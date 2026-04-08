# Pinterest Clone

A **pixel-perfect Pinterest clone** built with Flutter, replicating the official Pinterest mobile app — screens, animations, transitions, and micro-interactions.

## Screenshots

<!-- Add screenshots here -->

## Tech Stack

| Category | Package |
|---|---|
| **Framework** | Flutter (SDK ^3.11.0) |
| **State Management** | `flutter_riverpod` |
| **Navigation** | `go_router` |
| **Networking** | `dio` |
| **Authentication** | `clerk_flutter` (Clerk) |
| **Image Caching** | `cached_network_image` |
| **Loading Effects** | `shimmer` |
| **Grid Layout** | `flutter_staggered_grid_view` |
| **Responsiveness** | `flutter_screenutil` |
| **Serialization** | `freezed` + `json_serializable` |
| **Functional** | `dartz` (Either type) |
| **Local Storage** | `shared_preferences` + `flutter_secure_storage` |
| **Environment** | `flutter_dotenv` |

## Architecture

Clean Architecture with strict layer separation:

```
lib/
├── config/              # App config, environment, remote config
├── core/                # Shared utilities, services, design system, DI
│   ├── base/            # Base classes (UseCase, Failure, State)
│   ├── constants/       # API, asset, storage key constants
│   ├── design_systems/  # Colors, typography, spacing, borders, shadows
│   ├── di/              # Dependency injection
│   ├── extensions/      # BuildContext, String, num extensions
│   ├── services/        # API client, storage
│   ├── theme/           # App theme (dark/light)
│   ├── ui/              # Reusable atoms/molecules/organisms
│   └── utils/           # Logger, validators, formatters
├── features/            # Feature modules
│   ├── auth/            # Authentication (Clerk), signup, login, forgot password
│   ├── home/            # Home feed (curated + "For You" topic-based)
│   ├── search/          # Photo search
│   ├── create/          # Pin creation
│   ├── messages/        # Messages
│   ├── pin_detail/      # Pin detail view
│   ├── profile/         # User profile
│   └── localization/    # Multi-language support (en, hi, te)
├── router/              # GoRouter setup, route guards
└── main.dart            # Entry point
```

Each feature follows:
```
feature/
├── data/           # Datasources, models, repository implementations
├── domain/         # Entities, repository contracts, use cases
├── presentation/   # Providers (Riverpod), views, widgets
└── docs/           # Feature documentation
```

## Features

- **Authentication** — Email/password signup & login via Clerk, Google SSO, guest mode
- **7-Step Signup** — Email → Password → Email Verification → Birthday → Gender → Country → Topics → Confirmation
- **Email Existence Check** — Real-time Clerk check at email step, redirects to login if registered
- **Forgot Password** — Reset code via email, set new password
- **Home Feed** — 2-column masonry grid, "All" (curated) + "For You" (topic-based) tabs
- **Pin Detail** — Full-screen view with Hero animation, related pins
- **Search** — Photo search via Pexels API
- **Profile** — User info from Clerk API with local storage fallback
- **Shimmer Loading** — Loading placeholders on all async content
- **Localization** — English, Hindi, Telugu
- **Dark Theme** — Pinterest-style dark UI

## API

Uses the [Pexels API](https://www.pexels.com/api/) for photo content:
- `GET /v1/curated` — Curated photos for home feed
- `GET /v1/search` — Search + "For You" topic-based feed
- `GET /v1/photos/:id` — Single photo detail

## Setup

### Prerequisites

- Flutter SDK ^3.11.0
- Dart SDK ^3.11.0
- A [Pexels API key](https://www.pexels.com/api/)
- A [Clerk](https://clerk.com/) publishable key

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/pinterest.git
cd pinterest

# Install dependencies
flutter pub get

# Create .env file from example
cp .env.example .env
# Add your API keys to .env:
#   PEXELS_API_KEY=your_pexels_key
#   CLERK_PUBLISHABLE_KEY=your_clerk_key

# Generate freezed/json_serializable code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Available Commands

```bash
flutter pub get                                            # Install dependencies
dart run build_runner build --delete-conflicting-outputs   # Code generation
dart run build_runner watch --delete-conflicting-outputs   # Watch mode
flutter analyze                                            # Static analysis
flutter test                                               # Run tests
flutter run                                                # Run app
```

## Design System

All UI values use design tokens — no hardcoded colors, spacing, or pixel values:

| Token | Location |
|---|---|
| Colors | `core/design_systems/colors/` |
| Typography | `core/design_systems/typography/` |
| Spacing | `core/design_systems/spacing/` |
| Borders | `core/design_systems/borders/` |
| Shadows | `core/design_systems/shadows/` |
| Dimensions | `core/design_systems/dimensions/` |

Responsive values use `flutter_screenutil`: `.w`, `.h`, `.sp`, `.r`

## Project Conventions

- **Imports** — Always `package:pinterest/...` (no relative imports)
- **State** — Riverpod (`AsyncNotifier`, `FutureProvider`, `NotifierProvider`)
- **Errors** — `Either<Failure, T>` from dartz in repositories
- **Logging** — `AppLogger.info()` / `.error()` / `.debug()` (no `print()`)
- **Storage** — `AppStorage` provider only (no direct SharedPreferences)
- **Navigation** — `RouteNames` / `RoutePaths` constants with GoRouter
- **Widgets** — `ConsumerWidget` / `ConsumerStatefulWidget`, `const` constructors

## License

This project is for educational purposes only. Pinterest is a trademark of Pinterest, Inc.
