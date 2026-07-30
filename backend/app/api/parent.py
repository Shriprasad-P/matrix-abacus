from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from .deps import get_current_user, get_owned_child
from .schemas import (
    DashboardOut,
    ParentUpdate,
    UserOut,
)
from .serializers import (
    activity_out,
    announcement_out,
    attendance_out,
    child_out,
    course_out,
    weekly_points,
)
from ..core.database import get_db
from ..core.models import (
    Announcement,
    AnnouncementRead,
    AttendanceDay,
    Certificate,
    ChildCourseProgress,
    Course,
    PaymentPlan,
    PaymentReceipt,
    PracticeActivity,
    PracticeAnswer,
    PracticeResult,
    PracticeSession,
    User,
    Worksheet,
)

router = APIRouter(tags=["parent"])


def _courses_for_child(db: Session, child_id: str):
    courses = db.scalars(
        select(Course)
        .where(Course.active.is_(True))
        .options(selectinload(Course.levels))
        .order_by(Course.created_at)
    ).all()
    progress_rows = db.scalars(
        select(ChildCourseProgress)
        .where(ChildCourseProgress.child_id == child_id)
    ).all()
    progress_map = {row.level_id: row for row in progress_rows}
    return [course_out(course, progress_map) for course in courses]


def _announcements_for_user(db: Session, user_id: str):
    announcements = db.scalars(
        select(Announcement).order_by(Announcement.date.desc())
    ).all()
    reads = db.scalars(
        select(AnnouncementRead).where(AnnouncementRead.user_id == user_id)
    ).all()
    read_map = {read.announcement_id: read for read in reads}
    return [announcement_out(item, read_map.get(item.id)) for item in announcements]


def _dashboard_for_child(db: Session, child_id: str, user: User) -> dict:
    child = get_owned_child(child_id, user, db)
    attendance_days = db.scalars(
        select(AttendanceDay)
        .where(AttendanceDay.child_id == child.id)
        .order_by(AttendanceDay.date)
    ).all()
    worksheets = db.scalars(
        select(Worksheet)
        .where(Worksheet.child_id == child.id)
        .order_by(Worksheet.due_date, Worksheet.created_at.desc())
    ).all()
    results = db.scalars(
        select(PracticeResult)
        .where(PracticeResult.child_id == child.id)
        .order_by(PracticeResult.date.desc())
    ).all()
    certificates = db.scalars(
        select(Certificate)
        .where(Certificate.child_id == child.id)
        .order_by(Certificate.earned.desc(), Certificate.earned_date.desc())
    ).all()
    sessions = db.scalars(
        select(PracticeSession).where(PracticeSession.child_id == child.id)
    ).all()
    session_ids = [session.id for session in sessions]
    answers = db.scalars(
        select(PracticeAnswer).where(PracticeAnswer.session_id.in_(session_ids))
    ).all() if session_ids else []
    daily_activity = db.scalar(
        select(PracticeActivity)
        .where(PracticeActivity.active.is_(True))
        .options(selectinload(PracticeActivity.questions))
        .order_by(PracticeActivity.created_at)
    )
    plan = db.scalar(select(PaymentPlan).where(PaymentPlan.parent_id == user.id))
    receipts = db.scalars(
        select(PaymentReceipt)
        .where(PaymentReceipt.parent_id == user.id)
        .order_by(PaymentReceipt.date.desc())
    ).all()
    announcements = _announcements_for_user(db, user.id)

    return {
        "parent": UserOut.model_validate(user),
        "children": [child_out(item) for item in user.children],
        "selected_child": child_out(child),
        "courses": _courses_for_child(db, child.id),
        "attendance": attendance_out(attendance_days),
        "worksheets": worksheets,
        "results": results,
        "certificates": certificates,
        "announcements": announcements,
        "payment_plan": plan,
        "receipts": receipts,
        "daily_activity": activity_out(daily_activity) if daily_activity else None,
        "weekly_activity": weekly_points(sessions, answers),
        "unread_announcements": sum(not item.is_read for item in announcements),
    }


@router.get("/parent/me", response_model=UserOut)
def get_parent(user: User = Depends(get_current_user)) -> UserOut:
    return UserOut.model_validate(user)


@router.patch("/parent/me", response_model=UserOut)
def update_parent(
    payload: ParentUpdate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserOut:
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(user, field, value)
    db.commit()
    db.refresh(user)
    return UserOut.model_validate(user)


@router.get("/dashboard", response_model=DashboardOut)
def dashboard(
    child_id: str | None = Query(default=None),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DashboardOut:
    selected_id = child_id or (user.children[0].id if user.children else None)
    if selected_id is None:
        return DashboardOut(
            parent=UserOut.model_validate(user),
            children=[],
            selected_child=None,
            courses=[],
            attendance=None,
            worksheets=[],
            results=[],
            certificates=[],
            announcements=_announcements_for_user(db, user.id),
            payment_plan=db.scalar(select(PaymentPlan).where(PaymentPlan.parent_id == user.id)),
            receipts=db.scalars(select(PaymentReceipt).where(PaymentReceipt.parent_id == user.id)).all(),
            daily_activity=None,
            weekly_activity=[],
            unread_announcements=0,
        )
    return DashboardOut.model_validate(_dashboard_for_child(db, selected_id, user))


@router.get("/announcements")
def announcements(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return _announcements_for_user(db, user.id)

