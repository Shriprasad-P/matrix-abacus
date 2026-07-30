from collections.abc import Iterable

from ..core.models import (
    Announcement,
    AnnouncementRead,
    AttendanceDay,
    ChildCourseProgress,
    ChildProfile,
    Course,
    PaymentPlan,
    PaymentReceipt,
    PracticeActivity,
    PracticeAnswer,
    PracticeQuestion,
    PracticeSession,
    PracticeResult,
    Worksheet,
    User,
)
from .schemas import (
    AnnouncementOut,
    AttendanceSummaryOut,
    ChildOut,
    CourseLevelOut,
    CourseOut,
    PaymentPlanOut,
    PaymentReceiptOut,
    PracticeActivityOut,
    PracticeAnswerOut,
    PracticeQuestionOut,
    PracticeSessionOut,
    WeeklyActivityPoint,
)


def child_out(child: ChildProfile) -> ChildOut:
    return ChildOut.model_validate(child)


def course_out(course: Course, child_progress: dict[str, ChildCourseProgress]) -> CourseOut:
    levels = [
        CourseLevelOut(
            id=level.id,
            title=level.title,
            order=level.order,
            state=child_progress.get(level.id).state if level.id in child_progress else "locked",
            progress=child_progress.get(level.id).progress if level.id in child_progress else 0.0,
        )
        for level in course.levels
    ]
    progress = sum(level.progress for level in levels) / len(levels) if levels else 0.0
    return CourseOut(
        id=course.id,
        title=course.title,
        description=course.description,
        color=course.color,
        progress=progress,
        levels=levels,
    )


def attendance_out(days: Iterable[AttendanceDay]) -> AttendanceSummaryOut:
    ordered = sorted(days, key=lambda day: day.date)
    present = sum(day.status == "present" for day in ordered)
    absent = sum(day.status == "absent" for day in ordered)
    holiday = sum(day.status == "holiday" for day in ordered)
    denominator = present + absent
    percentage = present / denominator if denominator else 0.0
    return AttendanceSummaryOut(
        percentage=percentage,
        present_count=present,
        absent_count=absent,
        holiday_count=holiday,
        days=ordered,
    )


def announcement_out(announcement: Announcement, read: AnnouncementRead | None) -> AnnouncementOut:
    return AnnouncementOut(
        id=announcement.id,
        title=announcement.title,
        body=announcement.body,
        date=announcement.date,
        priority=announcement.priority,
        is_read=read is not None,
    )


def weekly_points(
    sessions: Iterable[PracticeSession],
    answers: Iterable[PracticeAnswer],
) -> list[WeeklyActivityPoint]:
    session_list = list(sessions)
    answer_list = list(answers)
    points: list[WeeklyActivityPoint] = []
    from datetime import date, timedelta

    today = date.today()
    for offset in range(6, -1, -1):
        day = today - timedelta(days=offset)
        day_sessions = [session for session in session_list if session.started_at.date() == day]
        day_session_ids = {session.id for session in day_sessions}
        points.append(
            WeeklyActivityPoint(
                date=day,
                sessions=len(day_sessions),
                questions_answered=sum(answer.session_id in day_session_ids for answer in answer_list),
            )
        )
    return points


def activity_out(activity: PracticeActivity) -> PracticeActivityOut:
    return PracticeActivityOut(
        id=activity.id,
        title=activity.title,
        description=activity.description,
        duration_seconds=activity.duration_seconds,
        difficulty=activity.difficulty,
        questions=[
            PracticeQuestionOut(
                id=question.id,
                position=question.position,
                prompt=question.prompt,
                operand_a=question.operand_a,
                operand_b=question.operand_b,
                operator=question.operator,
            )
            for question in activity.questions
        ],
    )


def session_out(session: PracticeSession, activity: PracticeActivity) -> PracticeSessionOut:
    return PracticeSessionOut(
        id=session.id,
        child_id=session.child_id,
        activity=activity_out(activity),
        status=session.status,
        started_at=session.started_at,
        completed_at=session.completed_at,
        elapsed_seconds=session.elapsed_seconds,
        correct_count=session.correct_count,
        total_questions=session.total_questions,
        accuracy=session.accuracy,
        avg_speed_seconds=session.avg_speed_seconds,
        answers=[
            PracticeAnswerOut(
                question_id=answer.question_id,
                answer=answer.answer,
                is_correct=answer.is_correct,
                correct_answer=None,
                elapsed_seconds=answer.elapsed_seconds,
            )
            for answer in session.answers
        ],
    )

