---
applyTo: "**/*.dart"
---

# Architecture Instructions — Pinterest Clone

## Clean Architecture (Strict 3-Layer)

This project follows **Clean Architecture** with strict dependency rules:

```
Presentation → Domain ← Data
```

- **Domain** is the innermost layer — it has ZERO dependencies on Flutter or external packages.
- **Data** implements domain contracts (repositories) and depends on domain.
- **Presentation** depends on domain (never directly on data).

## Layer Responsibilities

### 1. Domain Layer (`lib/features/<feature>/domain/`)

```
domain/
├── entities/          # Pure Dart classes — business objects
├── repositories/      # Abstract repository contracts (interfaces)
└── usecases/          # Single-responsibility business operations
```

**Rules:**
- Entities are immutable (`@freezed` or manual `const` constructors)
- Repository contracts are abstract classes with no implementation
- Each UseCase has ONE public `call()` method
- UseCases extend `BaseUseCase<Params, ReturnType>`
- No Flutter imports. No package imports except `dartz` for `Either`

### 2. Data Layer (`lib/features/<feature>/data/`)

```
data/
├── datasources/       # Remote (API) and Local (cache) data sources
├── models/            # Data transfer objects — JSON serialization
└── repositories/      # Concrete repository implementations
```

**Rules:**
- Models extend or map to domain Entities
- Models use `@JsonSerializable()` or `@freezed` for JSON conversion
- Remote datasources interact with `ApiClient` (Dio)
- Local datasources interact with `AppStorage` (Hive/SharedPreferences)
- Repository implementations handle error mapping → `Either<Failure, T>`
- Repository implementations decide cache-vs-network strategy

### 3. Presentation Layer (`lib/features/<feature>/presentation/`)

```
presentation/
├── providers/         # Riverpod providers, notifiers, controllers
├── views/             # Screen/Page widgets (full screens)
└── widgets/           # Feature-specific reusable widgets
```

**Rules:**
- Use Riverpod (`flutter_riverpod`) for state management — NOT BLoC
- Screens are `ConsumerWidget` or `ConsumerStatefulWidget`
- Providers are defined in `providers/` directory
- Use `AsyncNotifier` / `Notifier` for complex state
- Use `FutureProvider` / `StreamProvider` for simple async data
- Views NEVER directly call repository methods
- Views consume providers, providers call usecases

## State Management — Riverpod (NOT BLoC)

> **IMPORTANT**: Despite the folder structure showing `bloc/` directories, this project uses **Riverpod**. Rename `bloc/` → `providers/` when implementing.

### Provider Types & When to Use:

| Provider Type | Use When |
|---|---|
| `Provider` | Dependency injection, computed values |
| `FutureProvider` | Simple one-shot async data fetch |
| `StreamProvider` | Reactive real-time data |
| `StateProvider` | Simple mutable state (toggle, counter) |
| `NotifierProvider` | Complex synchronous state with methods |
| `AsyncNotifierProvider` | Complex async state with methods |

### Provider File Structure:

```dart
// providers/<feature>_providers.dart
final pinsProvider = AsyncNotifierProvider<PinsNotifier, List<Pin>>(
  PinsNotifier.new,
);

// providers/<feature>_notifier.dart  
class PinsNotifier extends AsyncNotifier<List<Pin>> {
  @override
  Future<List<Pin>> build() async {
    final useCase = ref.read(getPinsUseCaseProvider);
    final result = await useCase(GetPinsParams(page: 1));
    return result.fold((failure) => throw failure, (pins) => pins);
  }
}
```

## Dependency Injection with Riverpod

```dart
// Domain
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDatasource: ref.read(authRemoteDatasourceProvider),
    localDatasource: ref.read(authLocalDatasourceProvider),
  );
});

// UseCases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});
```

## Navigation — GoRouter

- Define routes in `lib/router/app_router.dart`
- Route names in `lib/router/route_names.dart`
- Use `ShellRoute` for bottom navigation persistence
- Use `GoRoute` for feature screens
- Pass parameters via `pathParameters` or `extra`
- Guard routes with `redirect` for auth state

## Feature Module Template

Every feature follows this exact structure:

```
features/<name>/
├── data/
│   ├── datasources/
│   │   ├── <name>_remote_datasource.dart
│   │   └── <name>_local_datasource.dart
│   ├── models/
│   │   └── <name>_model.dart
│   └── repositories/
│       └── <name>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <name>.dart
│   ├── repositories/
│   │   └── <name>_repository.dart
│   └── usecases/
│       └── <name>_usecase.dart
├── presentation/
│   ├── providers/
│   │   ├── <name>_providers.dart
│   │   └── <name>_notifier.dart
│   ├── views/
│   │   └── <name>_screen.dart
│   └── widgets/
└── docs/
    ├── README.md
    └── generatedSummaryMDFileByAi/
        └── AiSummary.md
```

## Import Rules

- NEVER use relative imports. Always use package imports:
  ```dart
  import 'package:pinterest/core/...';
  import 'package:pinterest/features/...';
  ```
- Group imports in order: dart → flutter → packages → project
- Each group separated by blank line

## Error Handling Pattern

Use `Either<Failure, T>` from `dartz` package:

```dart
// Repository contract
abstract class PinRepository {
  Future<Either<Failure, List<Pin>>> getPins({required int page});
}

// Repository implementation
@override
Future<Either<Failure, List<Pin>>> getPins({required int page}) async {
  try {
    final response = await remoteDatasource.getPins(page: page);
    return Right(response.map((m) => m.toEntity()).toList());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  }
}
```
