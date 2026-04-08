---
applyTo: "lib/**"
---

# Folder Structure Instructions — Pinterest Clone

## Complete Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # PinterestApp widget (MaterialApp.router)
│
├── config/
│   ├── app_config.dart                # App-wide configuration (name, version)
│   ├── environment.dart               # Environment variables (.env loader)
│   └── remote_config.dart             # Firebase Remote Config (feature flags)
│
├── core/
│   ├── base/
│   │   ├── base_exception.dart        # Abstract exception classes
│   │   ├── base_failure.dart          # Abstract failure classes (Either left)
│   │   ├── base_model.dart            # Base model mixin (toEntity, fromJson)
│   │   ├── base_state.dart            # Base view state enum
│   │   └── base_usecase.dart          # UseCase<Params, Type> contract
│   │
│   ├── constants/
│   │   ├── api_constants.dart         # Base URLs, timeout values
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── asset_constants.dart       # Asset path strings
│   │   ├── duration_constants.dart    # Animation/transition durations
│   │   └── storage_keys.dart          # Local storage key strings
│   │
│   ├── design_systems/
│   │   ├── colors/
│   │   │   └── app_colors.dart        # Color palette (dark + light)
│   │   ├── typography/
│   │   │   └── app_typography.dart    # Text styles
│   │   ├── borders/
│   │   │   └── app_borders.dart       # Border radius values
│   │   ├── spacing/
│   │   │   └── app_spacing.dart       # Spacing scale
│   │   ├── shadows/
│   │   │   └── app_shadows.dart       # Box shadow definitions
│   │   └── dimensions/
│   │       └── app_dimensions.dart    # Fixed dimension values
│   │
│   ├── di/
│   │   ├── injection.dart             # Root dependency injection (Riverpod)
│   │   └── providers.dart             # Core-level provider definitions
│   │
│   ├── extensions/
│   │   ├── build_context_ext.dart     # Context extensions (theme, media query)
│   │   ├── string_ext.dart            # String utilities
│   │   ├── widget_ext.dart            # Widget extensions (padding, shimmer)
│   │   └── num_ext.dart               # Number extensions (spacing helpers)
│   │
│   ├── services/
│   │   ├── api/
│   │   │   ├── api_client.dart        # Dio instance setup
│   │   │   ├── api_endpoints.dart     # Endpoint URL constants
│   │   │   ├── api_exceptions.dart    # API-specific exceptions
│   │   │   ├── api_interceptors.dart  # Auth/retry/cache interceptors
│   │   │   └── network_error_handler.dart
│   │   │
│   │   ├── storage/
│   │   │   └── app_storage.dart       # Local storage abstraction
│   │   │
│   │   └── media/
│   │       └── media_cache_service.dart  # Image/video cache management
│   │
│   ├── theme/
│   │   └── app_theme.dart             # ThemeData builder (light + dark)
│   │
│   ├── ui/
│   │   ├── atoms/                     # Smallest widgets (button, icon, text)
│   │   ├── molecules/                 # Compound widgets (card, search bar)
│   │   ├── organisms/                 # Complex widgets (grid, nav bar)
│   │   ├── templates/                 # Page layout templates
│   │   └── screens/                   # Full-screen states (loading, error, empty)
│   │
│   └── utils/
│       ├── app_logger.dart            # Logging utility (debug-only)
│       ├── debouncer.dart             # Debounce utility for search
│       ├── enums.dart                 # Shared enums
│       ├── validators/
│       │   └── validators.dart        # Input validators
│       └── formatters/
│           └── formatters.dart        # Date, number formatters
│
├── features/
│   ├── auth/                          # Authentication (Clerk + Google)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   ├── auth_providers.dart
│   │   │   │   └── auth_notifier.dart
│   │   │   ├── views/
│   │   │   │   ├── onboarding_screen.dart
│   │   │   │   └── login_screen.dart
│   │   │   └── widgets/
│   │   │       ├── google_sign_in_button.dart
│   │   │       └── login_form.dart
│   │   └── docs/
│   │
│   ├── home/                          # Home feed with masonry grid
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── home_remote_datasource.dart
│   │   │   │   └── home_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── photo_model.dart
│   │   │   │   └── photo_src_model.dart
│   │   │   └── repositories/
│   │   │       └── home_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── photo.dart
│   │   │   ├── repositories/
│   │   │   │   └── home_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_curated_photos_usecase.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   ├── home_providers.dart
│   │   │   │   └── home_notifier.dart
│   │   │   ├── views/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── pin_card.dart
│   │   │       ├── masonry_feed.dart
│   │   │       ├── ad_carousel.dart
│   │   │       └── featured_boards_section.dart
│   │   └── docs/
│   │
│   ├── search/                        # Search & Explore
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   ├── views/
│   │   │   │   └── search_screen.dart
│   │   │   └── widgets/
│   │   │       ├── search_bar_widget.dart
│   │   │       ├── category_section.dart
│   │   │       └── search_results_grid.dart
│   │   └── docs/
│   │
│   ├── pin_detail/                    # Pin detail view
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   ├── views/
│   │   │   │   └── pin_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── pin_action_bar.dart
│   │   │       ├── pin_info_section.dart
│   │   │       └── more_to_explore.dart
│   │   └── docs/
│   │
│   ├── create/                        # Create/Upload pin
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── docs/
│   │
│   ├── messages/                      # Messages/Chat
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── docs/
│   │
│   └── profile/                       # User profile & saved pins
│       ├── data/
│       ├── domain/
│       ├── presentation/
│       │   ├── providers/
│       │   ├── views/
│       │   │   └── profile_screen.dart
│       │   └── widgets/
│       │       ├── profile_header.dart
│       │       ├── profile_tabs.dart
│       │       └── saved_pins_grid.dart
│       └── docs/
│
├── router/
│   ├── app_router.dart                # GoRouter configuration
│   ├── route_names.dart               # Route name constants
│   └── route_guards.dart              # Auth guards / redirects
│
└── l10n/                              # Localization (optional)
    ├── app_en.arb
    └── app_localizations.dart
```

## File Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Feature folder | `snake_case` | `pin_detail/` |
| Dart file | `snake_case` | `pin_card.dart` |
| Class | `PascalCase` | `PinCard` |
| Provider | `camelCase` | `pinsProvider` |
| Constant | `camelCase` | `primaryRed` |
| Private field | `_camelCase` | `_counter` |
| Test file | `<name>_test.dart` | `pin_card_test.dart` |

## Feature Creation Checklist

When creating a new feature:

1. Use the **📦 Create New Feature** VS Code task
2. Rename `bloc/` → `providers/` directory
3. Create domain entities first (pure Dart)
4. Define repository contract (abstract class)
5. Implement data models with JSON serialization
6. Implement datasources (remote + local)
7. Implement repository
8. Create usecases
9. Create Riverpod providers
10. Build UI (views + widgets)
11. Add routes to `app_router.dart`
12. Write tests
13. Document in `docs/README.md`
