# Pinterest Clone — Product Requirements Document (PRD)

**Version**: 1.0.0  
**Last Updated**: April 5, 2026  
**Author**: Development Team  
**Status**: In Development

---

## 1. Executive Summary

Build a pixel-perfect Pinterest mobile application clone using Flutter that demonstrates expert-level UI/UX replication, clean architecture patterns, and modern state management. The app connects to the Pexels API for image content and uses Clerk for authentication.

### Success Criteria

| Metric | Target |
|---|---|
| UI Accuracy vs Pinterest | ≥ 90% pixel-perfect |
| Performance (scroll FPS) | 60 FPS steady |
| Image load time (grid) | < 500ms (cached < 50ms) |
| App startup time | < 2 seconds (cold start) |
| Crash rate | < 0.1% |
| Test coverage | ≥ 70% |

---

## 2. Target Audience

- **Primary**: Assignment evaluators reviewing Flutter expertise
- **User Persona**: Pinterest user who browses, saves, and shares visual content

---

## 3. Feature Specifications

### 3.1 Authentication (Auth)

**Reference Screens**: Onboarding, Login, Sign-up

#### 3.1.1 Onboarding Screen
- Background: Animated collage of Pinterest-style images (grid with parallax scroll)
- Pinterest logo centered
- Tagline: "Create a life you love"
- Email address text field
- "Continue with Google" button (peach/salmon colored)
- Google One-Tap sign-in bottom sheet overlay

#### 3.1.2 Login Screen
- Top: X (close) button + "Log in" title
- Horizontal divider below title
- "Continue with Google" button with Google logo (rounded, outlined)
- "Or" divider text
- Email text field (rounded, outlined, autofill)
- Password text field with visibility toggle eye icon
- "Log in" button (Pinterest Red, rounded, full-width)
- "Forgotten password?" link below
- Loading state: red spinner + "Loading..." text below login button

#### 3.1.3 Auth Flow
- **Provider**: Clerk SDK (`clerk_flutter`)
- **Google Sign-In**: One-tap + fallback to standard flow
- **Session persistence**: Secure storage for auth tokens
- **Auth guard**: Redirect unauthenticated users to onboarding

---

### 3.2 Home Feed

**Reference Screens**: Home (For you), Masonry grid

#### 3.2.1 Home Screen
- Top-left: "For you" text (underlined, selected tab)
- Top-right: Sparkle/tune icon (feed preferences)
- Content: Infinite-scroll 2-column masonry grid
- Pull-to-refresh with native Flutter refresh indicator
- Bottom: Standard bottom navigation bar

#### 3.2.2 Masonry Grid
- **Layout**: 2-column staggered grid (`flutter_staggered_grid_view`)
- **Spacing**: 4px gaps between items (cross-axis and main-axis)
- **Pin Cards**:
  - Rounded corners: 16px
  - Dynamic height based on image aspect ratio (width/height from API)
  - Image fills card with `BoxFit.cover`
  - "..." overflow menu button at bottom-right of card
  - No text/caption below image in home feed
- **Loading**: Shimmer placeholders matching card shapes while fetching
- **Pagination**: Load next page when scrolled to 80% of current content
- **Cache**: First 2 pages cached for instant reload

#### 3.2.3 Long Press Action
- On long press of a pin card:
  - Dim background with dark overlay
  - Show pin image in center (slightly zoomed)
  - Four circular action buttons arranged around image:
    - Pin/Save (top-left)
    - Share link (top-center-left)
    - Visual search (top-center-right)
    - WhatsApp share (bottom-right)
  - "..." more options below
  - Haptic feedback on press

#### 3.2.4 Ad/Sponsored Carousel
- Full-width carousel with auto-scroll
- "Sponsored by [Brand]" label
- "Visit" button (rounded, outlined)
- Page dots indicator below carousel
- Swipe through cards

#### 3.2.5 Featured Boards Section
- "Explore featured boards" header
- "Bring your inspiration to life" subheader
- Horizontal scrollable board cards:
  - Board cover: 2x2 or collage layout of images
  - Board name (bold)
  - Creator name with verified badge
  - Pin count + time indicator

---

### 3.3 Search / Explore

**Reference Screens**: Search tab

