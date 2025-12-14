# Smart Social Platform Backend

A comprehensive, enterprise-grade social media platform backend built with Node.js, featuring microservices architecture, AI-powered content moderation, real-time communication, and advanced analytics.

## 🚀 Features

### Core Features
- **Microservices Architecture** - Scalable, maintainable service-oriented design
- **Real-time Communication** - WebSocket-based live messaging and notifications
- **AI-Powered Moderation** - Automated content filtering and safety measures
- **Advanced Analytics** - Comprehensive user and content performance tracking
- **Multi-channel Notifications** - Push, email, SMS, and in-app notifications
- **Intelligent Feed Algorithm** - Personalized content recommendation engine
- **Advanced Search** - Elasticsearch-powered search with AI suggestions
- **Live Streaming** - Real-time video broadcasting capabilities
- **E-commerce Integration** - Shopping features with payment processing
- **Content Management** - Posts, Stories, Reels with media processing

### Security Features
- **Two-Factor Authentication** - TOTP and SMS-based 2FA
- **Device Management** - Track and manage user devices
- **Rate Limiting** - Protect against abuse and DDoS attacks
- **JWT Authentication** - Secure token-based authentication
- **Data Encryption** - End-to-end encryption for sensitive data
- **Content Filtering** - AI-powered inappropriate content detection
- **Privacy Controls** - Granular privacy settings and data protection

### Business Features
- **Creator Monetization** - Revenue sharing and creator tools
- **Business Analytics** - Detailed insights for business accounts
- **Sponsored Content** - Advertising and promotion system
- **Shopping Integration** - Product tagging and e-commerce features
- **Live Commerce** - Live streaming with shopping capabilities
- **Subscription Management** - Premium features and subscriptions

## 🏗️ Architecture

### Microservices
- **API Gateway** - Service orchestration and load balancing
- **Auth Service** - Authentication and user management
- **Content Service** - Posts, media, and content management
- **Feed Service** - Personalized feed generation
- **Search Service** - Advanced search and discovery
- **Notification Service** - Multi-channel notifications
- **Analytics Service** - Data tracking and insights
- **Chat Service** - Real-time messaging
- **AI Moderation Service** - Content moderation and safety
- **Media Service** - File processing and CDN management
- **Live Service** - Live streaming and broadcasting

### Technology Stack
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Cache**: Redis for session and data caching
- **Search**: Elasticsearch for advanced search
- **Queue**: Bull for background job processing
- **Real-time**: Socket.IO for WebSocket communication
- **AI/ML**: TensorFlow.js, OpenAI GPT, Google Vision API
- **Cloud**: AWS S3, CloudFront, Firebase
- **Monitoring**: Prometheus, Grafana, Winston logging

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- MongoDB 6.0+
- Redis 7.0+
- Elasticsearch 8.0+
- Docker and Docker Compose (optional)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/your-org/smart-social-platform.git
cd smart-social-platform/backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Environment setup**
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Start services with Docker**
```bash
docker-compose up -d
```

5. **Start individual services**
```bash
# Start all services
npm run start:all

# Or start individual services
npm run start:auth
npm run start:content
npm run start:feed
npm run start:search
npm run start:notification
npm run start:analytics
npm run start:gateway
```

### Development Mode
```bash
# Start all services in development mode
npm run dev:all

# Start API Gateway only
npm run start:gateway
```

## 📁 Project Structure

```
backend/
├── api-gateway/              # API Gateway service
│   ├── src/
│   │   ├── middleware/       # Authentication, rate limiting
│   │   ├── routes/          # Route definitions
│   │   ├── utils/           # Service registry, load balancer
│   │   └── server.js        # Main gateway server
│   └── package.json
├── services/                 # Microservices
│   ├── auth-service/        # Authentication & user management
│   ├── content-service/     # Posts, media, content
│   ├── feed-service/        # Personalized feed generation
│   ├── search-service/      # Search and discovery
│   ├── notification-service/ # Multi-channel notifications
│   ├── analytics-service/   # Data tracking & insights
│   ├── chat-service/        # Real-time messaging
│   ├── ai-moderation-service/ # Content moderation
│   ├── media-service/       # File processing & CDN
│   └── live-service/        # Live streaming
├── infrastructure/          # Infrastructure as code
│   ├── docker-compose.yml   # Local development setup
│   ├── kubernetes/          # K8s deployment configs
│   └── terraform/           # Cloud infrastructure
└── docs/                    # Documentation
```

## 🔧 Configuration

### Environment Variables
Key environment variables (see `.env.example` for complete list):

```bash
# Core Configuration
NODE_ENV=development
PORT=8000
MONGODB_URI=mongodb://localhost:27017/smart_social_platform
REDIS_URL=redis://localhost:6379

# Security
JWT_SECRET=your-jwt-secret
JWT_REFRESH_SECRET=your-refresh-secret

# External Services
AWS_ACCESS_KEY_ID=your-aws-key
OPENAI_API_KEY=your-openai-key
FIREBASE_PROJECT_ID=your-firebase-project

# Feature Flags
ENABLE_AI_MODERATION=true
ENABLE_LIVE_STREAMING=true
ENABLE_SHOPPING=true
```

### Service Ports
- API Gateway: 8000
- Auth Service: 3001
- Content Service: 3003
- Feed Service: 3004
- AI Moderation: 3005
- Search Service: 3006
- Notification Service: 3007
- Analytics Service: 3008
- Media Service: 3009
- Chat Service: 3010
- Live Service: 3011

## 🔐 Authentication

### JWT Token Structure
```javascript
{
  "userId": "user_id",
  "username": "username",
  "role": "user|admin|moderator",
  "permissions": ["read", "write", "moderate"],
  "iat": 1234567890,
  "exp": 1234567890
}
```

