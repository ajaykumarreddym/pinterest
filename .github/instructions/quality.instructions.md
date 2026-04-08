---
applyTo: "**/*.dart"
---

# Code Quality Instructions — Pinterest Clone

## Dart Code Style

- Follow official Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use `flutter_lints` (already configured in `analysis_options.yaml`)
- Max line length: 80 characters
- Use trailing commas for multi-line arguments (enables auto-formatting)

## Naming Conventions

```dart
// Classes, enums, typedefs → PascalCase
class PinCard {}
enum LoadingState { initial, loading, loaded, error }

// Variables, parameters, functions → camelCase
final photoList = <Photo>[];
void fetchPhotos() {}

// Constants → camelCase (NOT SCREAMING_CASE)
const primaryRed = Color(0xFFE60023);
const maxRetries = 3;

// Private → prefix with underscore
String _cachedToken = '';
void _handleTap() {}

// Providers → camelCase + Provider suffix contextually clear
final pinsProvider = AsyncNotifierProvider<PinsNotifier, List<Pin>>(...);
final authStateProvider = StateProvider<AuthState>(...);

// Files → snake_case
// pin_card.dart, auth_repository_impl.dart
```

## Import Organization

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

// 4. Project imports
import 'package:pinterest/core/...';
import 'package:pinterest/features/...';
```

**ALWAYS use package imports, NEVER relative imports.**

## Code Documentation

- Public APIs: one-line `///` doc comment (NOT `//`)
- Complex logic: inline `//` comments explaining WHY, not WHAT
- No obvious comments: `// increment counter` on `counter++`
- Document all provider definitions with usage context

## Const Usage

```dart
// Use const EVERYWHERE possible
const EdgeInsets.all(16)           // ✅
EdgeInsets.all(16)                 // ❌

const SizedBox(height: 8)         // ✅
SizedBox(height: 8)               // ❌

const Text('Hello')               // ✅ (if no dynamic data)
```

## File Size Limits

- Widgets: < 200 lines per file
- Providers/Notifiers: < 150 lines per file
- Models: < 100 lines per file
- If exceeding → split into smaller components

## Testing Requirements

```
test/
├── features/
│   ├── <feature>/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       └── views/
│   └── ...
└── core/
    ├── services/
    └── utils/
```

### Test Naming

```dart
// test file: <name>_test.dart
// test group: describe the class/function
// test name: 'should <expected behavior> when <condition>'

group('PinsNotifier', () {
  test('should emit loaded state when getPins succeeds', () {});
  test('should emit error state when getPins fails', () {});
});
```

## Git Commit Convention

```
feat: add masonry grid to home feed
fix: fix image loading flicker on scroll
refactor: extract PinCard to separate widget
style: apply consistent spacing to search screen
test: add unit tests for home repository
docs: update API documentation
chore: update dependencies
```

## Performance Checklist

- [ ] All list items have unique `key`
- [ ] Heavy widgets wrapped in `RepaintBoundary`
- [ ] Images use appropriate size variant (not `original` in grids)
- [ ] Scroll views have `cacheExtent` set
- [ ] No unnecessary `setState` or provider rebuilds
- [ ] No `print()` statements (use `AppLogger`)
- [ ] Tab content uses `AutomaticKeepAliveClientMixin`
- [ ] Animations use `AnimatedBuilder` or `ImplicitlyAnimated*` widgets
