---
applyTo: "**/design_systems/**,**/theme/**,**/ui/**"
---

# Design System Instructions — Pinterest Clone

## Pinterest Brand Design Tokens

### Color Palette

```dart
// Primary Colors
static const pinterestRed = Color(0xFFE60023);      // Pinterest signature red
static const pinterestRedDark = Color(0xFFAD081B);   // Pressed/dark red
static const pinterestRedLight = Color(0xFFFFEBEE);  // Light red background

// Background Colors (Dark Theme - Primary)
static const backgroundDark = Color(0xFF000000);       // Pure black background
static const surfaceDark = Color(0xFF1A1A1A);          // Card/elevated surfaces
static const surfaceVariantDark = Color(0xFF2A2A2A);   // Input fields, chips

// Background Colors (Light Theme)
static const backgroundLight = Color(0xFFFFFFFF);
static const surfaceLight = Color(0xFFF5F5F5);
static const surfaceVariantLight = Color(0xFFEEEEEE);

// Text Colors
static const textPrimaryDark = Color(0xFFFFFFFF);
static const textSecondaryDark = Color(0xFFB0B0B0);
static const textTertiaryDark = Color(0xFF787878);
static const textPrimaryLight = Color(0xFF111111);
static const textSecondaryLight = Color(0xFF767676);

// UI Element Colors
static const dividerDark = Color(0xFF2A2A2A);
static const dividerLight = Color(0xFFE0E0E0);
static const iconDefault = Color(0xFFB0B0B0);
static const iconActive = Color(0xFFFFFFFF);

// Overlay Colors
static const overlayDark = Color(0x80000000);     // 50% black
static const overlayLight = Color(0x33000000);    // 20% black

// Special Colors
static const googleBlue = Color(0xFF4285F4);      // Google sign-in
static const saveButtonRed = Color(0xFFE60023);    // Save button (same as primary)
static const linkBlue = Color(0xFF0076D3);         // Clickable links
```

### Typography

Pinterest uses a custom font. Use **Inter** or **SF Pro** as closest free alternatives.

```dart
// Heading Styles
static const h1 = TextStyle(
  fontSize: 28, fontWeight: FontWeight.w700, height: 1.2,
);
static const h2 = TextStyle(
  fontSize: 22, fontWeight: FontWeight.w700, height: 1.25,
);
static const h3 = TextStyle(
  fontSize: 18, fontWeight: FontWeight.w600, height: 1.3,
);

// Body Styles
static const bodyLarge = TextStyle(
  fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
);
static const bodyMedium = TextStyle(
  fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
);
static const bodySmall = TextStyle(
  fontSize: 12, fontWeight: FontWeight.w400, height: 1.4,
);

// Label Styles
static const labelLarge = TextStyle(
  fontSize: 16, fontWeight: FontWeight.w600, height: 1.2,
);
static const labelMedium = TextStyle(
  fontSize: 14, fontWeight: FontWeight.w600, height: 1.2,
);
static const labelSmall = TextStyle(
  fontSize: 12, fontWeight: FontWeight.w600, height: 1.2,
);

// Caption
static const caption = TextStyle(
  fontSize: 11, fontWeight: FontWeight.w400, height: 1.3,
);
```

### Border Radius

```dart
static const radiusNone = 0.0;
static const radiusXs = 4.0;
static const radiusSm = 8.0;
static const radiusMd = 12.0;
static const radiusLg = 16.0;
static const radiusXl = 24.0;
static const radiusFull = 999.0;    // Pill shape

// Pinterest-specific
static const pinCardRadius = 16.0;   // Pin card corners
static const buttonRadius = 24.0;    // Rounded buttons
static const searchBarRadius = 24.0; // Search bar
static const chipRadius = 20.0;      // Filter chips
static const avatarRadius = 999.0;   // Circle avatars
static const bottomSheetRadius = 16.0;
```

### Spacing Scale

