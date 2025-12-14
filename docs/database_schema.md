# Smart Social Platform - Database Schema

## Firestore Collections

### Users Collection
```javascript
{
  "id": "user_123",
  "email": "user@example.com",
  "username": "john_doe",
  "displayName": "John Doe",
  "profileImage": "https://cdn.example.com/profiles/user_123.jpg",
  "bio": "Passionate learner and creator",
  "isVerified": false,
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "settings": {
    "dailyTimeLimit": 900, // seconds
    "reelsLimit": 10,
    "notificationsEnabled": true,
    "darkMode": false,
    "language": "en"
  },
  "stats": {
    "postsCount": 25,
    "followersCount": 150,
    "followingCount": 89,
    "totalLikes": 1250
  },
  "timeTracking": {
    "dailyUsage": 420, // seconds today
    "weeklyUsage": 2100,
    "reelsWatchedToday": 3,
    "lastActiveAt": "2024-01-01T12:00:00Z"
  }
}
```

### Posts Collection
```javascript
{
  "id": "post_456",
  "userId": "user_123",
  "content": "Just learned something amazing about AI!",
  "mediaUrls": [
    "https://cdn.example.com/posts/post_456_1.jpg",
    "https://cdn.example.com/posts/post_456_2.jpg"
  ],
  "mediaType": "image", // image, video, carousel
  "hashtags": ["#AI", "#Learning", "#Technology"],
  "mentions": ["@jane_doe"],
  "location": {
    "name": "San Francisco, CA",
    "coordinates": [37.7749, -122.4194]
  },
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:00:00Z",
  "isActive": true,
  "engagement": {
    "likes": 42,
    "comments": 8,
    "shares": 3,
    "saves": 12,
    "views": 156
  },
  "aiAnalysis": {
    "qualityScore": 8.5,
    "isApproved": true,
    "categories": ["education", "technology"],
    "sentiment": "positive",
    "educationalValue": 9.2,
    "originalityScore": 8.8,
    "moderationFlags": []
  }
}
```

### Stories Collection
```javascript
{
  "id": "story_789",
  "userId": "user_123",
  "mediaUrl": "https://cdn.example.com/stories/story_789.mp4",
  "mediaType": "video",
  "duration": 15, // seconds
  "createdAt": "2024-01-01T14:00:00Z",
  "expiresAt": "2024-01-02T14:00:00Z",
  "isActive": true,
  "viewers": ["user_456", "user_789"],
  "viewCount": 25,
  "aiAnalysis": {
    "qualityScore": 7.8,
    "isApproved": true,
    "moderationFlags": []
  }
}
```

### Reels Collection
```javascript
{
  "id": "reel_101",
  "userId": "user_123",
  "videoUrl": "https://cdn.example.com/reels/reel_101.mp4",
  "thumbnailUrl": "https://cdn.example.com/reels/reel_101_thumb.jpg",
  "duration": 30,
  "caption": "Quick productivity tip!",
  "hashtags": ["#productivity", "#tips"],
  "music": {
    "trackId": "track_123",
    "title": "Upbeat Background",
    "artist": "Artist Name"
  },
  "createdAt": "2024-01-01T16:00:00Z",
  "isActive": true,
  "engagement": {
    "likes": 89,
    "comments": 15,
    "shares": 7,
    "views": 342
  },
  "aiAnalysis": {
    "qualityScore": 9.1,
    "isApproved": true,
    "categories": ["productivity", "education"],
    "engagementPrediction": 8.5
  }
}
```

### Comments Collection
```javascript
{
  "id": "comment_202",
  "postId": "post_456",
  "userId": "user_456",
  "content": "Great insight! Thanks for sharing.",
  "parentCommentId": null, // for replies
  "createdAt": "2024-01-01T11:00:00Z",
  "isActive": true,
  "likes": 5,
  "aiAnalysis": {
    "sentiment": "positive",
    "isSpam": false,
    "toxicityScore": 0.1
  }
}
```

