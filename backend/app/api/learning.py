from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from .deps import get_current_user, get_owned_child
from .schemas import (
    AnnouncementOut,
    AttendanceSummaryOut,
    CertificateOut,
    CourseOut,
    PaymentPlanOut,
    PaymentReceiptOut,
    PracticeResultOut,
    WorksheetOut,
    WorksheetProgressUpdate,
)
from .serializers import announcement_out, attendance_out, course_out
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
    PracticeResult,
    User,
    Worksheet,
)
from datetime import date, timedelta
from uuid import uuid4

router = APIRouter(tags=["learning"])


@router.get("/courses", response_model=list[CourseOut])
def courses(
    child_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[CourseOut]:
    child = get_owned_child(child_id, user, db)
    course_rows = db.scalars(
        select(Course)
        .where(Course.active.is_(True))
        .options(selectinload(Course.levels))
        .order_by(Course.created_at)
    ).all()
    progress_rows = db.scalars(
        select(ChildCourseProgress).where(ChildCourseProgress.child_id == child.id)
    ).all()
    progress_map = {row.level_id: row for row in progress_rows}
    return [course_out(course, progress_map) for course in course_rows]


@router.get("/attendance", response_model=AttendanceSummaryOut)
def attendance(
    child_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AttendanceSummaryOut:
    child = get_owned_child(child_id, user, db)
    days = db.scalars(
        select(AttendanceDay)
        .where(AttendanceDay.child_id == child.id)
        .order_by(AttendanceDay.date)
    ).all()
    return attendance_out(days)


@router.get("/worksheets", response_model=list[WorksheetOut])
def worksheets(
    child_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[WorksheetOut]:
    child = get_owned_child(child_id, user, db)
    return db.scalars(
        select(Worksheet)
        .where(Worksheet.child_id == child.id)
        .order_by(Worksheet.due_date, Worksheet.created_at.desc())
    ).all()


@router.get("/worksheets/{worksheet_id}", response_model=WorksheetOut)
def worksheet(
    worksheet_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> WorksheetOut:
    item = db.get(Worksheet, worksheet_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Worksheet not found")
    get_owned_child(item.child_id, user, db)
    return item


@router.patch("/worksheets/{worksheet_id}", response_model=WorksheetOut)
def update_worksheet(
    worksheet_id: str,
    payload: WorksheetProgressUpdate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> WorksheetOut:
    item = db.get(Worksheet, worksheet_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Worksheet not found")
    get_owned_child(item.child_id, user, db)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(item, field, value)
    db.commit()
    db.refresh(item)
    return item


@router.get("/results", response_model=list[PracticeResultOut])
def results(
    child_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[PracticeResultOut]:
    child = get_owned_child(child_id, user, db)
    return db.scalars(
        select(PracticeResult)
        .where(PracticeResult.child_id == child.id)
        .order_by(PracticeResult.date.desc())
    ).all()


@router.get("/certificates", response_model=list[CertificateOut])
def certificates(
    child_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[CertificateOut]:
    child = get_owned_child(child_id, user, db)
    return db.scalars(
        select(Certificate)
        .where(Certificate.child_id == child.id)
        .order_by(Certificate.earned.desc(), Certificate.earned_date.desc())
    ).all()


@router.patch("/announcements/{announcement_id}/read", response_model=AnnouncementOut)
def mark_announcement_read(
    announcement_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AnnouncementOut:
    announcement = db.get(Announcement, announcement_id)
    if announcement is None:
        raise HTTPException(status_code=404, detail="Announcement not found")
    read = db.scalar(
        select(AnnouncementRead).where(
            AnnouncementRead.announcement_id == announcement_id,
            AnnouncementRead.user_id == user.id,
        )
    )
    if read is None:
        read = AnnouncementRead(announcement_id=announcement_id, user_id=user.id)
        db.add(read)
        db.commit()
    return announcement_out(announcement, read)


@router.get("/payments/plan", response_model=PaymentPlanOut | None)
def payment_plan(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PaymentPlanOut | None:
    return db.scalar(select(PaymentPlan).where(PaymentPlan.parent_id == user.id))


@router.get("/payments/receipts", response_model=list[PaymentReceiptOut])
def payment_receipts(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[PaymentReceiptOut]:
    return db.scalars(
        select(PaymentReceipt)
        .where(PaymentReceipt.parent_id == user.id)
        .order_by(PaymentReceipt.date.desc())
    ).all()


@router.post("/payments/mock-success", response_model=PaymentPlanOut)
def mock_payment_success(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PaymentPlanOut:
    plan = db.scalar(select(PaymentPlan).where(PaymentPlan.parent_id == user.id))
    if plan is None:
        raise HTTPException(status_code=404, detail="Payment plan not found")
    plan.status = "paid"
    plan.due_amount = 0
    plan.next_due_date = date.today() + timedelta(days=30)
    db.add(
        PaymentReceipt(
            parent_id=user.id,
            title=f"{plan.name} payment",
            amount=plan.amount,
            status="paid",
            external_reference=f"MA-{uuid4().hex[:10].upper()}",
        )
    )
    db.commit()
    db.refresh(plan)
    return plan