#### 3.3.1 Search Screen
- Top: Search bar (rounded pill, "Search for ideas", camera icon right)
- Below: Category sections stacked vertically
- Each category section:
  - "Ideas for you" small label
  - Category title (bold, large: e.g., "Cool anime wallpapers")
  - Search icon button at right
  - Horizontal scrollable row of 4 images (equal height ~150px, tight spacing)
  - Images have no rounded corners in horizontal row

#### 3.3.2 Search Results
- On search submit: transition to results grid
- 2-column masonry grid (same as home feed)
- Filter chips at top (scrollable horizontal)
- Results include matched pins from Pexels search API

#### 3.3.3 Visual Search (Camera)
- Camera icon triggers visual search flow
- Take photo or pick from gallery
- Show visual search results in masonry grid

---

### 3.4 Pin Detail

**Reference Screens**: Pin detail view

#### 3.4.1 Pin Detail Screen
- Full-screen image at top (large variant from API)
- Back button (top-left, white circular button with shadow)
- "AI modified" label (bottom-left of image if applicable)
- Visual search button (bottom-right of image)

#### 3.4.2 Action Bar (below image)
- Heart icon + count (e.g., "63")
- Comment icon
- Share icon
- "..." more options
- "Save" button (Pinterest Red, rounded, right-aligned)

#### 3.4.3 Creator Info
- Creator avatar + name (bold)
- Below action bar

#### 3.4.4 More to Explore
- "More to explore" header
- 2-column masonry grid of related pins
- Infinite scroll for related content
- Uses Pexels search API with similar query terms

#### 3.4.5 Long Press Share Sheet
- Bottom sheet with:
  - Pin image preview (centered, dimmed background)
  - Circular action buttons on image (same as home long-press)
  - "Save or share Pin" text
  - Row of share options: Save, Collage, Message, WhatsApp
  - Second row: Telegram, Copy link, iMessage, More
  - Bottom toolbar: Profile pic, crop, edit, share icon

#### 3.4.6 Three-Dot Menu
- Appears as white pill-shaped dropdown from top-right
  - "..." at top
  - Additional option icons below
  - Music note icon at bottom

---

### 3.5 Create (Plus Tab)

**Reference**: Create new pin screen

- Tap "+" in bottom nav
- Options: Create Pin, Create Collage
- Pin creation: Image picker → add title, description, board selection
- Placeholder implementation sufficient (not primary evaluation criteria)

---

### 3.6 Messages

**Reference**: Messages/Chat tab

- Chat list with conversations
- Notification dot on tab when unread messages
- Placeholder implementation sufficient

---

### 3.7 Profile

**Reference Screens**: Profile tab

#### 3.7.1 Profile Screen
- Top: User avatar (left, large) + Settings gear icon (right)
- Tab bar: **Pins** | **Boards** | **Collages**
  - Underline indicator for selected tab
- Below tab bar:
  - Animated tooltip: "Introducing a new way to view all of your Pins"
  - Search bar for pins
  - Filter chips row: Grid icon, "Favourites" (star icon), "Created by you"
  - "+" add/create button at right

#### 3.7.2 Pins Tab
- 3-column equal-height grid (NOT masonry)
- Rounded corners on each image
- "[N] Pins saved" count at bottom

#### 3.7.3 Boards Tab
- Board cards with cover image collage
- Board name + pin count

#### 3.7.4 Collages Tab
- User-created collages (placeholder OK)

---

### 3.8 Bottom Navigation

