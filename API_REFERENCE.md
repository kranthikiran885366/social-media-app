# API Reference

Complete API documentation for Smart Social Platform backend services.

## Base URLs

### Development
```
API Gateway: http://localhost:8000
Auth Service: http://localhost:3001
Content Service: http://localhost:3003
Feed Service: http://localhost:3004
```

### Production
```
API Gateway: https://api.yourdomain.com
```

## Authentication

All authenticated endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

### Get JWT Token

```http
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user123",
    "email": "user@example.com",
    "username": "johndoe",
    "name": "John Doe"
  }
}
```

---

## Auth Service API

### Register

Create a new user account.

```http
POST /api/auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "SecurePassword123!",
  "confirmPassword": "SecurePassword123!",
  "name": "John Doe"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "Account created successfully",
  "user": {
    "id": "user123",
    "email": "user@example.com",
    "username": "johndoe"
  }
}
```

### Login

Authenticate user and receive JWT token.

```http
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response:** `200 OK`

### Logout

Invalidate current session token.

```http
POST /api/auth/logout
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Refresh Token

Get a new JWT token using refresh token.

```http
POST /api/auth/refresh
```

**Request Body:**
```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response:** `200 OK`

---

## Content Service API

### Create Post

Create a new post with text, images, or video.

```http
POST /api/content/posts
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "caption": "Beautiful sunset! 🌅",
  "mediaUrls": [
    "https://cdn.example.com/image1.jpg",
    "https://cdn.example.com/image2.jpg"
  ],
  "mediaType": "image",
  "tags": ["sunset", "nature"],
  "location": {
    "name": "Venice Beach",
    "coordinates": {
      "lat": 33.9850,
      "lng": -118.4695
    }
  }
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "post": {
    "id": "post123",
    "userId": "user123",
    "caption": "Beautiful sunset! 🌅",
    "mediaUrls": ["..."],
    "likes": 0,
    "comments": 0,
    "createdAt": "2025-12-14T10:30:00Z"
  }
}
```

### Get Post

Retrieve a specific post by ID.

```http
GET /api/content/posts/:postId
```

**Response:** `200 OK`

### Update Post

Update an existing post.

```http
PUT /api/content/posts/:postId
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "caption": "Updated caption"
}
```

**Response:** `200 OK`

### Delete Post

Delete a post.

```http
DELETE /api/content/posts/:postId
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Like Post

Like or unlike a post.

```http
POST /api/content/posts/:postId/like
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Comment on Post

Add a comment to a post.

```http
POST /api/content/posts/:postId/comments
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "text": "Great photo! 👍"
}
```

**Response:** `201 Created`

### Get Comments

Get all comments for a post.

```http
GET /api/content/posts/:postId/comments?page=1&limit=20
```

**Query Parameters:**
- `page` (optional): Page number, default 1
- `limit` (optional): Items per page, default 20

**Response:** `200 OK`

---

## Feed Service API

### Get Home Feed

Get personalized feed for the authenticated user.

```http
GET /api/feed/home?page=1&limit=10
```

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page` (optional): Page number, default 1
- `limit` (optional): Items per page, default 10

**Response:** `200 OK`
```json
{
  "success": true,
  "posts": [
    {
      "id": "post123",
      "user": {
        "id": "user456",
        "username": "janedoe",
        "avatar": "https://..."
      },
      "caption": "...",
      "mediaUrls": ["..."],
      "likes": 42,
      "comments": 5,
      "createdAt": "2025-12-14T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 150,
    "hasNext": true
  }
}
```

### Get Explore Feed

Get trending and recommended content.

```http
GET /api/feed/explore?category=all
```

**Query Parameters:**
- `category` (optional): all, trending, reels, photos, videos

**Response:** `200 OK`

---

## User Service API

### Get User Profile

Get user profile information.

```http
GET /api/users/:userId
```