### API Authentication
```bash
# Include JWT token in Authorization header
Authorization: Bearer <jwt_token>

# Or use API key for service-to-service communication
X-API-Key: <service_api_key>
```

## 📊 API Documentation

### Core Endpoints

#### Authentication
```bash
POST /api/auth/register          # User registration
POST /api/auth/login             # User login
POST /api/auth/refresh           # Refresh token
POST /api/auth/logout            # User logout
POST /api/auth/forgot-password   # Password reset
```

#### Content Management
```bash
GET    /api/content/posts        # Get posts
POST   /api/content/posts        # Create post
PUT    /api/content/posts/:id    # Update post
DELETE /api/content/posts/:id    # Delete post
POST   /api/content/posts/:id/like    # Like post
POST   /api/content/posts/:id/comment # Comment on post
```

#### Feed & Discovery
```bash
GET /api/feed/home              # Personalized home feed
GET /api/feed/explore           # Explore feed
GET /api/feed/reels             # Reels feed
GET /api/feed/trending          # Trending content
```

#### Search
```bash
GET /api/search                 # Universal search
GET /api/search/users           # Search users
GET /api/search/posts           # Search posts
GET /api/search/hashtags        # Search hashtags
GET /api/search/suggestions     # Search suggestions
```

#### Notifications
```bash
GET    /api/notifications       # Get notifications
POST   /api/notifications/read  # Mark as read
DELETE /api/notifications/:id   # Delete notification
PUT    /api/notifications/settings # Update settings
```

### Response Format
```javascript
{
  "success": true|false,
  "message": "Response message",
  "data": {
    // Response data
  },
  "pagination": {
    "page": 1,
    "limit": 20,
    "hasMore": true
  },
  "metadata": {
    // Additional metadata
  }
}
```

## 🔄 Real-time Features

### WebSocket Events
```javascript
// Client to Server
socket.emit('join_room', { roomId: 'user_123' });
socket.emit('send_message', { to: 'user_456', message: 'Hello!' });
socket.emit('typing_start', { chatId: 'chat_789' });

// Server to Client
socket.on('new_notification', (notification) => {});
socket.on('new_message', (message) => {});
socket.on('user_online', (userId) => {});
socket.on('live_stream_started', (streamData) => {});
```

## 🤖 AI Features

### Content Moderation
- **Toxicity Detection** - Identify harmful content
- **Spam Detection** - Filter spam and promotional content
- **Adult Content Detection** - NSFW content filtering
- **Violence Detection** - Identify violent content
- **Sentiment Analysis** - Analyze content sentiment

### Recommendation Engine
- **Collaborative Filtering** - User behavior-based recommendations
- **Content-Based Filtering** - Content similarity recommendations
- **Hybrid Approach** - Combined recommendation strategies
- **Real-time Learning** - Adaptive recommendation system

## 📈 Analytics & Monitoring

### Metrics Tracked
- **User Engagement** - Likes, comments, shares, time spent
- **Content Performance** - Reach, impressions, engagement rate
- **Business Metrics** - Revenue, conversions, ROI
- **System Performance** - Response times, error rates, uptime

### Monitoring Stack
- **Prometheus** - Metrics collection
- **Grafana** - Visualization and dashboards
- **Winston** - Application logging
- **Sentry** - Error tracking and monitoring

## 🚀 Deployment

### Docker Deployment
```bash
# Build and start all services
docker-compose up -d

# Scale specific services
docker-compose up -d --scale content-service=3

# View logs
docker-compose logs -f api-gateway
```

### Kubernetes Deployment
```bash
# Apply configurations
kubectl apply -f infrastructure/kubernetes/

# Check deployment status
kubectl get pods -n smart-social

# Scale services
kubectl scale deployment content-service --replicas=5
```

### Production Checklist
- [ ] Environment variables configured
- [ ] SSL certificates installed
- [ ] Database backups configured
- [ ] Monitoring and alerting setup
- [ ] Load balancer configured
- [ ] CDN setup for media files
- [ ] Security headers configured
- [ ] Rate limiting enabled
- [ ] Logging configured
- [ ] Health checks implemented

## 🧪 Testing

### Run Tests
```bash
# Run all tests
npm test

# Run service-specific tests
npm run test:auth
npm run test:content
npm run test:feed

# Run integration tests
npm run test:integration

# Generate coverage report
npm run test:coverage
```

### Test Structure
```
tests/
├── unit/           # Unit tests for individual functions
├── integration/    # Integration tests for API endpoints
├── e2e/           # End-to-end tests
└── fixtures/      # Test data and fixtures
```

## 🔧 Development

### Code Style
- **ESLint** - Code linting and formatting
- **Prettier** - Code formatting
- **Husky** - Git hooks for quality checks

### Development Workflow
1. Create feature branch
2. Implement changes with tests
3. Run linting and tests
4. Submit pull request
5. Code review and merge

### Debugging
```bash
# Debug specific service
DEBUG=smart-social:* npm run dev:auth

# Debug with Node.js inspector
node --inspect src/server.js
```

## 📚 Additional Resources

### Documentation
- [API Documentation](./docs/api.md)
- [Database Schema](./docs/database.md)
- [Architecture Guide](./docs/architecture.md)
- [Deployment Guide](./docs/deployment.md)

### Contributing
- [Contributing Guidelines](./CONTRIBUTING.md)
- [Code of Conduct](./CODE_OF_CONDUCT.md)
- [Security Policy](./SECURITY.md)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

For support and questions:
- Create an issue on GitHub
- Join our Discord community
- Email: support@smartsocial.com

---

**Smart Social Platform** - Building the future of social media with AI and advanced technology.