```dart
static const space0 = 0.0;
static const space1 = 2.0;
static const space2 = 4.0;
static const space3 = 8.0;
static const space4 = 12.0;
static const space5 = 16.0;
static const space6 = 20.0;
static const space7 = 24.0;
static const space8 = 32.0;
static const space9 = 40.0;
static const space10 = 48.0;
static const space11 = 56.0;
static const space12 = 64.0;

// Grid spacing
static const gridGutter = 4.0;       // Gap between masonry items
static const gridPadding = 4.0;      // Edge padding for grid
```

### Shadows

```dart
// Card shadow (subtle)
static const cardShadow = [
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  ),
];

// Elevated shadow (bottom sheets, modals)
static const elevatedShadow = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, -4),
  ),
];

// No shadow on dark theme (Pinterest uses flat dark cards)
```

### Dimensions

```dart
// Bottom Navigation
static const bottomNavHeight = 56.0;
static const bottomNavIconSize = 24.0;

// App Bar
static const appBarHeight = 56.0;

// Search Bar
static const searchBarHeight = 48.0;

// Pin Grid
static const pinGridColumns = 2;
static const pinGridCrossAxisSpacing = 4.0;
static const pinGridMainAxisSpacing = 4.0;

// Pin Card
static const pinCardMinHeight = 150.0;

// Bottom Sheet
static const bottomSheetMaxHeight = 0.9;  // 90% screen height

// FAB / Create Button
static const fabSize = 48.0;

// Avatar
static const avatarSmall = 24.0;
static const avatarMedium = 32.0;
static const avatarLarge = 48.0;
static const avatarXl = 64.0;
```

## Atomic Design System (UI Components)

Organize shared widgets using Atomic Design:

```
core/ui/
├── atoms/           # Smallest units — buttons, icons, text, avatar
├── molecules/       # Combinations — search bar, pin card, chip group
├── organisms/       # Complex sections — masonry grid, nav bar, header
├── templates/       # Page layouts — scaffold templates
└── screens/         # Full page shells (loading, error, empty states)
```

### Key Pinterest UI Components:

**Atoms:**
- `PinImage` — CachedNetworkImage with shimmer placeholder & avg_color
- `PinAvatar` — Circular avatar with fallback initials
- `PinIcon` — Consistent icon wrapper (size, color)
- `PinButton` — Primary (red), secondary (dark), text variants
- `PinChip` — Rounded toggle chip for filters/categories

**Molecules:**
- `PinCard` — Image + optional overlay + rounded corners (the core masonry item)
- `SearchBar` — TextField with search icon + camera icon
- `UserRow` — Avatar + name + follow button
- `ActionBar` — Like/Comment/Share/Save row
- `CategoryRow` — Horizontal scrolling category chips

**Organisms:**
- `MasonryGrid` — Staggered grid using `flutter_staggered_grid_view`
- `BottomNavBar` — 5-tab navigation (Home, Search, Create, Messages, Profile)
- `PinDetailSheet` — Pin detail modal/page with image + actions
- `ShareSheet` — Bottom sheet with share options
- `AdCarousel` — Sponsored content auto-play carousel

## Theme Configuration

Support **both light and dark** themes. Pinterest defaults to dark:

```dart
ThemeData buildPinterestTheme({required bool isDark}) {
  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
    colorScheme: isDark ? _darkColorScheme : _lightColorScheme,
    textTheme: _buildTextTheme(isDark),
    // ...
  );
}
```

## Animation Durations

```dart
static const instant = Duration(milliseconds: 100);
static const fast = Duration(milliseconds: 200);
static const normal = Duration(milliseconds: 300);
static const slow = Duration(milliseconds: 500);
static const pageTransition = Duration(milliseconds: 350);
```

## Image Placeholder Strategy

1. Show `shimmer` effect while loading (matches Pinterest's shimmer)
2. Use photo's `avg_color` as background color during load
3. Fade in image over 200ms once loaded
4. On error, show subtle broken-image icon
