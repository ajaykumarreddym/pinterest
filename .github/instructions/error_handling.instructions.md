---
applyTo: "**/*.dart"
---

# Error Handling Instructions — Pinterest Clone

## Error Hierarchy

```
BaseException (abstract)
├── ServerException          → API returned error status
├── NetworkException         → No internet / timeout
├── CacheException           → Local storage failure
├── UnauthorizedException    → 401 / Token expired
├── RateLimitException       → 429 / Too many requests
├── ValidationException      → Client-side input validation
└── UnknownException         → Unexpected/unhandled errors
```

## Failure Hierarchy (Domain Layer)

```
Failure (abstract, extends Equatable)
├── ServerFailure
├── NetworkFailure
├── CacheFailure
├── UnauthorizedFailure
├── RateLimitFailure
├── ValidationFailure
└── UnknownFailure
```

## Pattern: Either<Failure, T>

Every repository method returns `Future<Either<Failure, T>>`:

```dart
// Domain (contract)
abstract class PinRepository {
  Future<Either<Failure, List<Pin>>> getPins({required int page});
  Future<Either<Failure, Pin>> getPinById({required int id});
}

// Data (implementation)
@override
Future<Either<Failure, List<Pin>>> getPins({required int page}) async {
  try {
    final response = await remoteDatasource.getPins(page: page);
    final pins = response.map((m) => m.toEntity()).toList();
    await localDatasource.cachePins(response);
    return Right(pins);
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } on NetworkException {
    // Fallback to cache
    try {
      final cached = await localDatasource.getCachedPins();
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException {
      return Left(const NetworkFailure(message: 'No internet connection'));
    }
  }
}
```

## Presentation Layer Error Handling

### In Riverpod Providers:

```dart
class PinsNotifier extends AsyncNotifier<List<Pin>> {
  @override
  Future<List<Pin>> build() async {
    final result = await ref.read(getPinsUseCaseProvider)(
      GetPinsParams(page: 1),
    );
    return result.fold(
      (failure) => throw failure,  // Riverpod catches this → AsyncError
      (pins) => pins,
    );
  }
}
```

### In UI (Consuming AsyncValue):

```dart
ref.watch(pinsProvider).when(
  data: (pins) => MasonryGrid(pins: pins),
  loading: () => const ShimmerGrid(),
  error: (error, stack) => ErrorView(
    failure: error as Failure,
    onRetry: () => ref.invalidate(pinsProvider),
  ),
);
```

## Network Error Recovery

1. **No Internet**: Show cached data if available, else show offline state
2. **Timeout**: Auto-retry once, then show retry button
3. **Rate Limit (429)**: Show rate limit message, queue retry after `Retry-After` header
4. **Server Error (5xx)**: Show generic error with retry button
5. **Auth Error (401)**: Trigger re-authentication flow

## UI Error States

Every screen must handle these states:

```dart
enum ViewState { initial, loading, loaded, error, empty }
```

- **Loading**: Shimmer placeholders matching content layout
- **Error**: Centered message + retry button (Pinterest style: subtle, not alarming)
- **Empty**: Friendly illustration/message (e.g., "Nothing here yet")
- **No Internet**: Offline banner at top + cached content below

## Logging

- Log all API errors with request details (URL, method, status)
- Log cache misses/hits in debug mode
- NEVER log sensitive data (tokens, passwords, PII)
- Use `AppLogger` wrapper (not raw `print()`)

## Global Error Boundary

Wrap app in error boundary for uncaught exceptions:

```dart
void main() {
  FlutterError.onError = (details) {
    AppLogger.error('Flutter Error', error: details.exception, stack: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Platform Error', error: error, stack: stack);
    return true;
  };

  runApp(const ProviderScope(child: PinterestApp()));
}
```