### Notifications Collection
```javascript
{
  "id": "notif_303",
  "userId": "user_123",
  "type": "like", // like, comment, follow, mention, time_limit
  "title": "New like on your post",
  "message": "Jane Doe liked your post",
  "data": {
    "postId": "post_456",
    "fromUserId": "user_456"
  },
  "isRead": false,
  "createdAt": "2024-01-01T12:30:00Z",
  "expiresAt": "2024-01-08T12:30:00Z"
}
```

### Analytics Collection
```javascript
{
  "id": "analytics_404",
  "userId": "user_123",
  "date": "2024-01-01",
  "metrics": {
    "timeSpent": 420, // seconds
    "postsViewed": 25,
    "reelsWatched": 3,
    "likesGiven": 8,
    "commentsPosted": 2,
    "postsCreated": 1,
    "profileViews": 12
  },
  "aiInsights": {
    "productivityScore": 8.2,
    "engagementQuality": "high",
    "recommendedBreakTime": "14:30:00",
    "suggestions": [
      "Great job staying within your time limit!",
      "Try the 5-minute growth mode for focused learning"
    ]
  }
}
```

## MongoDB Collections (for Analytics & Logs)

### User Sessions
```javascript
{
  "_id": ObjectId("..."),
  "userId": "user_123",
  "sessionId": "session_abc123",
  "startTime": ISODate("2024-01-01T10:00:00Z"),
  "endTime": ISODate("2024-01-01T10:15:00Z"),
  "duration": 900, // seconds
  "activities": [
    {
      "type": "post_view",
      "postId": "post_456",
      "timestamp": ISODate("2024-01-01T10:02:00Z"),
      "duration": 15
    },
    {
      "type": "reel_watch",
      "reelId": "reel_101",
      "timestamp": ISODate("2024-01-01T10:05:00Z"),
      "duration": 30,
      "completed": true
    }
  ],
  "deviceInfo": {
    "platform": "iOS",
    "version": "17.0",
    "model": "iPhone 14"
  }
}
```

### Content Moderation Logs
```javascript
{
  "_id": ObjectId("..."),
  "contentId": "post_456",
  "contentType": "post",
  "userId": "user_123",
  "moderationResult": {
    "qualityScore": 8.5,
    "isApproved": true,
    "reasons": [],
    "flags": [],
    "categories": ["education", "technology"]
  },
  "aiModel": "content-analyzer-v2.1",
  "processingTime": 1.2, // seconds
  "timestamp": ISODate("2024-01-01T10:00:00Z")
}
```

## Redis Cache Structure

### Feed Cache
```
Key: "feed:user_123"
Value: JSON array of post IDs with scores
TTL: 300 seconds (5 minutes)

Key: "post:post_456"
Value: Complete post object
TTL: 3600 seconds (1 hour)
```

### User Session Cache
```
Key: "session:user_123"
Value: {
  "dailyUsage": 420,
  "reelsWatched": 3,
  "lastActivity": "2024-01-01T12:00:00Z"
}
TTL: 86400 seconds (24 hours)
```

## ElasticSearch Indexes

### Posts Index
```javascript
{
  "mappings": {
    "properties": {
      "id": { "type": "keyword" },
      "userId": { "type": "keyword" },
      "content": { 
        "type": "text",
        "analyzer": "standard"
      },
      "hashtags": { "type": "keyword" },
      "categories": { "type": "keyword" },
      "qualityScore": { "type": "float" },
      "createdAt": { "type": "date" },
      "engagement": {
        "properties": {
          "likes": { "type": "integer" },
          "comments": { "type": "integer" },
          "views": { "type": "integer" }
        }
      }
    }
  }
}
```

### Users Index
```javascript
{
  "mappings": {
    "properties": {
      "id": { "type": "keyword" },
      "username": { "type": "keyword" },
      "displayName": { 
        "type": "text",
        "analyzer": "standard"
      },
      "bio": { 
        "type": "text",
        "analyzer": "standard"
      },
      "isVerified": { "type": "boolean" },
      "stats": {
        "properties": {
          "followersCount": { "type": "integer" },
          "postsCount": { "type": "integer" }
        }
      }
    }
  }
}
```