# Matrix Abacus Backend

FastAPI backend for the Matrix Abacus parent-managed learning application.

## Included

- FastAPI REST API under /api/v1
- PostgreSQL-ready SQLAlchemy persistence
- SQLite local development and test support
- Parent OTP authentication with signed JWT access tokens
- Parent-owned child profiles and ownership checks
- Courses, levels, progress, attendance, worksheets, results, certificates
- Practice activities, secure server-side answer validation, sessions, and results
- Announcements with per-parent read state
- Payment-plan and receipt endpoints with a mock success flow
- Admin endpoints for courses, levels, worksheets, announcements, and practice activities
- OpenAPI documentation at /docs

The initial implementation intentionally leaves SMS delivery, object storage, push notifications, and real payment-gateway callbacks behind service boundaries. DEV_AUTH=true returns the development OTP in the request response; disable it in production.

## Local setup

From the repository root:

    cd backend
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    cp .env.example .env
    uvicorn app.main:app --reload

The API is available at:

- Health: http://127.0.0.1:8000/health
- Swagger UI: http://127.0.0.1:8000/docs
- OpenAPI JSON: http://127.0.0.1:8000/openapi.json

Demo login when SEED_DEMO_DATA=true:

- Parent mobile: 9876543210
- Admin mobile: 9999999999
- Development OTP: 1234

## PostgreSQL with Docker

    cd backend
    docker compose up -d db
    DATABASE_URL=postgresql+psycopg://matrix:matrix@localhost:5432/matrix_abacus uvicorn app.main:app --reload

Stop the database:

    docker compose down

## API flow for the Flutter client

1. POST /api/v1/auth/request-otp with { "mobile": "9876543210" }
2. POST /api/v1/auth/verify-otp with { "mobile": "9876543210", "otp": "1234" }
3. Send Authorization: Bearer <access_token> on subsequent requests.
4. GET /api/v1/children
5. Select a child and load:
   - GET /api/v1/courses?child_id=<id>
   - GET /api/v1/attendance?child_id=<id>
   - GET /api/v1/worksheets?child_id=<id>
   - GET /api/v1/results?child_id=<id>
   - GET /api/v1/certificates?child_id=<id>
   - GET /api/v1/practice/daily?child_id=<id>
6. For practice:
   - POST /api/v1/practice/sessions
   - POST /api/v1/practice/sessions/<session_id>/answers
   - POST /api/v1/practice/sessions/<session_id>/complete

## Production hardening still required

Before production deployment:

- Use a strong secret from a secret manager.
- Set DEV_AUTH=false.
- Connect an SMS/OTP provider.
- Add rate limiting backed by Redis or a gateway.
- Add Alembic migrations and run them in deployment.
- Add private object storage with signed download URLs.
- Replace mock payment success with Razorpay webhook verification.
- Add push/email/SMS notification providers.
- Add structured logging, metrics, tracing, backups, and CI security checks.