**Response:** `200 OK`
```json
{
  "success": true,
  "user": {
    "id": "user123",
    "username": "johndoe",
    "name": "John Doe",
    "bio": "Photographer | Traveler 📸",
    "avatar": "https://...",
    "followers": 1234,
    "following": 567,
    "posts": 89,
    "isFollowing": false,
    "isPrivate": false
  }
}
```

### Update Profile

Update user profile information.

```http
PUT /api/users/profile
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "John Doe Updated",
  "bio": "New bio text",
  "avatar": "https://...",
  "website": "https://johndoe.com"
}
```

**Response:** `200 OK`

### Follow User

Follow a user.

```http
POST /api/users/:userId/follow
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Unfollow User

Unfollow a user.

```http
DELETE /api/users/:userId/follow
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Get Followers

Get list of user's followers.

```http
GET /api/users/:userId/followers?page=1&limit=20
```

**Response:** `200 OK`

### Get Following

Get list of users that the user is following.

```http
GET /api/users/:userId/following?page=1&limit=20
```

**Response:** `200 OK`

---

## Search Service API

### Search Users

Search for users by username or name.

```http
GET /api/search/users?q=john&limit=10
```

**Query Parameters:**
- `q` (required): Search query
- `limit` (optional): Max results, default 10

**Response:** `200 OK`

### Search Posts

Search for posts by caption or tags.

```http
GET /api/search/posts?q=sunset&limit=20
```

**Response:** `200 OK`

### Search Tags

Search for hashtags.

```http
GET /api/search/tags?q=nature
```

**Response:** `200 OK`

---

## Notification Service API

### Get Notifications

Get user's notifications.

```http
GET /api/notifications?page=1&unread=false
```

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page` (optional): Page number
- `unread` (optional): Filter unread only

**Response:** `200 OK`

### Mark as Read

Mark notification as read.

```http
PUT /api/notifications/:notificationId/read
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Mark All as Read

Mark all notifications as read.

```http
PUT /api/notifications/read-all
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

---

## Chat Service API

### Get Conversations

Get user's chat conversations.

```http
GET /api/chat/conversations
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Get Messages

Get messages in a conversation.

```http
GET /api/chat/conversations/:conversationId/messages?page=1
```

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`

### Send Message

Send a new message.

```http
POST /api/chat/conversations/:conversationId/messages
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "text": "Hello! How are you?",
  "mediaUrl": null
}
```

**Response:** `201 Created`

---

## WebSocket Events

### Connect to Chat

```javascript
const socket = io('wss://api.yourdomain.com', {
  auth: {
    token: 'your_jwt_token'
  }
});

// Join conversation
socket.emit('join_conversation', { conversationId: 'conv123' });

// Send message
socket.emit('send_message', {
  conversationId: 'conv123',
  text: 'Hello!'
});

// Receive message
socket.on('new_message', (message) => {
  console.log('New message:', message);
});

// Typing indicator
socket.emit('typing', { conversationId: 'conv123' });
socket.on('user_typing', (data) => {
  console.log(`${data.username} is typing...`);
});
```

---

## Error Responses

All errors follow this format:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

### Common Error Codes

| Code | Status | Description |
|------|--------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or missing authentication token |
| `FORBIDDEN` | 403 | User doesn't have permission |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 400 | Invalid input data |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `SERVER_ERROR` | 500 | Internal server error |

---

## Rate Limits

- **Anonymous requests**: 50 requests per minute
- **Authenticated requests**: 100 requests per minute
- **File uploads**: 10 per minute

Rate limit headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1702564800
```

---

## Pagination

Paginated endpoints return:

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": false
  }
}
```

---

## File Upload

For uploading media files:

```http
POST /api/media/upload
```

**Headers:** 
- `Authorization: Bearer <token>`
- `Content-Type: multipart/form-data`

**Form Data:**
- `file`: The file to upload
- `type`: "image" or "video"

**Response:** `200 OK`
```json
{
  "success": true,
  "url": "https://cdn.example.com/uploads/image123.jpg",
  "thumbnail": "https://cdn.example.com/uploads/thumb_image123.jpg"
}
```

---

**Last Updated**: December 14, 2025
**API Version**: 1.0
