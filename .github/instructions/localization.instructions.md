---
applyTo: "**/l10n/**,**/lang/**,**/constants/default_local_strings.dart"
---

# Localization Instructions — Pinterest Clone

## Strategy

Use Flutter's built-in `intl` package with ARB files for internationalization.

## File Structure

```
lib/l10n/
├── app_en.arb           # English (source)
└── app_localizations.dart  # Generated class
assets/lang/
├── en.json              # Fallback strings
```

## String Usage

```dart
// Access localized strings
final l10n = AppLocalizations.of(context)!;
Text(l10n.searchForIdeas)  // "Search for ideas"
```

## Key Pinterest Strings

```json
{
  "appName": "Pinterest",
  "searchForIdeas": "Search for ideas",
  "forYou": "For you",
  "home": "Home",
  "search": "Search",
  "create": "Create",
  "messages": "Messages",
  "profile": "Profile",
  "save": "Save",
  "saved": "Saved",
  "logIn": "Log in",
  "signUp": "Sign up",
  "continueWithGoogle": "Continue with Google",
  "or": "Or",
  "emailAddress": "Email address",
  "password": "Password",
  "forgottenPassword": "Forgotten password?",
  "createALifeYouLove": "Create a life\nyou love",
  "moreToExplore": "More to explore",
  "ideasForYou": "Ideas for you",
  "exploreFeaturedBoards": "Explore featured boards",
  "bringYourInspirationToLife": "Bring your inspiration to life",
  "pins": "Pins",
  "boards": "Boards",
  "collages": "Collages",
  "favourites": "Favourites",
  "createdByYou": "Created by you",
  "pinsSaved": "{count} Pins saved",
  "saveOrSharePin": "Save or share Pin",
  "loading": "Loading...",
  "noInternetConnection": "No internet connection",
  "somethingWentWrong": "Something went wrong",
  "retry": "Retry",
  "aiModified": "AI modified",
  "visit": "Visit",
  "sponsoredBy": "Sponsored by {sponsor}"
}
```

## Rules

1. **NEVER** hardcode user-facing strings in widgets
2. Use ARB message format for plurals and parameters
3. Keep keys in `camelCase`
4. Group related keys with common prefixes
5. Provide descriptions for translators in ARB files
6. Default language: English
