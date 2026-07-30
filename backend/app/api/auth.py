from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import desc, select
from sqlalchemy.orm import Session

from .deps import get_current_user
from .schemas import OtpRequestIn, OtpRequestOut, OtpVerifyIn, TokenOut, UserOut
from ..core.config import get_settings
from ..core.database import get_db
from ..core.models import OtpChallenge, User
from ..core.security import (
    create_access_token,
    generate_otp,
    hash_otp,
    normalize_mobile,
    verify_otp_digest,
)

router = APIRouter(prefix="/auth", tags=["authentication"])


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _as_utc(value: datetime) -> datetime:
    return value if value.tzinfo else value.replace(tzinfo=timezone.utc)


@router.post("/request-otp", response_model=OtpRequestOut)
def request_otp(payload: OtpRequestIn, db: Session = Depends(get_db)) -> OtpRequestOut:
    try:
        mobile = normalize_mobile(payload.mobile)
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error

    settings = get_settings()
    otp = generate_otp()
    expires_at = _utcnow() + timedelta(seconds=settings.otp_expire_seconds)
    challenge = OtpChallenge(
        mobile=mobile,
        code_digest=hash_otp(otp),
        expires_at=expires_at,
    )
    db.add(challenge)
    db.commit()
    db.refresh(challenge)

    return OtpRequestOut(
        challenge_id=challenge.id,
        expires_at=expires_at,
        dev_otp=otp if settings.dev_auth else None,
    )


@router.post("/verify-otp", response_model=TokenOut)
def verify_otp(payload: OtpVerifyIn, db: Session = Depends(get_db)) -> TokenOut:
    try:
        mobile = normalize_mobile(payload.mobile)
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error

    challenge = db.scalar(
        select(OtpChallenge)
        .where(OtpChallenge.mobile == mobile, OtpChallenge.consumed_at.is_(None))
        .order_by(desc(OtpChallenge.created_at))
    )
    if challenge is None or _as_utc(challenge.expires_at) <= _utcnow():
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="OTP expired or not requested")
    settings = get_settings()
    if challenge.attempts >= settings.otp_max_attempts:
        raise HTTPException(status_code=status.HTTP_429_TOO_MANY_REQUESTS, detail="Too many OTP attempts")

    challenge.attempts += 1
    if not verify_otp_digest(payload.otp, challenge.code_digest):
        db.commit()
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid OTP")

    challenge.consumed_at = _utcnow()
    user = db.scalar(select(User).where(User.mobile == mobile))
    if user is None:
        user = User(mobile=mobile, name="Parent", role="parent")
        db.add(user)
    db.commit()
    db.refresh(user)

    return TokenOut(
        access_token=create_access_token(user.id, user.role),
        user=UserOut.model_validate(user),
    )


@router.get("/me", response_model=UserOut)
def current_user(user: User = Depends(get_current_user)) -> UserOut:
    return UserOut.model_validate(user)


@router.post("/logout", status_code=204)
def logout() -> None:
    # JWTs are stateless; the client discards its access token.
    return None

