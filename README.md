# Matrix Abacus

For a full screen inventory, architecture layers, and design-system map, see **[ARCHITECTURE.md](ARCHITECTURE.md)**.

Parent-managed mathematics learning app — Flutter UI/UX prototype plus a FastAPI backend.

The Flutter client still defaults to local mock state. The backend is available under `backend/` and is ready to replace the mock repository with REST API calls.

## How to run

```bash
# Ensure Flutter is on PATH (example after local SDK install)
export PATH="$PATH:$HOME/development/flutter/bin"

cd "/Users/shriprasad/Documents/Projects/MatrixAbacusApplication"
flutter pub get
flutter run
```

Pick a connected device/simulator, or:

```bash
flutter run -d chrome   # web smoke check
flutter run -d macos    # if desktop enabled
```

Analyze & test:

```bash
flutter analyze
flutter test
```

## Mock login behavior

1. Splash → Welcome  
2. **Get started** or **I already have an account** → mobile login  
3. Enter any **10-digit** mobile number  
4. Enter any **4–6 digit** OTP (e.g. `1234`)  
5. Account loading simulates a short delay, then:
   - **Get started** path → optional first-time child setup  
   - **Existing account** path → parent home with 3 sample children  

There is no SMS. Invalid OTP format shows an error; otherwise any digits continue.

## Screen / navigation map

```
Splash → Welcome → Login → OTP → Account Loading
                              ├─ (first time) Child Setup → Parent Shell
                              └─ Parent Shell

Parent Shell (bottom nav)
├─ Home (dashboard)
├─ Practice → Practice Intro → Question (+ Abacus) → Pause / Complete
├─ Progress
├─ Worksheets → Worksheet details
└─ More
   ├─ Settings (prefs, privacy, terms, help, logout)
   ├─ Payments → mock payment success
   ├─ Certificates → details (earned / locked)
   ├─ Results
   ├─ Attendance
   ├─ Courses & levels
   └─ Announcements → details

Also reachable from Home quick actions / cards:
Child profile · Child switcher (modal sheet) · Attendance · Courses · etc.
```

## Project structure

```
lib/
  app/           # MaterialApp, router, theme
  core/
    constants/
    models/
    mock/        # MockData
    repositories/# MatrixRepository + MockMatrixRepository
    state/       # AppState + AppStateScope
    widgets/     # Reusable design-system components
  features/      # Feature screens (onboarding, auth, dashboard, practice, …)
```

## Replacing mock services with real APIs

1. Keep models in `lib/core/models/`.  
2. Implement `MatrixRepository` (see `lib/core/repositories/matrix_repository.dart`) with HTTP/gRPC clients.  
3. Construct `AppState(repository: YourApiRepository())` in `lib/app/app.dart`.  
4. Replace mock OTP in `verifyOtp` with a real auth flow; keep UI screens as-is.  
5. Wire payments / downloads / push to real SDKs behind the same UI actions.

## Backend

The FastAPI backend lives in `backend/`. It provides PostgreSQL-ready persistence, OTP/JWT authentication, parent/child ownership checks, learning data, practice sessions, announcements, payments, and admin content endpoints.

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

See [backend/README.md](backend/README.md) for the API flow, demo credentials, PostgreSQL setup, and production hardening checklist.

UI should not need a major rewrite if the repository contract is preserved.

## Demo UI states

- **Worksheets** and **Certificates**: overflow menu (⋮) switches Loading / Empty / Error / Normal.  
- Locked levels and locked certificates are always visible.  
- Payment success is a dedicated mock screen (no charge).

## Design notes

- Material 3 with custom indigo / warm accent palette  
- Plus Jakarta Sans via `google_fonts`  
- Large touch targets (≥ 48 logical px where interactive)  
- Portrait-first; layouts avoid dense “dashboard clutter”  
- Child practice is full-screen and focused (no bottom nav)

## Assumptions

- One parent account manages multiple children; children have **no separate login**.  
- Practice updates streak / accuracy locally in memory only.  
- “Download / view worksheet” and “Pay now” are UI affordances with snackbars / success screens.  
- Sample data includes three children (Aarav, Anaya, Vihaan).  
- Flutter SDK was not present in the environment initially; install Flutter 3.x+ to build.
