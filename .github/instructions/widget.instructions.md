---
applyTo: "**/ui/**,**/widgets/**,**/views/**"
---

# Widget Instructions — Pinterest Clone

## Widget Principles

1. **Composition over inheritance** — Build complex UIs by composing small widgets
2. **Single responsibility** — Each widget does ONE thing well
3. **Const constructors** — Always use `const` when possible
4. **Keys** — Use `ValueKey` for list items that reorder (masonry grid pins)
5. **Extract, don't nest** — If nesting > 3 levels deep, extract to separate widget

## Widget Naming

```dart
// Screens (full page) → suffix: Screen
class HomeScreen extends ConsumerWidget {}
class LoginScreen extends ConsumerStatefulWidget {}

// Reusable widgets → descriptive noun
class PinCard extends StatelessWidget {}
class MasonryFeed extends ConsumerWidget {}

// Feature-specific widgets → prefix: feature context
class SearchBarWidget extends StatelessWidget {}
class ProfileHeader extends StatelessWidget {}
```

## ConsumerWidget vs ConsumerStatefulWidget

```dart
// Use ConsumerWidget (stateless) when:
// - No local state (TextEditingController, AnimationController, etc)
// - Only reading/watching Riverpod providers
class PinCard extends ConsumerWidget {
  const PinCard({super.key, required this.photo});
  final Photo photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) { ... }
}

// Use ConsumerStatefulWidget when:
// - Need local controllers (ScrollController, AnimationController)
// - Need initState/dispose lifecycle
// - Need TickerProviderStateMixin for animations
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}
```

## Pinterest-Specific Widget Patterns

### PinCard (Masonry Grid Item)

```dart
class PinCard extends StatelessWidget {
  // Must handle:
  // 1. Dynamic height based on image aspect ratio
  // 2. Shimmer placeholder during load
  // 3. avg_color background while loading
  // 4. Rounded corners (16px)
  // 5. Long-press → share menu overlay with circular action buttons
  // 6. Tap → navigate to pin detail
  // 7. Optional "..." menu button overlay
  // 8. Hero animation tag for detail transition
}
```

### MasonryGrid

```dart
// Use MasonryGridView.count from flutter_staggered_grid_view
MasonryGridView.count(
  crossAxisCount: 2,
  mainAxisSpacing: 4.0,
  crossAxisSpacing: 4.0,
  itemCount: pins.length,
  itemBuilder: (context, index) => PinCard(photo: pins[index]),
)
```

### BottomNavBar

Pinterest has 5 tabs:
1. **Home** (house icon) — filled when active
2. **Search** (magnifying glass) — filled when active
3. **Create** (plus icon) — always outlined, center
4. **Messages** (chat bubble) — with notification dot
5. **Profile** (person icon) — filled when active

```dart
// Use GoRouter ShellRoute with IndexedStack for tab persistence
// Each tab maintains its own navigation stack
// Bottom nav is dark gray (#1A1A1A) with white icons
```

### SearchBar

```dart
// Pinterest search bar specifics:
// - Rounded pill shape (24px radius)
// - Left: search icon
// - Right: camera icon (visual search)  
// - Placeholder: "Search for ideas"
// - Dark surface background (#2A2A2A)
// - On tap: expand with animation, show search history
```

## Image Loading Pattern

```dart
CachedNetworkImage(
  imageUrl: photo.src.medium,
  placeholder: (_, __) => Shimmer.fromColors(
    baseColor: Color(int.parse(photo.avgColor.replaceFirst('#', '0xFF'))),
    highlightColor: Color(int.parse(photo.avgColor.replaceFirst('#', '0xFF'))).withOpacity(0.5),
    child: Container(color: Colors.white),
  ),
  errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
  fit: BoxFit.cover,
  fadeInDuration: const Duration(milliseconds: 200),
)
```

## Animation Guidelines

| Interaction | Animation | Duration |
|---|---|---|
| Pin card tap → detail | Hero + fade | 300ms |
| Long press pin → options | Scale up + fade in circles | 200ms |
| Tab switch | Instant (no animation) | 0ms |
| Pull to refresh | Overscroll + spinner | Native |
| Search expand | Slide up + fade | 250ms |
| Bottom sheet | Slide up from bottom | 300ms |
| Pin save | Scale bounce + checkmark | 200ms |
| Share sheet open | Slide up + overlay fade | 300ms |

## Shimmer Loading States

Every content area must have a shimmer placeholder:

```dart
// Grid shimmer: 2-column boxes with varying heights
// Detail shimmer: Full-width image placeholder + text lines
// Profile shimmer: Circle avatar + horizontal content blocks
// Search shimmer: Pill-shaped chips + grid below
```

## Accessibility

- All images: `semanticLabel` from `alt` text
- All buttons: proper `tooltip`
- All interactive items: minimum 48x48 tap target
- Support system font scaling (use `sp` via ScreenUtil)
- Support screen readers (Semantics widgets)

## Performance Rules

- Use `const` widgets wherever possible
- Use `RepaintBoundary` around animation-heavy widgets
- Use `AutomaticKeepAliveClientMixin` for tab content
- Lazy load images in off-screen grid items
- Use `cacheExtent` on scroll views for smoother scrolling
- NEVER rebuild entire list — use proper keys
