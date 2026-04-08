---
applyTo: "**/*.dart"
---

# Responsive Design Instructions — Pinterest Clone

## ScreenUtil Setup

```dart
// Initialize in app.dart
ScreenUtilInit(
  designSize: const Size(375, 812),  // iPhone X design base
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) => child!,
  child: MaterialApp.router(...),
)
```

## Usage Conventions

```dart
// Dimensions → .w (width), .h (height)
Container(width: 100.w, height: 50.h)

// Font sizes → .sp
Text('Hello', style: TextStyle(fontSize: 14.sp))

// Border radius → .r
BorderRadius.circular(16.r)

// Padding/Margin → .w for horizontal, .h for vertical
EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)
```

## Breakpoint Strategy

```dart
// Mobile portrait (primary target)
// Width: 320 - 428 dp
// Grid: 2 columns

// Mobile landscape
// Width: 568 - 926 dp  
// Grid: 3 columns

// Tablet portrait
// Width: 600 - 834 dp
// Grid: 3 columns

// Tablet landscape
// Width: 1024 - 1194 dp
// Grid: 4-5 columns
```

## Responsive Grid Columns

```dart
int getGridColumns(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return 2;      // Phone
  if (width < 900) return 3;      // Small tablet
  if (width < 1200) return 4;     // Large tablet
  return 5;                        // Desktop
}
```

## Pinterest-Specific Responsive Rules

1. **Masonry grid**: Always 2 columns on phone, scale up on wider screens
2. **Bottom nav**: Fixed height, icon-only on phone
3. **Pin card**: Width adapts to column count, height based on aspect ratio
4. **Search bar**: Full width minus padding, camera icon at trailing edge
5. **Pin detail**: Full-screen image on phone, side panel on tablet
6. **Profile grid**: Same column logic as masonry, but equal-height cells

## Safe Area

```dart
// Always use SafeArea for:
// - Top of screens (status bar)
// - Bottom of screens (home indicator / nav gestures)
SafeArea(
  child: Scaffold(
    body: ...,
    bottomNavigationBar: ...,
  ),
)
```

## Text Scaling

- Use `.sp` for ALL font sizes
- Test with system font scaling at 1.0x, 1.3x, 2.0x
- Set `maxLines` + `overflow: TextOverflow.ellipsis` on text that could overflow
- Minimum touch target: 48x48 regardless of text scale
