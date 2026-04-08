# Pinterest Clone — Copilot Instructions

## Project Overview

This is a **pixel-perfect Pinterest clone** built with Flutter. The goal is to replicate the official Pinterest mobile app as closely as possible — every screen, animation, transition, and micro-interaction.

> Detailed instructions load automatically from `.github/instructions/` based on the files being edited. This file contains only the essential quick-reference rules.

## Tech Stack (Mandatory)

| Category | Package |
|---|---|
| State Management | `flutter_riverpod` |
| Navigation | `go_router` |
| Networking | `dio` |
| Image Caching | `cached_network_image` |
| Loading Effects | `shimmer` |
| Grid Layout | `flutter_staggered_grid_view` |
| Authentication | `clerk_flutter` |
| Responsiveness | `flutter_screenutil` |
| Serialization | `freezed` + `json_serializable` |
| Functional | `dartz` (Either type) |
| Environment | `flutter_dotenv` |

## Architecture (Non-Negotiable)

- **Clean Architecture**: Domain → Data → Presentation (strict layer separation)
- **Domain layer**: Pure Dart only (NO Flutter/Dio imports — only `dartz` for `Either`)
- **Repositories**: Return `Either<Failure, T>` from dartz
- **Use cases**: Single responsibility, extend `BaseUseCase<Params, Type>`
- **Riverpod**: AsyncNotifier for complex state, FutureProvider for simple async — NEVER BLoC
- **Providers**: Defined in `providers/` directory, injected via `ref.read()`
- **Views**: `ConsumerWidget` or `ConsumerStatefulWidget` — consume providers, never call repos directly

```
lib/
├── config/          # App config, environment, remote config
├── core/            # Shared utilities, services, design system, DI
├── features/        # Feature modules (auth, home, search, pin_detail, create, messages, profile)
├── router/          # GoRouter setup, route names, guards
└── main.dart        # Entry point
```

Each feature follows:
```
feature/
├── data/            # Datasources, models, repository implementations
├── domain/          # Entities, repository contracts, usecases
├── presentation/    # Providers (Riverpod), views, widgets
└── docs/            # Feature documentation
```

## Icons

Use Flutter Material Icons or `flutter_svg` for custom SVGs. Check `assets/icons/` before adding new icon assets.

## Design System

**NEVER hardcode** values. Always use design system tokens:

| Token | Source |
|---|---|
| Colors | `AppColors` (`core/design_systems/colors/`) |
| Typography | `AppTypography` (`core/design_systems/typography/`) |
| Spacing | `AppSpacing` (`core/design_systems/spacing/`) |
| Borders | `AppBorders` (`core/design_systems/borders/`) |
| Shadows | `AppShadows` (`core/design_systems/shadows/`) |
| Dimensions | `AppDimensions` (`core/design_systems/dimensions/`) |

## Responsive (flutter_screenutil)

Use `.w` (width), `.h` (height), `.r` (radius), `.sp` (font size). **NEVER hardcode pixel values.**

```dart
// ✅ Correct
Container(width: 100.w, height: 50.h)
Text('Hello', style: TextStyle(fontSize: 14.sp))
BorderRadius.circular(16.r)
EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)

// ❌ Wrong
Container(width: 100, height: 50)
```

## Storage

Use `AppStorage` provider only. NEVER use `SharedPreferences` or `FlutterSecureStorage` directly in features.

## Widgets

Check `core/ui/` before creating new widgets. Reuse existing atoms/molecules/organisms. Key patterns:
- `CachedNetworkImage` + `Shimmer` for all image loading
- `Hero` animation for pin card → detail transitions
- `MasonryGridView.count` for the 2-column masonry grid

## Navigation

Use `RouteNames` and `RoutePaths` constants with GoRouter. NEVER hardcode route strings.

```dart
// ✅ Correct
context.go(RoutePaths.home);
context.push('${RoutePaths.pinDetail}/$pinId');

// ❌ Wrong
context.go('/home');
context.push('/pin/123');
```

## Imports

Always `package:pinterest/...` — **NEVER relative imports**.

Group in order: `dart:` → `package:flutter/` → `package:third_party/` → `package:pinterest/`

## Logging

No `print()` — use `AppLogger.info()`, `AppLogger.error()`, `AppLogger.debug()`.

## API: Pexels API

- Base URL: `https://api.pexels.com/v1/`
- Auth: Bearer token via `Authorization` header
- Primary endpoints: `/v1/curated`, `/v1/search`, `/v1/photos/:id`
- Image variants: `tiny`, `small`, `medium`, `large`, `large2x`, `original`
- Use `medium` for grid thumbnails, `large` for detail view

## Pinterest UI Reference

