from fastapi import APIRouter

from . import admin, auth, children, learning, parent, practice

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth.router)
api_router.include_router(parent.router)
api_router.include_router(children.router)
api_router.include_router(learning.router)
api_router.include_router(practice.router)
api_router.include_router(admin.router)

