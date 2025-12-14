# Smart Social Platform - API Documentation

## Base URL
```
Production: https://api.smartsocial.com
Development: http://localhost:8000
```

## Authentication
All authenticated endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <access_token>
```

## Auth Service API (Port 3001)

### POST /api/auth/register
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "john_doe",
  "password": "securePassword123"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "username": "john_doe",
      "isVerified": false,
      "dailyTimeLimit": 900,
      "reelsLimit": 10
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

### POST /api/auth/login
Authenticate user and get access tokens.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "user_123",
      "email": "user@example.com",
      "username": "john_doe",
      "isVerified": false,
      "dailyTimeLimit": 900,
      "reelsLimit": 10
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

### POST /api/auth/refresh
Refresh access token using refresh token.

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

## Content Service API (Port 3003)

### POST /api/content/posts
Create a new post with AI moderation.

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Request Body (Form Data):**
```
content: "Just learned something amazing about AI!"
hashtags: ["#AI", "#Learning"]
media: [File1, File2] // Optional media files
location: "San Francisco, CA" // Optional
```

**Response (201):**
```json
{
  "success": true,
  "message": "Post created successfully",
  "data": {
    "post": {
      "id": "post_456",
      "userId": "user_123",
      "content": "Just learned something amazing about AI!",
      "mediaUrls": ["https://cdn.example.com/posts/post_456_1.jpg"],
      "hashtags": ["#AI", "#Learning"],
      "createdAt": "2024-01-01T10:00:00Z",
      "aiAnalysis": {
        "qualityScore": 8.5,
        "isApproved": true,
        "categories": ["education", "technology"]
      }
    }
  }
}
```

### GET /api/content/posts/:postId
Get a specific post by ID.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "post": {
      "id": "post_456",
      "userId": "user_123",
      "username": "john_doe",
      "userAvatar": "https://cdn.example.com/avatars/user_123.jpg",
      "content": "Just learned something amazing about AI!",
      "mediaUrls": ["https://cdn.example.com/posts/post_456_1.jpg"],
      "hashtags": ["#AI", "#Learning"],
      "createdAt": "2024-01-01T10:00:00Z",
      "engagement": {
        "likes": 42,
        "comments": 8,
        "shares": 3,
        "saves": 12
      },
      "aiAnalysis": {
        "qualityScore": 8.5,
        "categories": ["education", "technology"]
      }
    }
  }
}
```

### POST /api/content/posts/:postId/like
Like or unlike a post.

**Response (200):**
```json
{
  "success": true,
  "message": "Post liked successfully",
  "data": {
    "liked": true,
    "likesCount": 43
  }
}
```

## Feed Service API (Port 3004)

### GET /api/feed/home
Get personalized home feed with AI-curated content.

**Query Parameters:**
```
page: 1 (default)
limit: 20 (default, max 50)
quality_threshold: 6.0 (default)
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "post_456",
        "userId": "user_123",
        "username": "john_doe",
        "userAvatar": "https://cdn.example.com/avatars/user_123.jpg",
        "content": "Just learned something amazing about AI!",
        "mediaUrls": ["https://cdn.example.com/posts/post_456_1.jpg"],
        "createdAt": "2024-01-01T10:00:00Z",
        "engagement": {
          "likes": 42,
          "comments": 8
        },
        "aiAnalysis": {
          "qualityScore": 8.5,
          "categories": ["education", "technology"]
        }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "hasNext": true
    },
    "feedMetrics": {
      "averageQualityScore": 7.8,
      "totalTimeEstimate": 300
    }
  }
}
```

### GET /api/feed/reels
Get AI-curated reels feed with time limits.

**Query Parameters:**
```
page: 1 (default)
limit: 10 (default, max 20)
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "reels": [
      {
        "id": "reel_101",
        "userId": "user_123",
        "username": "john_doe",
        "userAvatar": "https://cdn.example.com/avatars/user_123.jpg",
        "videoUrl": "https://cdn.example.com/reels/reel_101.mp4",
        "thumbnailUrl": "https://cdn.example.com/reels/reel_101_thumb.jpg",
        "duration": 30,
        "caption": "Quick productivity tip!",
        "createdAt": "2024-01-01T16:00:00Z",
        "engagement": {
          "likes": 89,
          "comments": 15,
          "views": 342
        },
        "aiAnalysis": {
          "qualityScore": 9.1,
          "categories": ["productivity", "education"]
        }
      }
    ],
    "userLimits": {
      "dailyReelsLimit": 10,
      "reelsWatchedToday": 3,
      "remainingReels": 7
    }
  }
}
```

