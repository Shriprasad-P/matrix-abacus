from fastapi import APIRouter, Depends, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from .deps import get_owned_child, require_admin
from .schemas import (
    AdminActivityCreate,
    AdminAnnouncementCreate,
    AdminCourseCreate,
    AdminLevelCreate,
    AdminOverviewOut,
    AdminWorksheetCreate,
    CourseLevelOut,
    CourseOut,
    WorksheetOut,
)
from .serializers import course_out
from ..core.database import get_db
from ..core.models import (
    Announcement,
    ChildCourseProgress,
    ChildProfile,
    Course,
    CourseLevel,
    PracticeActivity,
    PracticeQuestion,
    User,
    Worksheet,
)

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/overview", response_model=AdminOverviewOut)
def overview(
    _admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> AdminOverviewOut:
    return AdminOverviewOut(
        active_students=db.scalar(select(func.count(ChildProfile.id))) or 0,
        parent_accounts=db.scalar(select(func.count(User.id)).where(User.role == "parent")) or 0,
        active_courses=db.scalar(select(func.count(Course.id)).where(Course.active.is_(True))) or 0,
        pending_worksheets=db.scalar(
            select(func.count(Worksheet.id)).where(Worksheet.status != "completed")
        ) or 0,
        active_activities=db.scalar(
            select(func.count(PracticeActivity.id)).where(PracticeActivity.active.is_(True))
        ) or 0,
        announcements=db.scalar(select(func.count(Announcement.id))) or 0,
    )


@router.post("/courses", response_model=CourseOut, status_code=status.HTTP_201_CREATED)
def create_course(
    payload: AdminCourseCreate,
    _admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> CourseOut:
    course = Course(**payload.model_dump())
    db.add(course)
    db.commit()
    db.refresh(course)
    return course_out(course, {})


@router.post("/courses/{course_id}/levels", response_model=CourseLevelOut, status_code=status.HTTP_201_CREATED)
def create_level(
    course_id: str,
    payload: AdminLevelCreate,
    _admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> CourseLevelOut:
    course = db.get(Course, course_id)
    if course is None:
        from fastapi import HTTPException

        raise HTTPException(status_code=404, detail="Course not found")
    level = CourseLevel(course_id=course.id, **payload.model_dump())
    db.add(level)
    db.commit()
    db.refresh(level)
    return CourseLevelOut(id=level.id, title=level.title, order=level.order, state="locked", progress=0.0)


@router.post("/worksheets", response_model=WorksheetOut, status_code=status.HTTP_201_CREATED)
def create_worksheet(
    payload: AdminWorksheetCreate,
    _admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
) -> WorksheetOut:
    child = get_owned_child(payload.child_id, _admin, db)
    item = Worksheet(child_id=child.id, **payload.model_dump(exclude={"child_id"}))
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.post("/announcements", status_code=status.HTTP_201_CREATED)
def create_announcement(
    payload: AdminAnnouncementCreate,
    _admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    item = Announcement(**payload.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.post("/activities", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_activity(
    payload: AdminActivityCreate,
    _admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    activity = PracticeActivity(
        title=payload.title,
        description=payload.description,
        duration_seconds=payload.duration_seconds,
        difficulty=payload.difficulty,
    )
    db.add(activity)
    db.flush()
    db.add_all(
        [
            PracticeQuestion(activity_id=activity.id, **question.model_dump())
            for question in payload.questions
        ]
    )
    db.commit()
    db.refresh(activity)
    return {"id": activity.id, "title": activity.title, "question_count": len(payload.questions)}
