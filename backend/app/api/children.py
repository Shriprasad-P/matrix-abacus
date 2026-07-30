from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from .deps import get_current_user, get_owned_child
from .parent import _courses_for_child
from .schemas import ChildCreate, ChildOut, ChildUpdate
from .serializers import child_out
from ..core.database import get_db
from ..core.models import ChildProfile, User

router = APIRouter(prefix="/children", tags=["children"])


@router.get("", response_model=list[ChildOut])
def list_children(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[ChildOut]:
    children = db.scalars(
        select(ChildProfile)
        .where(ChildProfile.parent_id == user.id)
        .order_by(ChildProfile.created_at)
    ).all()
    return [child_out(child) for child in children]


@router.post("", response_model=ChildOut, status_code=status.HTTP_201_CREATED)
def create_child(
    payload: ChildCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ChildOut:
    child = ChildProfile(parent_id=user.id, **payload.model_dump())
    db.add(child)
    db.commit()
    db.refresh(child)
    return child_out(child)


@router.get("/{child_id}", response_model=ChildOut)
def get_child(
    child_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ChildOut:
    return child_out(get_owned_child(child_id, user, db))


@router.patch("/{child_id}", response_model=ChildOut)
def update_child(
    child_id: str,
    payload: ChildUpdate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ChildOut:
    child = get_owned_child(child_id, user, db)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(child, field, value)
    db.commit()
    db.refresh(child)
    return child_out(child)


@router.get("/{child_id}/overview")
def child_overview(
    child_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    child = get_owned_child(child_id, user, db)
    return {
        "child": child_out(child),
        "courses": _courses_for_child(db, child.id),
    }

