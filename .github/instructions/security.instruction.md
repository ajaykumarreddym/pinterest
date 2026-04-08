---
applyTo: "**/security/**,**/auth/**,**/config/**"
---

# Security Instructions — Pinterest Clone

## API Key Management

- Store API keys in `.env` file (MUST be in `.gitignore`)
- Load via `flutter_dotenv` package
- Access through `Environment` class — NEVER direct string access
- CI/CD: Use platform secrets (GitHub Secrets, etc.)

```dart
// ✅ Correct
final apiKey = Environment.pexelsApiKey;

// ❌ NEVER
final apiKey = 'abc123xyz';
```

## .env File Structure

```env
PEXELS_API_KEY=your_key_here
CLERK_PUBLISHABLE_KEY=your_key_here
```

## Authentication Security

- Use Clerk SDK for auth — do NOT implement custom auth
- Store auth tokens in secure storage (`flutter_secure_storage`)
- Clear tokens on logout
- Validate token expiry before API calls
- Handle 401 responses with automatic re-auth flow

## Data Security

- No PII in logs (email, name, tokens)
- No sensitive data in `SharedPreferences` — use `SecureStorage`
- Sanitize all user inputs before API calls
- Use HTTPS only for all network requests

## Input Validation

- Validate email format client-side before login attempt
- Validate password strength requirements
- Sanitize search queries (prevent injection)
- Limit input lengths on text fields

## Secure Storage Hierarchy

| Data Type | Storage | Example |
|---|---|---|
| Auth tokens | SecureStorage | JWT, refresh token |
| User preferences | SharedPreferences | Theme, language |
| Cached API data | Hive | Photos, search history |
| API keys | .env file | Pexels key |

## Dependencies Audit

- Keep dependencies up to date
- Review package permissions
- Use trusted packages with high pub.dev scores
- Pin major versions to avoid breaking changes
