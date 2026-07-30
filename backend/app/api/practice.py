from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from .deps import get_current_user, get_owned_child
from .schemas import (
    PracticeActivityOut,
    PracticeAnswerIn,
    PracticeAnswerResponse,
    PracticeCompleteOut,
    PracticeSessionOut,
    PracticeSessionStartIn,
)
from .serializers import activity_out, session_out
from ..core.database import get_db
from ..core.models import (
    PracticeActivity,
    PracticeAnswer,
    PracticeQuestion,
    PracticeResult,
    PracticeSession,
    User,
)

router = APIRouter(prefix="/practice", tags=["practice"])


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _activity(db: Session, activity_id: str | None = None) -> PracticeActivity:
    statement = (
        select(PracticeActivity)
        .where(PracticeActivity.active.is_(True))
        .options(selectinload(PracticeActivity.questions))
    )
    if activity_id:
        statement = statement.where(PracticeActivity.id == activity_id)
    item = db.scalar(statement.order_by(PracticeActivity.created_at))
    if item is None:
        raise HTTPException(status_code=404, detail="Practice activity not found")
    return item


def _session(db: Session, session_id: str, user: User) -> tuple[PracticeSession, PracticeActivity]:
    item = db.scalar(
        select(PracticeSession)
        .where(PracticeSession.id == session_id)
        .options(selectinload(PracticeSession.answers))
    )
    if item is None:
        raise HTTPException(status_code=404, detail="Practice session not found")
    get_owned_child(item.child_id, user, db)
    activity = _activity(db, item.activity_id)
    return item, activity


@router.get("/daily", response_model=PracticeActivityOut)
def daily_practice(
    child_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PracticeActivityOut:
    get_owned_child(child_id, user, db)
    return activity_out(_activity(db))


@router.post("/sessions", response_model=PracticeSessionOut, status_code=status.HTTP_201_CREATED)
def start_session(
    payload: PracticeSessionStartIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PracticeSessionOut:
    child = get_owned_child(payload.child_id, user, db)
    activity = _activity(db, payload.activity_id)
    if not activity.questions:
        raise HTTPException(status_code=409, detail="Practice activity has no questions")
    item = PracticeSession(
        child_id=child.id,
        activity_id=activity.id,
        total_questions=len(activity.questions),
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return session_out(item, activity)


@router.get("/sessions/{session_id}", response_model=PracticeSessionOut)
def get_session(
    session_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PracticeSessionOut:
    item, activity = _session(db, session_id, user)
    return session_out(item, activity)


@router.post("/sessions/{session_id}/answers", response_model=PracticeAnswerResponse)
def answer_question(
    session_id: str,
    payload: PracticeAnswerIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PracticeAnswerResponse:
    item, activity = _session(db, session_id, user)
    if item.status != "active":
        raise HTTPException(status_code=409, detail="Practice session is not active")
    question = db.get(PracticeQuestion, payload.question_id)
    if question is None or question.activity_id != activity.id:
        raise HTTPException(status_code=404, detail="Question not found in this activity")
    if any(answer.question_id == question.id for answer in item.answers):
        raise HTTPException(status_code=409, detail="Question has already been answered")

    is_correct = payload.answer == question.correct_answer
    item.answers.append(
        PracticeAnswer(
            question_id=question.id,
            answer=payload.answer,
            is_correct=is_correct,
            elapsed_seconds=payload.elapsed_seconds,
        )
    )
    item.correct_count += int(is_correct)
    item.elapsed_seconds = max(item.elapsed_seconds, payload.elapsed_seconds)
    db.commit()
    db.refresh(item)

    next_question = next(
        (candidate.position for candidate in activity.questions if candidate.position > question.position),
        None,
    )
    return PracticeAnswerResponse(
        session=session_out(item, activity),
        is_correct=is_correct,
        correct_answer=question.correct_answer,
        next_position=next_question,
    )


@router.post("/sessions/{session_id}/complete", response_model=PracticeCompleteOut)
def complete_session(
    session_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PracticeCompleteOut:
    item, activity = _session(db, session_id, user)
    existing_result = db.scalar(select(PracticeResult).where(PracticeResult.session_id == item.id))
    if item.status == "completed" and existing_result is not None:
        return PracticeCompleteOut(
            session=session_out(item, activity),
            result=existing_result,
        )

    item.status = "completed"
    item.completed_at = _now()
    answered_count = len(item.answers)
    item.accuracy = item.correct_count / item.total_questions if item.total_questions else 0.0
    item.avg_speed_seconds = item.elapsed_seconds / answered_count if answered_count else 0.0
    stars = 3 if item.accuracy >= 0.9 else 2 if item.accuracy >= 0.7 else 1 if item.accuracy >= 0.5 else 0

    child = get_owned_child(item.child_id, user, db)
    child.streak += 1
    child.accuracy = (child.accuracy * 0.7) + (item.accuracy * 0.3)
    child.avg_speed_seconds = (
        (child.avg_speed_seconds * 0.7) + (item.avg_speed_seconds * 0.3)
        if child.avg_speed_seconds
        else item.avg_speed_seconds
    )
    child.overall_progress = min(1.0, child.overall_progress + 0.02)
    result = PracticeResult(
        child_id=child.id,
        session_id=item.id,
        title=activity.title,
        topic="Daily Practice",
        score=item.correct_count,
        total=item.total_questions,
        accuracy=item.accuracy,
        avg_speed_seconds=item.avg_speed_seconds,
        teacher_feedback="Keep practicing — consistency builds confidence.",
        stars=stars,
    )
    db.add(result)
    db.commit()
    db.refresh(item)
    db.refresh(result)
    return PracticeCompleteOut(
        session=session_out(item, activity),
        result=result,
    )

