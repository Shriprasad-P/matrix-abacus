from datetime import date, datetime, timezone
from uuid import uuid4

from sqlalchemy import Boolean, Date, DateTime, Float, ForeignKey, Integer, JSON, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


def new_id() -> str:
    return str(uuid4())


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    role: Mapped[str] = mapped_column(String(20), default="parent", nullable=False, index=True)
    mobile: Mapped[str] = mapped_column(String(20), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(120), default="Parent", nullable=False)
    email: Mapped[str | None] = mapped_column(String(255), nullable=True)
    notifications_enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    practice_reminders: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    announcement_alerts: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)

    children: Mapped[list["ChildProfile"]] = relationship(
        back_populates="parent", cascade="all, delete-orphan"
    )


class OtpChallenge(Base):
    __tablename__ = "otp_challenges"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    mobile: Mapped[str] = mapped_column(String(20), nullable=False, index=True)
    code_digest: Mapped[str] = mapped_column(String(128), nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    attempts: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    consumed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class ChildProfile(Base):
    __tablename__ = "children"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    parent_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    age: Mapped[int] = mapped_column(Integer, nullable=False)
    class_name: Mapped[str] = mapped_column(String(80), default="Beginner", nullable=False)
    school_name: Mapped[str] = mapped_column(String(180), default="", nullable=False)
    avatar_color: Mapped[int] = mapped_column(Integer, default=0xFFE0E7FF, nullable=False)
    avatar_emoji: Mapped[str] = mapped_column(String(8), default="🌟", nullable=False)
    current_level: Mapped[str] = mapped_column(String(120), default="Level 1", nullable=False)
    current_course: Mapped[str] = mapped_column(String(120), default="Abacus Foundations", nullable=False)
    streak: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    overall_progress: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    accuracy: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    avg_speed_seconds: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    badges: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)

    parent: Mapped[User] = relationship(back_populates="children")
    course_progress: Mapped[list["ChildCourseProgress"]] = relationship(
        back_populates="child", cascade="all, delete-orphan"
    )


class Course(Base):
    __tablename__ = "courses"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    description: Mapped[str] = mapped_column(Text, default="", nullable=False)
    color: Mapped[int] = mapped_column(Integer, default=0xFF4F46E5, nullable=False)
    active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)

    levels: Mapped[list["CourseLevel"]] = relationship(
        back_populates="course", cascade="all, delete-orphan", order_by="CourseLevel.order"
    )