- 5 tabs: Home, Search, Create(+), Messages, Profile
- Dark background (#1A1A1A)
- White icons when active, gray when inactive
- Home: Filled house icon
- Search: Magnifying glass
- Create: Plus icon (always outlined, centered)
- Messages: Chat bubble (with red notification dot)
- Profile: Person silhouette
- Tab persistence: Each tab maintains scroll position and navigation stack
- Implemented with GoRouter `ShellRoute` + `IndexedStack`

---

## 4. Technical Architecture

### 4.1 Architecture Pattern: Clean Architecture

```
┌─────────────────────────────────────────────┐
│             Presentation Layer              │
│  (ConsumerWidgets, Providers, Notifiers)    │
├─────────────────────────────────────────────┤
│               Domain Layer                  │
│  (Entities, Repository Contracts, UseCases) │
├─────────────────────────────────────────────┤
│                Data Layer                   │
│  (Models, DataSources, Repository Impls)    │
└─────────────────────────────────────────────┘
```

### 4.2 State Management: Riverpod

| Provider Type | Use Case |
|---|---|
| `Provider` | DI — inject repositories, usecases |
| `FutureProvider` | Simple async data fetch |
| `AsyncNotifierProvider` | Complex async state (pagination, mutations) |
| `NotifierProvider` | Complex sync state |
| `StateProvider` | Simple toggles (theme, tab index) |

### 4.3 Navigation: GoRouter

```
/                          # Redirect → /home or /onboarding
├── /onboarding            # Auth: Onboarding
├── /login                 # Auth: Login
├── /shell                 # ShellRoute (bottom nav)
│   ├── /home              # Home feed
│   ├── /search            # Search/Explore
│   ├── /create            # Create pin
│   ├── /messages          # Messages
│   └── /profile           # Profile
├── /pin/:id               # Pin detail (pushes over shell)
└── /settings              # Settings
```

### 4.4 API Integration

- **Primary**: Pexels API (https://api.pexels.com/v1/)
- **Fallback**: Unsplash API (if needed)
- **Networking**: Dio with interceptors
- **Caching**: Local cache for offline support

### 4.5 Required Packages

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^14.8.1
  dio: ^5.7.0
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  flutter_staggered_grid_view: ^0.7.0
  clerk_flutter: # latest
  flutter_screenutil: ^5.9.3
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  dartz: ^0.10.1
  flutter_dotenv: ^5.2.1
  equatable: ^2.0.7
  flutter_secure_storage: ^9.2.4

dev_dependencies:
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.3
  mockito: ^5.4.4
  mocktail: ^1.0.4
```

---

## 5. Screen-by-Screen Implementation Priority

### Phase 1: Foundation (Day 1)
- [ ] Project setup (packages, architecture scaffold)
- [ ] Design system (colors, typography, spacing)
- [ ] API client + interceptors
- [ ] Environment config (.env)
- [ ] GoRouter setup with shell route
- [ ] Bottom navigation

### Phase 2: Core Screens (Day 2-3)
- [ ] Home feed with masonry grid
- [ ] Pin card widget
- [ ] Shimmer loading states
- [ ] Image loading with CachedNetworkImage
- [ ] Pagination (infinite scroll)
- [ ] Pin detail screen
- [ ] Hero animation (grid → detail)

### Phase 3: Search & Auth (Day 3-4)
- [ ] Search screen with category sections
- [ ] Search results grid
- [ ] Onboarding screen
- [ ] Login screen with Google sign-in
- [ ] Auth flow + guards

### Phase 4: Profile & Polish (Day 4-5)
- [ ] Profile screen with tabs
- [ ] Saved pins grid
- [ ] Long-press share overlay
- [ ] Share bottom sheet
- [ ] Pull-to-refresh
- [ ] Animations & transitions
- [ ] Error states & empty states
- [ ] Performance optimization

### Phase 5: Final (Day 5)
- [ ] Create/Messages placeholder screens
- [ ] Build release APK
- [ ] Record walkthrough video
- [ ] Final polish & testing

---

## 6. Evaluation Alignment

| Criteria | Weight | Our Strategy |
|---|---|---|
| UI Accuracy | 35% | Pixel-perfect replication from screenshots, exact colors/spacing/animations |
| Code Architecture | 25% | Strict Clean Architecture + Riverpod + GoRouter |
| Code Quality | 20% | Linting, naming conventions, const usage, organized imports |
| Performance | 20% | 60 FPS scrolling, efficient image loading, caching, lazy loading |

---

## 7. Deliverables

1. **GitHub Repository**: Clean commit history with meaningful messages
2. **Android APK**: Release build
3. **iOS Walkthrough**: 5-10 minute video demonstrating all screens
4. **README**: Setup instructions, architecture overview, screenshots

---

## 8. Non-Functional Requirements

- **Offline Support**: Cache first 2 pages, show cached data when offline
- **Accessibility**: Semantic labels, min tap targets, font scaling
- **Internationalization**: English default, ARB-ready for future languages
- **Security**: No hardcoded keys, secure storage for tokens
- **Responsiveness**: Phone portrait primary, handle landscape + tablet gracefully
