---
applyTo: "**/api/**,**/datasources/**,**/models/**"
---

# API Instructions — Pinterest Clone

## Primary API: Pexels API

- **Base URL**: `https://api.pexels.com/v1/`
- **Video URL**: `https://api.pexels.com/videos/`
- **Auth**: Bearer token in `Authorization` header
- **Rate Limit**: 200 requests/hour (free tier)
- **Docs**: https://www.pexels.com/api/documentation/

### Key Endpoints:

| Endpoint | Method | Description |
|---|---|---|
| `/v1/curated` | GET | Trending/curated photos (home feed) |
| `/v1/search` | GET | Search photos by query |
| `/v1/photos/:id` | GET | Get single photo detail |
| `/videos/popular` | GET | Popular videos |
| `/videos/search` | GET | Search videos |
| `/v1/collections` | GET | Photo collections (boards) |

### Query Parameters:

```
?page=1         # Pagination (1-indexed)
&per_page=20    # Items per page (max 80)
&query=nature   # Search query (for search endpoints)
```

### Response Shape (Photo):

```json
{
  "id": 2014422,
  "width": 3024,
  "height": 4032,
  "url": "https://www.pexels.com/photo/...",
  "photographer": "Joey Hare",
  "photographer_url": "https://www.pexels.com/@joey",
  "photographer_id": 680589,
  "avg_color": "#978E82",
  "src": {
    "original": "https://images.pexels.com/.../original.jpeg",
    "large2x": "https://images.pexels.com/.../large2x.jpeg",
    "large": "https://images.pexels.com/.../large.jpeg",
    "medium": "https://images.pexels.com/.../medium.jpeg",
    "small": "https://images.pexels.com/.../small.jpeg",
    "portrait": "https://images.pexels.com/.../portrait.jpeg",
    "landscape": "https://images.pexels.com/.../landscape.jpeg",
    "tiny": "https://images.pexels.com/.../tiny.jpeg"
  },
  "liked": false,
  "alt": "Brown Rocks During Golden Hour"
}
```

### Response Shape (Curated/Search List):

```json
{
  "page": 1,
  "per_page": 20,
  "total_results": 8000,
  "next_page": "https://api.pexels.com/v1/curated/?page=2&per_page=20",
  "photos": [...]
}
```

## Fallback API: Unsplash

- **Base URL**: `https://api.unsplash.com/`
- **Auth**: `Authorization: Client-ID YOUR_ACCESS_KEY`

## Dio Configuration

### ApiClient Setup:

```dart
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Authorization': Environment.pexelsApiKey,
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      AuthInterceptor(),
      RetryInterceptor(),
      CacheInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }
}
```

### API Interceptors:

1. **AuthInterceptor** — Attaches Bearer token to every request
2. **RetryInterceptor** — Retries failed requests (max 3 attempts, exponential backoff)
3. **CacheInterceptor** — Caches GET responses for offline support
4. **CurlLoggerInterceptor** — Logs cURL commands in debug mode only

### Error Response Handling:

Map API errors to domain failures:

```dart
ServerFailure      → 500+ status codes
UnauthorizedFailure → 401 status code
RateLimitFailure   → 429 status code (Too Many Requests)
NetworkFailure     → SocketException, TimeoutException
CacheFailure       → Local storage read/write errors
```

## Pagination Strategy

Use cursor-based pagination with Pexels `next_page` URL:

```dart
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int perPage;
  final int totalResults;
  final String? nextPage;
  final bool hasMore;
}
```

- Default page size: 20 items
- Prefetch next page when user scrolls to 80% of current list
- Cache first 2 pages for instant load on revisit

## Image Loading Strategy

Use `src` field variants based on context:

| Context | Image Variant | Reason |
|---|---|---|
| Grid thumbnail | `medium` (350px) | Fast load, good enough for grid |
| Pin detail (initial) | `large` (940px) | Quick load for detail view |
| Pin detail (full) | `large2x` or `original` | Progressive load for zoom |
| Search suggestions | `tiny` (130px) | Minimal bandwidth |
| Share preview | `small` (280px) | Compact preview |

## Model Conventions

```dart
@freezed
class PhotoModel with _$PhotoModel {
  const factory PhotoModel({
    required int id,
    required int width,
    required int height,
    required String url,
    required String photographer,
    @JsonKey(name: 'photographer_url') required String photographerUrl,
    @JsonKey(name: 'photographer_id') required int photographerId,
    @JsonKey(name: 'avg_color') required String avgColor,
    required PhotoSrcModel src,
    required bool liked,
    required String alt,
  }) = _PhotoModel;

  factory PhotoModel.fromJson(Map<String, dynamic> json) =>
      _$PhotoModelFromJson(json);
}
```

## API Key Security

- **NEVER** hardcode API keys in source code
- Store in `.env` file (git-ignored) using `flutter_dotenv`
- Access via `Environment.pexelsApiKey`
- For CI/CD, use environment variables or secrets manager