## AI Moderation Service API (Port 3005)

### POST /api/moderation/analyze
Analyze content for quality and appropriateness.

**Request Body:**
```json
{
  "content": "Just learned something amazing about AI!",
  "mediaUrls": ["https://example.com/image.jpg"],
  "contentType": "post",
  "userId": "user_123"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "analysis": {
      "qualityScore": 8.5,
      "isApproved": true,
      "reasons": [],
      "metrics": {
        "textQuality": 8.2,
        "sentiment": 7.8,
        "educationalValue": 9.1,
        "originalityScore": 8.8,
        "spamScore": 0.1
      },
      "categories": ["education", "technology"],
      "processingTime": 1.2
    }
  }
}
```

### GET /api/moderation/content/:contentId/quality
Get quality metrics for existing content.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "qualityMetrics": {
      "relevanceScore": 8.5,
      "engagementPotential": 7.2,
      "educationalValue": 6.8,
      "originalityScore": 9.1,
      "overallScore": 8.5
    },
    "recommendations": [
      "Content shows high educational value",
      "Consider adding more visual elements",
      "Great originality score!"
    ]
  }
}
```

## Analytics Service API (Port 3008)

### GET /api/analytics/user/time-tracking
Get user's time tracking and usage analytics.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "today": {
      "timeSpent": 420,
      "timeLimit": 900,
      "remainingTime": 480,
      "reelsWatched": 3,
      "reelsLimit": 10,
      "postsViewed": 25
    },
    "weekly": {
      "totalTime": 2100,
      "averageDaily": 300,
      "mostActiveDay": "Wednesday",
      "productivityScore": 8.2
    },
    "insights": [
      {
        "type": "achievement",
        "message": "Great job! You've reduced your daily usage by 40% this week.",
        "icon": "trending_up"
      },
      {
        "type": "suggestion",
        "message": "Try the '5-minute Growth Mode' for focused learning.",
        "icon": "lightbulb"
      }
    ]
  }
}
```

### POST /api/analytics/track-activity
Track user activity for analytics.

**Request Body:**
```json
{
  "activityType": "post_view",
  "contentId": "post_456",
  "duration": 15,
  "metadata": {
    "scrollDepth": 0.8,
    "interacted": true
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Activity tracked successfully"
}
```

## Search Service API (Port 3009)

### GET /api/search/posts
Search posts with AI-powered relevance ranking.

**Query Parameters:**
```
q: "AI learning" (search query)
category: "education" (optional)
quality_min: 6.0 (optional)
page: 1 (default)
limit: 20 (default)
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": "post_456",
        "content": "Just learned something amazing about AI!",
        "username": "john_doe",
        "qualityScore": 8.5,
        "relevanceScore": 9.2,
        "createdAt": "2024-01-01T10:00:00Z"
      }
    ],
    "suggestions": ["machine learning", "artificial intelligence", "deep learning"],
    "totalResults": 1250
  }
}
```

### GET /api/search/users
Search users by username or display name.

**Query Parameters:**
```
q: "john" (search query)
verified_only: false (optional)
page: 1 (default)
limit: 20 (default)
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "user_123",
        "username": "john_doe",
        "displayName": "John Doe",
        "avatar": "https://cdn.example.com/avatars/user_123.jpg",
        "isVerified": false,
        "followersCount": 150,
        "bio": "Passionate learner and creator"
      }
    ],
    "totalResults": 45
  }
}
```

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Invalid or expired token"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Insufficient permissions"
}
```

### 429 Too Many Requests
```json
{
  "success": false,
  "message": "Rate limit exceeded. Try again later.",
  "retryAfter": 60
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error"
}
```

## Rate Limits

- Authentication endpoints: 5 requests per minute per IP
- Content creation: 10 posts per hour per user
- Feed requests: 100 requests per hour per user
- Search requests: 50 requests per minute per user
- Analytics tracking: 1000 requests per hour per user