class CourseLevel(Base):
    __tablename__ = "course_levels"
    __table_args__ = (UniqueConstraint("course_id", "order", name="uq_course_level_order"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    course_id: Mapped[str] = mapped_column(ForeignKey("courses.id", ondelete="CASCADE"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    order: Mapped[int] = mapped_column(Integer, nullable=False)

    course: Mapped[Course] = relationship(back_populates="levels")
    progress: Mapped[list["ChildCourseProgress"]] = relationship(
        back_populates="level", cascade="all, delete-orphan"
    )


class ChildCourseProgress(Base):
    __tablename__ = "child_course_progress"
    __table_args__ = (UniqueConstraint("child_id", "level_id", name="uq_child_level_progress"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    child_id: Mapped[str] = mapped_column(ForeignKey("children.id", ondelete="CASCADE"), nullable=False, index=True)
    level_id: Mapped[str] = mapped_column(ForeignKey("course_levels.id", ondelete="CASCADE"), nullable=False, index=True)
    state: Mapped[str] = mapped_column(String(20), default="locked", nullable=False)
    progress: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)

    child: Mapped[ChildProfile] = relationship(back_populates="course_progress")
    level: Mapped[CourseLevel] = relationship(back_populates="progress")


class AttendanceDay(Base):
    __tablename__ = "attendance_days"
    __table_args__ = (UniqueConstraint("child_id", "date", name="uq_child_attendance_date"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    child_id: Mapped[str] = mapped_column(ForeignKey("children.id", ondelete="CASCADE"), nullable=False, index=True)
    date: Mapped[date] = mapped_column(Date, nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="none", nullable=False)


class Worksheet(Base):
    __tablename__ = "worksheets"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    child_id: Mapped[str] = mapped_column(ForeignKey("children.id", ondelete="CASCADE"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    description: Mapped[str] = mapped_column(Text, default="", nullable=False)
    instructions: Mapped[str] = mapped_column(Text, default="", nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="new", nullable=False)
    progress: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    due_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    storage_key: Mapped[str | None] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class PracticeActivity(Base):
    __tablename__ = "practice_activities"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    description: Mapped[str] = mapped_column(Text, default="", nullable=False)
    duration_seconds: Mapped[int] = mapped_column(Integer, default=300, nullable=False)
    difficulty: Mapped[str] = mapped_column(String(20), default="easy", nullable=False)
    active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)

    questions: Mapped[list["PracticeQuestion"]] = relationship(
        back_populates="activity", cascade="all, delete-orphan", order_by="PracticeQuestion.position"
    )


class PracticeQuestion(Base):
    __tablename__ = "practice_questions"
    __table_args__ = (UniqueConstraint("activity_id", "position", name="uq_activity_question_position"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    activity_id: Mapped[str] = mapped_column(ForeignKey("practice_activities.id", ondelete="CASCADE"), nullable=False, index=True)
    position: Mapped[int] = mapped_column(Integer, nullable=False)
    prompt: Mapped[str] = mapped_column(String(240), nullable=False)
    operand_a: Mapped[int] = mapped_column(Integer, nullable=False)
    operand_b: Mapped[int] = mapped_column(Integer, nullable=False)
    operator: Mapped[str] = mapped_column(String(4), default="+", nullable=False)
    correct_answer: Mapped[int] = mapped_column(Integer, nullable=False)

    activity: Mapped[PracticeActivity] = relationship(back_populates="questions")


class PracticeSession(Base):
    __tablename__ = "practice_sessions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    child_id: Mapped[str] = mapped_column(ForeignKey("children.id", ondelete="CASCADE"), nullable=False, index=True)
    activity_id: Mapped[str] = mapped_column(ForeignKey("practice_activities.id"), nullable=False, index=True)
    status: Mapped[str] = mapped_column(String(20), default="active", nullable=False)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    elapsed_seconds: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    correct_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_questions: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    accuracy: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    avg_speed_seconds: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)

    answers: Mapped[list["PracticeAnswer"]] = relationship(
        back_populates="session", cascade="all, delete-orphan"
    )


class PracticeAnswer(Base):
    __tablename__ = "practice_answers"
    __table_args__ = (UniqueConstraint("session_id", "question_id", name="uq_session_question_answer"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    session_id: Mapped[str] = mapped_column(ForeignKey("practice_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    question_id: Mapped[str] = mapped_column(ForeignKey("practice_questions.id"), nullable=False)
    answer: Mapped[int] = mapped_column(Integer, nullable=False)
    is_correct: Mapped[bool] = mapped_column(Boolean, nullable=False)
    elapsed_seconds: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    answered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)

    session: Mapped[PracticeSession] = relationship(back_populates="answers")


class PracticeResult(Base):
    __tablename__ = "practice_results"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    child_id: Mapped[str] = mapped_column(ForeignKey("children.id", ondelete="CASCADE"), nullable=False, index=True)
    session_id: Mapped[str | None] = mapped_column(ForeignKey("practice_sessions.id", ondelete="SET NULL"), nullable=True)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    topic: Mapped[str] = mapped_column(String(120), default="Daily Practice", nullable=False)
    score: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    accuracy: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    avg_speed_seconds: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    teacher_feedback: Mapped[str | None] = mapped_column(Text, nullable=True)
    stars: Mapped[int] = mapped_column(Integer, default=0, nullable=False)


class Certificate(Base):
    __tablename__ = "certificates"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    child_id: Mapped[str] = mapped_column(ForeignKey("children.id", ondelete="CASCADE"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    description: Mapped[str] = mapped_column(Text, default="", nullable=False)
    earned: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    earned_date: Mapped[date | None] = mapped_column(Date, nullable=True)


class Announcement(Base):
    __tablename__ = "announcements"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)
    priority: Mapped[str] = mapped_column(String(20), default="normal", nullable=False)


class AnnouncementRead(Base):
    __tablename__ = "announcement_reads"
    __table_args__ = (UniqueConstraint("announcement_id", "user_id", name="uq_announcement_user_read"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    announcement_id: Mapped[str] = mapped_column(ForeignKey("announcements.id", ondelete="CASCADE"), nullable=False)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    read_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow, nullable=False)


class PaymentPlan(Base):
    __tablename__ = "payment_plans"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    parent_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True)
    name: Mapped[str] = mapped_column(String(160), nullable=False)
    amount: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    billing_cycle: Mapped[str] = mapped_column(String(40), default="monthly", nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="due", nullable=False)
    next_due_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    due_amount: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)


class PaymentReceipt(Base):
    __tablename__ = "payment_receipts"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=new_id)
    parent_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    amount: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    date: Mapped[date] = mapped_column(Date, default=date.today, nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="paid", nullable=False)
    external_reference: Mapped[str | None] = mapped_column(String(120), nullable=True)
