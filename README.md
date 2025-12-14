# Smart Social Platform 🚀

A comprehensive, feature-rich social media platform built with Flutter and Node.js microservices architecture. Experience Instagram-like features with advanced AI moderation, real-time messaging, stories, reels, shopping, and more.

![Flutter](https://img.shields.io/badge/Flutter-3.38.3-02569B?logo=flutter)
![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?logo=node.js)
![MongoDB](https://img.shields.io/badge/MongoDB-6.0-47A248?logo=mongodb)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

## ✨ Features

### 📱 Core Features
- **Authentication & Authorization** - Secure login/register with JWT, social login (Google, Apple)
- **User Profiles** - Customizable profiles with bio, avatar, follower/following system
- **Feed System** - Personalized timeline with posts, likes, comments, shares
- **Stories** - 24-hour ephemeral content with views tracking
- **Reels** - Short-form video content with music integration
- **Direct Messaging** - Real-time 1-on-1 and group chats
- **Notifications** - Real-time push notifications for all interactions

### 🎨 Content Creation
- **Post Creation** - Photos, videos, carousels with filters and editing
- **AR Filters** - Augmented reality face filters and effects
- **Music Integration** - Add trending audio to reels and stories
- **Live Streaming** - Go live with real-time viewer interaction
- **Shopping Tags** - Tag products in posts for e-commerce

### 🤖 Advanced Features
- **AI Content Moderation** - Automatic detection of inappropriate content
- **Smart Recommendations** - ML-powered content suggestions
- **Advanced Search** - Search users, hashtags, locations, and content
- **Analytics Dashboard** - Creator insights and engagement metrics
- **Business Tools** - Professional accounts with advertising capabilities
- **Monetization** - Creator fund and sponsored content support

### 🔒 Security & Privacy
- **Two-Factor Authentication** - Enhanced account security
- **Privacy Controls** - Granular content visibility settings
- **Block & Report** - User safety and content reporting
- **Data Encryption** - End-to-end encryption for messages

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       Frontend (Flutter)                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │   Auth   │ │   Feed   │ │   Chat   │ │  Profile │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                      API Gateway                             │
│                   (Express.js + Nginx)                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                    Microservices Layer                       │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐  │
│  │  Auth  │ │Content │ │  Feed  │ │  Chat  │ │ Search │  │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘  │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐  │
│  │ Notify │ │Analytics││  AI    │ │Creator │ │ Recom. │  │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘  │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ MongoDB  │ │  Redis   │ │  RabbitMQ│ │   AWS S3 │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK**: 3.38.3 or higher
- **Node.js**: 18.x or higher
- **MongoDB**: 6.0 or higher
- **Redis**: 7.0 or higher
- **Docker** (optional, for containerized deployment)

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Run on Android emulator
flutter run -d android

# Run on iOS simulator (macOS only)
flutter run -d ios
```

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your configuration

# Start all services
docker-compose up -d

# Or run individual service
cd services/auth-service
npm install
npm run dev
```

### Database Setup

```bash
# Start MongoDB
docker run -d -p 27017:27017 --name mongodb mongo:6.0

# Start Redis
docker run -d -p 6379:6379 --name redis redis:7.0

# Run database migrations (from backend directory)
npm run migrate
```

## 📁 Project Structure

```
smart_social_platform/
├── frontend/                    # Flutter application
│   ├── lib/
│   │   ├── core/               # Core utilities, theme, routes
│   │   ├── features/           # Feature modules (auth, feed, chat, etc.)
│   │   ├── models/             # Data models
│   │   ├── services/           # API services
│   │   ├── widgets/            # Reusable widgets
│   │   └── main.dart           # App entry point
│   ├── assets/                 # Images, fonts, animations
│   ├── test/                   # Unit & widget tests
│   └── pubspec.yaml            # Flutter dependencies
│
├── backend/                     # Node.js backend
│   ├── api-gateway/            # API Gateway service
│   ├── services/               # Microservices
│   │   ├── auth-service/       # Authentication
│   │   ├── content-service/    # Posts & media
│   │   ├── feed-service/       # Timeline & feed
│   │   ├── chat-service/       # Messaging
│   │   ├── notification-service/
│   │   ├── analytics-service/
│   │   ├── search-service/
│   │   ├── ai-moderation-service/
│   │   ├── creator-service/
│   │   └── recommendation-service/
│   ├── infrastructure/         # Docker, monitoring
│   └── docker-compose.yml
│
├── docs/                        # Documentation
│   ├── api_documentation.md    # API endpoints
│   ├── architecture.md         # System architecture
│   └── database_schema.md      # Database design
│
├── infrastructure/              # Infrastructure as Code
│   ├── kubernetes/             # K8s manifests
│   ├── terraform/              # AWS provisioning
│   └── aws-cloudformation/     # CloudFormation templates
│
├── CONTRIBUTING.md             # Contribution guidelines
├── LICENSE                     # MIT License
├── TECH_STACK.md              # Technology documentation
└── README.md                   # This file
```

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.38.3** - Cross-platform UI framework
- **flutter_bloc 8.1.3** - State management
- **go_router 12.1.1** - Navigation
- **dio 5.4.0** - HTTP client
- **cached_network_image** - Image optimization
- **lottie** - Animations

### Backend
- **Node.js 18.x** - Runtime
- **Express.js** - Web framework
- **MongoDB** - Primary database
- **Redis** - Caching & sessions
- **Socket.io** - Real-time communication
- **RabbitMQ** - Message queue
- **JWT** - Authentication

### Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Orchestration
- **AWS** - Cloud provider (EC2, S3, RDS, CloudFront)
- **Terraform** - Infrastructure as Code
- **GitHub Actions** - CI/CD

[See full tech stack documentation →](TECH_STACK.md)

## 📚 Documentation

- [API Documentation](docs/api_documentation.md) - REST API endpoints and usage
- [Architecture Guide](docs/architecture.md) - System design and patterns
- [Database Schema](docs/database_schema.md) - Data models and relationships
- [Contributing Guide](CONTRIBUTING.md) - How to contribute
- [Tech Stack Details](TECH_STACK.md) - Complete technology breakdown

## 🧪 Testing

### Frontend Tests
```bash
cd frontend

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/features/auth/auth_test.dart
```

### Backend Tests
```bash
cd backend

# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific service tests
cd services/auth-service
npm test
```

## 🚢 Deployment

### Docker Deployment
```bash
# Build and run all services
docker-compose up -d

# Scale specific service
docker-compose up -d --scale content-service=3

# View logs
docker-compose logs -f
```

### Kubernetes Deployment
```bash
# Apply configurations
kubectl apply -f infrastructure/kubernetes/

# Check status
kubectl get pods -n social-platform

# Scale deployment
kubectl scale deployment content-service --replicas=5
```

### AWS Deployment
```bash
# Initialize Terraform
cd infrastructure/terraform
terraform init

# Plan infrastructure
terraform plan

# Apply infrastructure
terraform apply
```

## 🔧 Configuration

### Environment Variables

Create `.env` files in respective directories:

**Backend `.env`:**
```env
NODE_ENV=development
PORT=3000

# Database
MONGODB_URI=mongodb://localhost:27017/social_platform
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# AWS
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=your-bucket-name
AWS_REGION=us-east-1

# Services
AUTH_SERVICE_URL=http://localhost:3001
CONTENT_SERVICE_URL=http://localhost:3002
FEED_SERVICE_URL=http://localhost:3003
```

**Frontend:**
Flutter configuration is in `lib/core/constants/app_constants.dart`

## 📊 Monitoring & Analytics

- **Prometheus** - Metrics collection
- **Grafana** - Visualization dashboards
- **ELK Stack** - Centralized logging
- **AWS CloudWatch** - Cloud monitoring

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: [kranthikiran885366](https://github.com/kranthikiran885366)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/kranthikiran885366/social-media-app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/kranthikiran885366/social-media-app/discussions)

## 🗺️ Roadmap

- [x] Core authentication & profiles
- [x] Feed & post creation
- [x] Stories & reels
- [x] Direct messaging
- [x] AI content moderation
- [ ] Live streaming
- [ ] AR filters implementation
- [ ] Advanced analytics dashboard
- [ ] Blockchain-based creator monetization
- [ ] WebRTC video calling
- [ ] Progressive Web App (PWA)

## ⭐ Star History

If you find this project useful, please consider giving it a star!

---

Made with ❤️ by the Smart Social Platform Team
