from datetime import date, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from .models import (
    Announcement,
    AttendanceDay,
    Certificate,
    ChildCourseProgress,
    ChildProfile,
    Course,
    CourseLevel,
    PaymentPlan,
    PaymentReceipt,
    PracticeActivity,
    PracticeQuestion,
    PracticeResult,
    User,
    Worksheet,
)


def seed_demo_data(db: Session) -> None:
    if db.scalar(select(User).where(User.mobile == "9876543210")):
        return

    parent = User(
        mobile="9876543210",
        name="Priya Sharma",
        email="priya@example.com",
        role="parent",
    )
    admin = User(mobile="9999999999", name="Matrix Admin", role="admin")
    db.add_all([parent, admin])
    db.flush()

    children = [
        ChildProfile(
            parent_id=parent.id,
            name="Aarav Sharma",
            age=8,
            class_name="Level 2",
            avatar_color=0xFFE0E7FF,
            avatar_emoji="🧑🏽‍🎓",
            current_level="Level 2",
            current_course="Abacus Foundations",
            streak=6,
            overall_progress=0.68,
            accuracy=0.87,
            avg_speed_seconds=7.4,
            badges=["7-day streak", "Fast thinker"],
        ),
        ChildProfile(
            parent_id=parent.id,
            name="Anaya Sharma",
            age=6,
            class_name="Level 1",
            avatar_color=0xFFFFE4C7,
            avatar_emoji="👧🏽",
            current_level="Level 1",
            current_course="Number Sense",
            streak=3,
            overall_progress=0.42,
            accuracy=0.76,
            avg_speed_seconds=9.2,
            badges=["First week"],
        ),
        ChildProfile(
            parent_id=parent.id,
            name="Vihaan Sharma",
            age=10,
            class_name="Level 3",
            avatar_color=0xFFD1FAE5,
            avatar_emoji="🧒🏽",
            current_level="Level 3",
            current_course="Mental Arithmetic",
            streak=12,
            overall_progress=0.81,
            accuracy=0.93,
            avg_speed_seconds=5.9,
            badges=["12-day streak", "Accuracy ace", "Level up"],
        ),
    ]
    db.add_all(children)
    db.flush()

    course_one = Course(
        title="Abacus Foundations",
        description="Build number sense and confident abacus technique.",
        color=0xFF4F46E5,
    )
    course_two = Course(
        title="Mental Arithmetic",
        description="Strengthen speed and accuracy beyond the abacus.",
        color=0xFFF97316,
    )
    db.add_all([course_one, course_two])
    db.flush()

    levels = [
        CourseLevel(course_id=course_one.id, title="Number Sense", order=1),
        CourseLevel(course_id=course_one.id, title="Single-digit addition", order=2),
        CourseLevel(course_id=course_one.id, title="Two-digit addition", order=3),
        CourseLevel(course_id=course_two.id, title="Mental addition", order=1),
        CourseLevel(course_id=course_two.id, title="Speed drills", order=2),
    ]
    db.add_all(levels)
    db.flush()

    for child_index, child in enumerate(children):
        for index, level in enumerate(levels):
            state = "completed" if index < child_index + 1 else "current" if index == child_index + 1 else "locked"
            progress = 1.0 if state == "completed" else 0.4 if state == "current" else 0.0
            db.add(ChildCourseProgress(child_id=child.id, level_id=level.id, state=state, progress=progress))

        for day_offset in range(30):
            attendance_date = date.today() - timedelta(days=day_offset)
            status = "absent" if day_offset % 11 == 0 else "present"
            db.add(AttendanceDay(child_id=child.id, date=attendance_date, status=status))

        db.add_all(
            [
                Worksheet(
                    child_id=child.id,
                    title="Daily addition practice",
                    description="Complete ten addition questions using your abacus.",
                    instructions="Use the abacus first, then write the answer.",
                    status="in_progress" if child_index == 0 else "new",
                    progress=0.6 if child_index == 0 else 0.0,
                    due_date=date.today() + timedelta(days=3),
                ),
                Worksheet(
                    child_id=child.id,
                    title="Number bonds review",
                    description="Review number bonds up to twenty.",
                    instructions="Try each question without rushing.",
                    status="completed" if child_index == 2 else "new",
                    progress=1.0 if child_index == 2 else 0.0,
                    due_date=date.today() + timedelta(days=7),
                ),
            ]
        )
        db.add_all(
            [
                Certificate(
                    child_id=child.id,
                    title="Abacus starter",
                    description="Completed the first abacus learning milestone.",
                    earned=True,
                    earned_date=date.today() - timedelta(days=18),
                ),
                Certificate(
                    child_id=child.id,
                    title="Speed champion",
                    description="Complete a speed challenge with outstanding accuracy.",
                    earned=child_index == 2,
                    earned_date=date.today() - timedelta(days=3) if child_index == 2 else None,
                ),
            ]
        )
        db.add(
            PracticeResult(
                child_id=child.id,
                title="Yesterday's daily drill",
                topic="Addition",
                score=7 + child_index,
                total=8,
                accuracy=(7 + child_index) / 8,
                avg_speed_seconds=7.4 - child_index * 0.5,
                teacher_feedback="Keep practicing — consistency builds confidence.",
                stars=2 if child_index < 2 else 3,
            )
        )

    activity = PracticeActivity(
        title="Daily number sprint",
        description="A short arithmetic drill to keep your streak alive.",
        duration_seconds=300,
        difficulty="medium",
    )
    db.add(activity)
    db.flush()
    questions = [(3, 4), (6, 2), (9, 5), (7, 8), (12, 4), (5, 9), (8, 6), (11, 7)]
    db.add_all(
        [
            PracticeQuestion(
                activity_id=activity.id,
                position=index,
                prompt=f"{a} + {b} = ?",
                operand_a=a,
                operand_b=b,
                operator="+",
                correct_answer=a + b,
            )
            for index, (a, b) in enumerate(questions)
        ]
    )

    db.add_all(
        [
            Announcement(
                title="Welcome to this week's practice",
                body="Keep your daily streak going with a short number sprint.",
                priority="normal",
            ),
            Announcement(
                title="Parent progress meeting",
                body="Your centre has shared a new progress meeting schedule.",
                priority="important",
            ),
        ]
    )
    db.add(
        PaymentPlan(
            parent_id=parent.id,
            name="Monthly learning plan",
            amount=2500,
            billing_cycle="monthly",
            status="due",
            next_due_date=date.today() + timedelta(days=8),
            due_amount=2500,
        )
    )
    db.add(
        PaymentReceipt(
            parent_id=parent.id,
            title="June tuition",
            amount=2500,
            date=date.today() - timedelta(days=22),
            status="paid",
            external_reference="MA-DEMO-0001",
        )
    )
    db.commit()