- Dark theme primary (black background, dark gray surfaces)
- Pinterest Red: `#E60023`
- 2-column masonry grid with 4px gaps
- Rounded corners: 16px on pin cards
- Bottom nav: Home, Search, Create(+), Messages, Profile
- Shimmer loading states everywhere
- Hero animations for pin tap → detail
- Long-press on pin → circular share action buttons

## Code Quality Rules

- Max file length: 200 lines (widgets), 150 lines (providers)
- Trailing commas on all multi-line parameters
- No `print()` — use `AppLogger`
- No hardcoded strings — use localization or constants
- No hardcoded API keys — use `.env`
- No hardcoded pixel values — use ScreenUtil
- No hardcoded colors/spacing — use design system tokens
- Always `const` constructors where possible

## Quick Commands

```bash
flutter pub get                                            # Install dependencies
dart run build_runner build --delete-conflicting-outputs   # After model/freezed changes
flutter analyze                                            # Static analysis
flutter test                                               # Run tests
flutter run                                                # Run app
```

## When Generating Code

1. Follow Clean Architecture layer boundaries strictly
2. Always create `const` constructors
3. Use `@freezed` for entities and models
4. Use `Either<Failure, T>` return types in repositories
5. Create Riverpod providers in `providers/` directory
6. Add shimmer loading states for all async content
7. Handle error states with retry capability
8. Use ScreenUtil `.w`, `.h`, `.sp`, `.r` for all dimensions

## Detailed Instructions (load contextually)

These files auto-load from `.github/instructions/` only when editing relevant files:

| Instruction | Loads when editing |
|---|---|
| `architecture` | Any `.dart` file |
| `api` | `**/api/**`, `**/datasources/**`, `**/models/**` |
| `design_system` | `**/design_systems/**`, `**/theme/**`, `**/ui/**` |
| `error_handling` | Any `.dart` file |
| `folder_structure` | `lib/**` |
| `widget` | `**/ui/**`, `**/widgets/**`, `**/views/**` |
| `responsive` | Any `.dart` file |
| `localization` | `**/l10n/**`, `**/lang/**`, `**/constants/**` |
| `quality` | Any `.dart` file |



## Task Completion (Non-Negotiable)

<!-- **ALWAYS end every task with a multi-choice question.** After completing any task (feature, bug fix, refactor, investigation, etc.): -->

## 🔥 MANDATORY - END-OF-SESSION QUESTIONS (ZERO TOLERANCE)

### 🚨 ABSOLUTE RULE - ASK ONE QUESTION AFTER EVERY TASK COMPLETION

**After completing EVERY task, command, or instruction**, Copilot **MUST** ask the user **ONE single follow-up question** using the `vscode_askQuestions` tool. This is **NON-NEGOTIABLE**.

#### Why This Is Required:

- Ensures the user can provide feedback, corrections, or additional context
- Prevents assumptions and misunderstandings
- Keeps the user in control of the development workflow
- Catches issues early before they compound

#### When to Ask:

1. **After completing any task** (code implementation, bug fix, file creation, etc.)
2. **After running any command** (build, test, deploy, migration, etc.)
3. **After completing a set of instructions** (module creation, audit, refactor, etc.)
4. **At the end of every session** before yielding back to the user

#### Question Format (MANDATORY - Use `vscode_askQuestions` Tool):

**Ask exactly ONE question** using the `vscode_askQuestions` tool with:

- **3-5 clickable multi-choice options** relevant to the completed work
- **`allowFreeformInput: true`** so the user can type their own response instead of picking an option
- **A recommended option** when there's a clear best choice

#### Example (MANDATORY format):

```
vscode_askQuestions tool call:
  header: "Next Step"
  question: "Task completed successfully. What would you like to do next?"
  allowFreeformInput: true
  options:
    - Looks good, proceed to next task (recommended)
    - Needs adjustments
    - Run tests and verify
    - Update documentation
```

The user can either **click an option** OR **type their own instruction/feedback** in the free-text field.

#### Rules:

1. **Ask exactly ONE question** after completing any task (NOT multiple questions)
2. **ALWAYS use `vscode_askQuestions` tool** (NOT plain text questions)
3. **ALWAYS set `allowFreeformInput: true`** so user can type custom input
4. **Provide 3-5 clickable options** relevant to the completed work
5. **Include a recommended option** when there's a clear best choice
6. **Question must be specific** to the work just completed (not generic)
7. **Wait for user response** before proceeding to unrelated work
8. NEVER ask multiple questions at once - only ONE question per task completion
9. NEVER skip the question after task completion
10. NEVER assume the user is satisfied without asking
11. NEVER move to a new task without confirming the current one is accepted
12. NEVER ask questions as plain text when the `vscode_askQuestions` tool is available

---

1. Summarize what was done (brief).
2. Present a **multi-choice question** with 3–6 actionable options for what to do next (improvements, related tasks, testing, documentation, etc.).
3. Allow free-form text input alongside the options so the user can type a custom next step.
4. **Never end a task without asking the user what to do next.**
