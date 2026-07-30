from datetime import datetime, timedelta, timezone
import hashlib
import hmac
import secrets

from jose import JWTError, jwt

from .config import get_settings


def normalize_mobile(mobile: str) -> str:
    normalized = "".join(character for character in mobile if character.isdigit())
    if len(normalized) < 10 or len(normalized) > 15:
        raise ValueError("Mobile number must contain between 10 and 15 digits")
    return normalized


def generate_otp() -> str:
    settings = get_settings()
    if settings.dev_auth:
        return settings.dev_otp
    return str(secrets.randbelow(900000) + 100000)


def hash_otp(otp: str) -> str:
    settings = get_settings()
    return hmac.new(settings.jwt_secret_key.encode(), otp.encode(), hashlib.sha256).hexdigest()


def verify_otp_digest(otp: str, digest: str) -> bool:
    return hmac.compare_digest(hash_otp(otp), digest)


def create_access_token(user_id: str, role: str) -> str:
    settings = get_settings()
    expires = datetime.now(timezone.utc) + timedelta(
        minutes=settings.jwt_access_token_expire_minutes
    )
    payload = {"sub": user_id, "role": role, "exp": expires}
    return jwt.encode(payload, settings.jwt_secret_key, algorithm="HS256")


def decode_access_token(token: str) -> dict[str, str]:
    settings = get_settings()
    try:
        return jwt.decode(token, settings.jwt_secret_key, algorithms=["HS256"])
    except JWTError as error:
        raise ValueError("Invalid or expired access token") from error

