# Matrix Abacus — Application Architecture & Inventory

**Product:** Parent-managed mathematics learning application  
**Type:** Flutter UI/UX prototype (no real backend)  
**Repo:** https://github.com/Shriprasad-P/matrix-abacus  
**Stack:** Flutter 3.x · Material 3 · Dart · local in-memory state · mock repositories  

---

## 1. Product overview

Matrix Abacus helps parents manage one or more children’s abacus/maths learning. Children do **not** have a separate login. Practice mode opens from the selected child profile inside the parent account.

| Role | Capabilities |
|------|----------------|
| **Parent** | View/switch children, progress, attendance, courses, worksheets, results, certificates, announcements, payments, settings; open practice mode |
| **Child (practice mode)** | Daily drill, answer questions, use abacus visualizer, see feedback, score/speed/accuracy, streaks/badges, completion |

### Out of scope (by design)

- Real authentication / SMS OTP APIs  
- Real payments / payment gateway  
- Push notifications  
- Database or remote API integration  
- Rankings / social comparison  

All data is **local mock data** with in-memory updates for the session.

---

## 2. High-level architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation                          │
│  Features (screens)  +  Core widgets (design system)         │
└────────────────────────────┬────────────────────────────────┘
                             │ reads / writes
┌────────────────────────────▼────────────────────────────────┐
│                     Application state                        │
│              AppState (ChangeNotifier)                       │
│              AppStateScope (InheritedNotifier)               │
└────────────────────────────┬────────────────────────────────┘
                             │ calls
┌────────────────────────────▼────────────────────────────────┐
│                     Repository layer                         │
│         MatrixRepository  ←→  MockMatrixRepository           │
└────────────────────────────┬────────────────────────────────┘
                             │ loads
┌────────────────────────────▼────────────────────────────────┐
│                      Mock data / models                      │
│         MockData  +  typed domain models                     │
└─────────────────────────────────────────────────────────────┘
```

**Principles**

- **Feature-based folders** for screens  
- **Shared core** for models, mock data, repositories, state, reusable widgets  
- **Repository abstraction** so UI can later swap mocks for real APIs without major UI rewrites  
- **Named routes** for navigation  
- **No unnecessary packages** beyond `google_fonts` and Flutter SDK  

---

## 3. Folder structure

```
lib/
├── main.dart                          # Entry: portrait lock + runApp
├── app/
│   ├── app.dart                       # MatrixAbacusApp + AppStateScope
│   ├── router.dart                    # Named-route map + screen wiring
│   └── theme/
│       ├── app_colors.dart            # Design tokens (palette)
│       ├── app_spacing.dart           # Spacing scale
│       ├── app_dimensions.dart        # Radii, touch targets, sizes
│       ├── app_typography.dart        # Plus Jakarta Sans text styles
│       └── app_theme.dart             # Material 3 ThemeData
├── core/
│   ├── constants/app_constants.dart   # App name, route name constants
│   ├── models/                        # Domain models + enums
│   ├── mock/mock_data.dart            # Seed data for prototype
│   ├── repositories/matrix_repository.dart
│   ├── state/app_state.dart           # Global in-memory state
│   └── widgets/                       # Reusable UI components
└── features/
    ├── onboarding/                    # Splash, welcome
    ├── authentication/                # Login, OTP, loading, child setup
    ├── shell/                         # Parent bottom-nav shell
    ├── dashboard/                     # Parent home
    ├── children/                      # Child profile
    ├── progress/
    ├── attendance/
    ├── courses/
    ├── worksheets/
    ├── results/
    ├── certificates/
    ├── announcements/
    ├── payments/
    ├── settings/                      # More + settings + info pages
    └── practice/                      # Child practice flow
