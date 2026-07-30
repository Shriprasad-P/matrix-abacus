from datetime import date, datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class OtpRequestIn(BaseModel):
    mobile: str = Field(min_length=10, max_length=20)


class OtpRequestOut(BaseModel):
    challenge_id: str
    expires_at: datetime
    dev_otp: str | None = None


class OtpVerifyIn(BaseModel):
    mobile: str = Field(min_length=10, max_length=20)
    otp: str = Field(min_length=4, max_length=8)


class UserOut(ORMModel):
    id: str
    role: str
    mobile: str
    name: str
    email: str | None
    notifications_enabled: bool
    practice_reminders: bool
    announcement_alerts: bool


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class ParentUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    email: str | None = Field(default=None, max_length=255)
    notifications_enabled: bool | None = None
    practice_reminders: bool | None = None
    announcement_alerts: bool | None = None


class ChildCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    age: int = Field(ge=2, le=18)
    class_name: str = Field(default="Beginner", max_length=80)
    school_name: str = Field(default="", max_length=180)
    avatar_color: int = 0xFFE0E7FF
    avatar_emoji: str = Field(default="🌟", max_length=8)


class ChildUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    age: int | None = Field(default=None, ge=2, le=18)
    class_name: str | None = Field(default=None, max_length=80)
    school_name: str | None = Field(default=None, max_length=180)
    avatar_color: int | None = None
    avatar_emoji: str | None = Field(default=None, max_length=8)


class ChildOut(ORMModel):
    id: str
    name: str
    age: int
    class_name: str
    school_name: str
    avatar_color: int
    avatar_emoji: str
    current_level: str
    current_course: str
    streak: int
    overall_progress: float
    accuracy: float
    avg_speed_seconds: float
    badges: list[str]


class CourseLevelOut(BaseModel):
    id: str
    title: str
    order: int
    state: str
    progress: float


class CourseOut(BaseModel):
    id: str
    title: str
    description: str
    color: int
    progress: float
    levels: list[CourseLevelOut]


class AttendanceDayOut(ORMModel):
    date: date
    status: str


class AttendanceSummaryOut(BaseModel):
    percentage: float
    present_count: int
    absent_count: int
    holiday_count: int
    days: list[AttendanceDayOut]


class WorksheetOut(ORMModel):
    id: str
    child_id: str
    title: str
    description: str
    instructions: str
    status: str
    progress: float
    due_date: date | None
    created_at: datetime


class WorksheetProgressUpdate(BaseModel):
    status: str | None = Field(default=None, pattern="^(new|in_progress|completed)$")
    progress: float | None = Field(default=None, ge=0.0, le=1.0)


class PracticeResultOut(ORMModel):
    id: str
    child_id: str
    title: str
    topic: str
    score: int
    total: int
    accuracy: float
    avg_speed_seconds: float
    date: datetime
    teacher_feedback: str | None
    stars: int


class CertificateOut(ORMModel):
    id: str
    child_id: str
    title: str
    description: str
    earned: bool
    earned_date: date | None


class AnnouncementOut(BaseModel):
    id: str
    title: str
    body: str
    date: datetime
    priority: str
    is_read: bool


class PaymentPlanOut(ORMModel):
    id: str
    name: str
    amount: float
    billing_cycle: str
    status: str
    next_due_date: date | None
    due_amount: float


class PaymentReceiptOut(ORMModel):
    id: str
    title: str
    amount: float
    date: date
    status: str
    external_reference: str | None


class WeeklyActivityPoint(BaseModel):
    date: date
    sessions: int
    questions_answered: int


class PracticeQuestionOut(BaseModel):
    id: str
    position: int
    prompt: str
    operand_a: int
    operand_b: int
    operator: str


class PracticeActivityOut(BaseModel):
    id: str
    title: str
    description: str
    duration_seconds: int
    difficulty: str
    questions: list[PracticeQuestionOut]


class PracticeSessionStartIn(BaseModel):
    child_id: str
    activity_id: str | None = None


class PracticeAnswerIn(BaseModel):
    question_id: str
    answer: int
    elapsed_seconds: int = Field(default=0, ge=0)


class PracticeAnswerOut(BaseModel):
    question_id: str
    answer: int
    is_correct: bool
    correct_answer: int | None = None
    elapsed_seconds: int


class PracticeSessionOut(BaseModel):
    id: str
    child_id: str
    activity: PracticeActivityOut
    status: str
    started_at: datetime
    completed_at: datetime | None
    elapsed_seconds: int
    correct_count: int
    total_questions: int
    accuracy: float
    avg_speed_seconds: float
    answers: list[PracticeAnswerOut]


class PracticeAnswerResponse(BaseModel):
    session: PracticeSessionOut
    is_correct: bool
    correct_answer: int
    next_position: int | None


class PracticeCompleteOut(BaseModel):
    session: PracticeSessionOut
    result: PracticeResultOut


class AdminCourseCreate(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    description: str = ""
    color: int = 0xFF4F46E5


class AdminLevelCreate(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    order: int = Field(ge=1)


class AdminWorksheetCreate(BaseModel):
    child_id: str
    title: str = Field(min_length=1, max_length=160)
    description: str = ""
    instructions: str = ""
    due_date: date | None = None


class AdminAnnouncementCreate(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    body: str = Field(min_length=1)
    priority: str = Field(default="normal", pattern="^(normal|important)$")


class AdminQuestionCreate(BaseModel):
    position: int = Field(ge=0)
    prompt: str = Field(min_length=1, max_length=240)
    operand_a: int
    operand_b: int
    operator: str = "+"
    correct_answer: int


class AdminActivityCreate(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    description: str = ""
    duration_seconds: int = Field(default=300, ge=1)
    difficulty: str = Field(default="easy", pattern="^(easy|medium|challenge)$")
    questions: list[AdminQuestionCreate] = Field(min_length=1)


class DashboardOut(BaseModel):
    parent: UserOut
    children: list[ChildOut]
    selected_child: ChildOut | None
    courses: list[CourseOut]
    attendance: AttendanceSummaryOut | None
    worksheets: list[WorksheetOut]
    results: list[PracticeResultOut]
    certificates: list[CertificateOut]
    announcements: list[AnnouncementOut]
    payment_plan: PaymentPlanOut | None
    receipts: list[PaymentReceiptOut]
    daily_activity: PracticeActivityOut | None
    weekly_activity: list[WeeklyActivityPoint]
    unread_announcements: int


class AdminOverviewOut(BaseModel):
    active_students: int
    parent_accounts: int
    active_courses: int
    pending_worksheets: int
    active_activities: int
    announcements: int