```

Platform folders (`android/`, `ios/`, `macos/`) are standard Flutter scaffolding.

---

## 4. Layer details

### 4.1 App shell (`lib/app/`)

| File | Responsibility |
|------|----------------|
| `main.dart` | Ensures Flutter binding; locks preferred orientation to portrait; starts app |
| `app.dart` | Creates `AppState`, wraps tree in `AppStateScope`, configures `MaterialApp` + theme + router |
| `router.dart` | `onGenerateRoute` for every screen; central place for navigation callbacks |
| `theme/*` | Design system: colors, type, spacing, dimensions, Material 3 theme |

### 4.2 Domain models (`lib/core/models/`)

| Model | Purpose |
|-------|---------|
| `Parent` | Parent profile + notification preference flags |
| `ChildProfile` | Child identity, level, streak, accuracy, badges |
| `Course` / `CourseLevel` | Courses with level states (locked / unlocked / current / completed) |
| `AttendanceDay` / `AttendanceSummary` | Calendar attendance + percentages |
| `Worksheet` | Assigned worksheets + status/progress |
| `PracticeResult` | Practice/session results + optional teacher feedback |
| `Certificate` | Earned vs locked certificates |
| `Announcement` | Centre announcements + read/unread |
| `PaymentPlan` / `PaymentReceipt` | Plan + receipt history |
| `PracticeActivity` / `PracticeQuestion` / `PracticeSessionState` | Daily drill content + live session |
| `WeeklyActivityPoint` | Simple weekly activity chart points |
| `enums.dart` | Shared enums (worksheet status, level state, UI demo state, etc.) |

### 4.3 Mock data & repository

**`MockData`** (`lib/core/mock/mock_data.dart`)

- 1 parent (Priya Sharma)  
- 3 children (Aarav, Anaya, Vihaan)  
- Courses/levels per child  
- Attendance (~30 days)  
- Worksheets, results, certificates  
- Announcements  
- Payment plan + receipts  
- Daily practice questions (8 arithmetic items)  
- Weekly activity points  

**`MatrixRepository`** (abstract) + **`MockMatrixRepository`**

- Async fetch methods with artificial latency (~650 ms)  
- `verifyOtp` accepts any 4–6 digit numeric OTP  
- Replace `MockMatrixRepository` with an API implementation later; keep the same interface  

### 4.4 Application state (`AppState`)

Central `ChangeNotifier` holding:

- Auth / bootstrap flags  
- Selected child ID  
- Child-scoped lists (courses, attendance, worksheets, results, certificates, weekly activity)  
- Announcements, payment plan/receipts  
- Active practice session + last practice result  
- Demo UI states (worksheets/certificates loading/empty/error)  

Key behaviors:

- `bootstrapAccount` — load parent + children + scoped data  
- `selectChild` — switch profile and reload scoped data  
- Practice: `startPractice`, `submitAnswer`, `advanceQuestion`, `pause/resume/restart`, `completePractice`, `endPractice`  
- Local streak/accuracy updates after practice  
- Mock payment success + logout  

Access pattern:

```dart
AppState.of(context);   // listen (rebuild on notify)
AppState.read(context); // one-shot actions (no listen)
```

---

## 5. Screen inventory

### Onboarding & authentication

| # | Screen | File | Notes |
|---|--------|------|-------|
| 1 | Splash | `features/onboarding/splash_screen.dart` | Brand animation → welcome |
| 2 | Welcome | `features/onboarding/welcome_screen.dart` | Get started / existing account |
| 3 | Parent login | `features/authentication/login_screen.dart` | 10-digit mobile |
| 4 | OTP | `features/authentication/otp_screen.dart` | Mock OTP |
| 5 | Account loading | `features/authentication/account_loading_screen.dart` | Bootstraps mock account |
| 6 | First-time child setup | `features/authentication/child_setup_screen.dart` | Optional add child |

### Parent application

| # | Screen | File | Notes |
|---|--------|------|-------|
| 7 | Home dashboard | `features/dashboard/dashboard_screen.dart` | Greeting, child card, progress, practice CTA, worksheets, announcements, quick actions |
| 8 | Child switcher | `core/widgets/child_switcher.dart` | Modal bottom sheet |
| 9 | Child profile | `features/children/child_profile_screen.dart` | Avatar, level, streak, badges |
| 10 | Progress | `features/progress/progress_screen.dart` | Overall + weekly chart + course progress |
| 11 | Attendance | `features/attendance/attendance_screen.dart` | Calendar + present/absent/holiday |
| 12 | Courses & levels | `features/courses/courses_screen.dart` | Course cards + locked/current/completed levels |
| 13 | Worksheets | `features/worksheets/worksheets_screen.dart` | List + demo loading/empty/error |
| 14 | Worksheet details | same file | Title, instructions, progress, mock download |
| 15 | Results | `features/results/results_screen.dart` | Score, accuracy, speed, feedback |
| 16 | Certificates | `features/certificates/certificates_screen.dart` | Earned/locked + details |
| 17 | Announcements | `features/announcements/announcements_screen.dart` | List + detail + mark read |
| 18 | Payments | `features/payments/payments_screen.dart` | Plan, receipts, mock pay + success |
| 19 | Settings / More | `features/settings/more_screen.dart` | Profile prefs, legal, help, logout |

### Child practice mode

| # | Screen / component | File | Notes |
|---|-------------------|------|-------|
| 20 | Practice intro | `features/practice/practice_intro_screen.dart` | Duration, difficulty, start |
| 21 | Question | `features/practice/practice_question_screen.dart` | Timer, question, input, feedback, exit confirm |
| 22 | Abacus visualizer | `core/widgets/practice_widgets.dart` | Interactive beads (local only) |
| 23 | Pause | `features/practice/practice_pause_screen.dart` | Resume / restart / exit |
| 24 | Completion | `features/practice/practice_complete_screen.dart` | Score, stars, streak, again / home |

### Shell

| Screen | File | Tabs |
|--------|------|------|
| Parent shell | `features/shell/parent_shell.dart` | Home · Practice · Progress · Worksheets · More |

---

## 6. Navigation map

```
Splash
  └─ Welcome
       └─ Login (firstTime: true|false)
            └─ OTP
                 └─ Account Loading
                      ├─ [first time] Child Setup ─┐
                      └────────────────────────────┴─► Parent Shell (/app)

Parent Shell (IndexedStack + NavigationBar)
  Home ──────► child profile, attendance, courses, results,
               certificates, announcements, payments, practice intro
  Practice ──► Practice Intro → Question ⇄ Pause → Complete → Shell
  Progress
  Worksheets ► Worksheet details
  More ──────► Settings, Payments, Certificates, Results,
               Attendance, Courses, Announcements
                 Settings ► Privacy / Terms / Help / Logout → Welcome
                 Payments ► Payment success
```

**Route names** live in `AppRoutes` (`lib/core/constants/app_constants.dart`).

---

## 7. Design system

### Visual direction

- Trustworthy for parents; playful but not childish for kids  
- Soft optimistic palette: deep indigo primary, warm orange secondary  
- Soft backgrounds, white cards, rounded corners, large touch targets (≥ 48 px)  
- Material 3 customized (not default Flutter look)  
- Typography: **Plus Jakarta Sans** via `google_fonts`  

### Token files

| Token | File |
|-------|------|
| Colors | `app_colors.dart` |
| Spacing | `app_spacing.dart` |
| Dimensions | `app_dimensions.dart` |
| Typography | `app_typography.dart` |
| Theme assembly | `app_theme.dart` |

### Reusable components

| Component | Location |
|-----------|----------|
| Primary / secondary buttons | `common_widgets.dart` |
| Page header, avatar, status chip | `common_widgets.dart` |
| Empty / error / loading skeleton | `common_widgets.dart` |
| Confirmation dialog helper | `common_widgets.dart` |
| Child profile card, progress/stat cards | `feature_cards.dart` |
| Course / worksheet / announcement / certificate cards | `feature_cards.dart` |
| Child switcher bottom sheet | `child_switcher.dart` |
| Attendance calendar, weekly progress chart | `charts.dart` |
| Abacus, answer input, practice header, success animation | `practice_widgets.dart` |

---

## 8. UI states implemented

| State | Where |
|-------|--------|
| Loading | Account loading; worksheets/certificates demo; skeletons |
| Empty | Worksheets, results, certificates demo, announcements |
| Error | Worksheets demo error + retry |
| Success | Practice complete; payment success; OTP continue |
| Disabled | Locked pay button when already paid; locked certificate action |
| Locked | Course levels; certificates not yet earned |

Worksheets and Certificates menus (⋮) can force Loading / Empty / Error / Normal for demos.

---

## 9. Key user flows

### Mock login

1. Splash → Welcome  
2. Enter any 10-digit mobile → Send OTP  
3. Enter any 4–6 digit OTP → Verify  
4. Account loads mock parent + 3 children  
5. First-time path can add a child; otherwise go to Home  

### Switch child

Home child card → switch icon → bottom sheet → select child → scoped data reloads  

### Practice session

Practice tab / Daily practice card → Intro → Start → answer with optional abacus → correct/incorrect feedback → next → Complete (score, stars, streak) → practice again or return home  

### Mock payment

More / Payments → Pay now → success screen → plan marked paid + receipt added (local only)  

---

## 10. Data flow (practice example)

```
UI (PracticeQuestionScreen)
  → AppState.submitAnswer(answer)
      → compares to PracticeQuestion.correctAnswer
      → updates session feedback + correctCount
  → AppState.advanceQuestion()
      → if last: completePractice()
          → writes PracticeResult into results
          → updates child streak / accuracy / progress
          → navigates to completion screen
```

---

## 11. Replacing mocks with real APIs

1. Keep models under `lib/core/models/`  
2. Implement `MatrixRepository` with HTTP/gRPC clients  
3. Construct `AppState(repository: YourApiRepository())` in `app.dart`  
4. Replace `verifyOtp` with real auth; keep login/OTP UI  
5. Wire payments / file download / push behind the same button actions  

UI screens should not need a large rewrite if the repository contract is preserved.

---

## 12. Testing & quality

| Check | Command / status |
|-------|------------------|
| Analyzer | `flutter analyze` (clean at delivery) |
| Widget tests | `test/widget_test.dart` — splash→welcome; mock login→shell |
| Dependencies | Flutter SDK, `cupertino_icons`, `google_fonts` |

---

## 13. Assumptions

1. One parent account manages multiple children; no child login.  
2. Practice updates streak/accuracy in memory only (lost on app restart).  
3. Worksheet download and Pay now are UI-only (snackbar / success screen).  
4. Sample content is India-oriented (INR, +91 mobile) for realism.  
5. Portrait is the primary layout target.  
6. Prefer project path **without spaces** for iOS device builds (`MatrixAbacusApplication`).  

---

## 14. Quick start

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
cd "/Users/shriprasad/Documents/Projects/MatrixAbacusApplication"
flutter pub get
flutter run            # pick device when prompted
# or:
flutter run -d chrome
```

**Mock OTP:** any 4–6 digits (e.g. `1234`) after any 10-digit mobile number.

---

## 15. Document map

| Doc | Purpose |
|-----|---------|
| `README.md` | How to run, mock login, navigation summary |
| `ARCHITECTURE.md` (this file) | Full inventory, architecture, screens, design system, API swap guide |
