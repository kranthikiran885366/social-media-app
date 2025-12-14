# Deployment Guide

This guide covers deployment strategies for Smart Social Platform across different environments.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Development Deployment](#development-deployment)
- [Staging Deployment](#staging-deployment)
- [Production Deployment](#production-deployment)
- [Docker Deployment](#docker-deployment)
- [Kubernetes Deployment](#kubernetes-deployment)
- [AWS Deployment](#aws-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring](#monitoring)
- [Rollback Strategy](#rollback-strategy)

## Prerequisites

### Required Tools
```bash
# Flutter SDK
flutter --version  # 3.38.3 or higher

# Node.js & npm
node --version     # 18.x or higher
npm --version      # 9.x or higher

# Docker
docker --version   # 20.x or higher
docker-compose --version

# Kubernetes (optional)
kubectl version    # 1.25 or higher
helm version       # 3.x or higher

# Terraform (optional)
terraform --version # 1.5 or higher

# AWS CLI (for AWS deployment)
aws --version      # 2.x or higher
```

### Access Requirements
- GitHub repository access
- Docker Hub or container registry credentials
- AWS account (for cloud deployment)
- Domain name and SSL certificates
- MongoDB Atlas or database server
- Redis instance

## Environment Setup

### Environment Variables

Create `.env` files for each environment:

#### Development `.env`
```env
NODE_ENV=development
PORT=3000

# Database
MONGODB_URI=mongodb://localhost:27017/social_platform_dev
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=dev-secret-key-change-in-production
JWT_EXPIRES_IN=7d

# AWS (Development)
AWS_ACCESS_KEY_ID=your-dev-access-key
AWS_SECRET_ACCESS_KEY=your-dev-secret-key
AWS_S3_BUCKET=social-platform-dev
AWS_REGION=us-east-1

# Services URLs
AUTH_SERVICE_URL=http://localhost:3001
CONTENT_SERVICE_URL=http://localhost:3003
FEED_SERVICE_URL=http://localhost:3004
CHAT_SERVICE_URL=http://localhost:3010
NOTIFICATION_SERVICE_URL=http://localhost:3007

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8080

# Rate Limiting
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100
```

#### Production `.env`
```env
NODE_ENV=production
PORT=3000

# Database (Use MongoDB Atlas)
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/social_platform?retryWrites=true&w=majority
REDIS_URL=redis://production-redis:6379

# JWT (Strong secret)
JWT_SECRET=<GENERATE_STRONG_SECRET_256_BITS>
JWT_EXPIRES_IN=7d

# AWS (Production)
AWS_ACCESS_KEY_ID=<PRODUCTION_ACCESS_KEY>
AWS_SECRET_ACCESS_KEY=<PRODUCTION_SECRET_KEY>
AWS_S3_BUCKET=social-platform-prod
AWS_REGION=us-east-1
AWS_CLOUDFRONT_DOMAIN=d1234567890.cloudfront.net

# Services URLs (Internal)
AUTH_SERVICE_URL=http://auth-service:3001
CONTENT_SERVICE_URL=http://content-service:3003
FEED_SERVICE_URL=http://feed-service:3004
CHAT_SERVICE_URL=http://chat-service:3010
NOTIFICATION_SERVICE_URL=http://notification-service:3007

# CORS
CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com

# Rate Limiting
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100

# Monitoring
SENTRY_DSN=<YOUR_SENTRY_DSN>
NEW_RELIC_LICENSE_KEY=<YOUR_NEW_RELIC_KEY>
```

## Development Deployment

### Frontend (Flutter)

```bash
cd frontend

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS (macOS only)
flutter run -d ios

# Build for production
flutter build web --release
flutter build apk --release
flutter build ios --release
```

### Backend (Node.js)

```bash
cd backend

# Install dependencies
npm install

# Start MongoDB and Redis
docker-compose up -d mongodb redis

# Start all services in development mode
npm run dev

# Or start individual services
cd services/auth-service
npm install
npm run dev
```

## Staging Deployment

### Using Docker Compose

```bash
# Build all services
docker-compose build

# Start staging environment
docker-compose -f docker-compose.staging.yml up -d

# View logs
docker-compose logs -f

# Scale specific service
docker-compose up -d --scale content-service=3

# Stop all services
docker-compose down
```

## Production Deployment

### Pre-deployment Checklist

- [ ] All tests passing
- [ ] Code review completed
- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] SSL certificates installed
- [ ] Monitoring setup
- [ ] Backup strategy in place
- [ ] Rollback plan documented

## Docker Deployment

### Build Docker Images

```bash
# Backend services
cd backend

# Build API Gateway
docker build -t social-platform/api-gateway:latest ./api-gateway

# Build Auth Service
docker build -t social-platform/auth-service:latest ./services/auth-service

# Build all services
for service in services/*; do
  docker build -t social-platform/$(basename $service):latest ./$service
done

# Push to registry
docker tag social-platform/api-gateway:latest registry.example.com/api-gateway:v1.0.0
docker push registry.example.com/api-gateway:v1.0.0
```

### Frontend Docker Image

```bash
cd frontend

# Build Flutter web
flutter build web --release

# Create Dockerfile
cat > Dockerfile << EOF
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Build and push
docker build -t social-platform/frontend:latest .
docker push registry.example.com/frontend:v1.0.0
```

### Production Docker Compose

```yaml
# docker-compose.production.yml
version: '3.8'

services:
  api-gateway:
    image: registry.example.com/api-gateway:v1.0.0
    ports:
      - "8000:8000"
    environment:
      - NODE_ENV=production
    env_file:
      - .env.production
    restart: always
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1'
          memory: 1G

  auth-service:
    image: registry.example.com/auth-service:v1.0.0
    environment:
      - NODE_ENV=production
    env_file:
      - .env.production
    restart: always
    deploy:
      replicas: 2

  # ... other services
```

## Kubernetes Deployment

### Prerequisites

```bash
# Create namespace
kubectl create namespace social-platform

# Create secrets
kubectl create secret generic app-secrets \
  --from-env-file=.env.production \
  -n social-platform

# Create ConfigMap
kubectl create configmap app-config \
  --from-file=config/ \
  -n social-platform
```

### Deploy Services

```bash
# Apply all configurations
kubectl apply -f infrastructure/kubernetes/ -n social-platform

# Check deployment status
kubectl get pods -n social-platform
kubectl get services -n social-platform

# Check logs
kubectl logs -f deployment/auth-service -n social-platform

# Scale deployment
kubectl scale deployment auth-service --replicas=5 -n social-platform
```

### Example Deployment Manifest

```yaml
# infrastructure/kubernetes/auth-service.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
  namespace: social-platform
spec:
  replicas: 3
  selector:
    matchLabels:
      app: auth-service
  template:
    metadata:
      labels:
        app: auth-service
    spec:
      containers:
      - name: auth-service
        image: registry.example.com/auth-service:v1.0.0
        ports:
        - containerPort: 3001
        env:
        - name: NODE_ENV
          value: "production"
        envFrom:
        - secretRef:
            name: app-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3001
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3001
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: auth-service
  namespace: social-platform
spec:
  selector:
    app: auth-service
  ports:
  - port: 3001
    targetPort: 3001
  type: ClusterIP
```

## AWS Deployment

### Using Terraform

```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Get outputs
terraform output
```

### Manual AWS Setup

#### 1. VPC and Networking
```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create subnets
aws ec2 create-subnet --vpc-id vpc-xxx --cidr-block 10.0.1.0/24
aws ec2 create-subnet --vpc-id vpc-xxx --cidr-block 10.0.2.0/24

# Create Internet Gateway
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway --vpc-id vpc-xxx --internet-gateway-id igw-xxx
```

#### 2. ECS Cluster
```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name social-platform-prod

# Register task definitions
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Create services
aws ecs create-service \
  --cluster social-platform-prod \
  --service-name auth-service \
  --task-definition auth-service:1 \
  --desired-count 3 \
  --launch-type FARGATE
```

#### 3. Load Balancer
```bash
# Create Application Load Balancer
aws elbv2 create-load-balancer \
  --name social-platform-alb \
  --subnets subnet-xxx subnet-yyy \
  --security-groups sg-xxx

# Create target groups
aws elbv2 create-target-group \
  --name auth-service-tg \
  --protocol HTTP \
  --port 3001 \
  --vpc-id vpc-xxx
```

#### 4. RDS (MongoDB Alternative)
```bash
# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier social-platform-db \
  --db-instance-class db.t3.medium \
  --engine postgres \
  --master-username admin \
  --master-user-password <PASSWORD> \
  --allocated-storage 100
```

#### 5. S3 for Media Storage
```bash
# Create S3 bucket
aws s3 mb s3://social-platform-media

# Configure CORS
aws s3api put-bucket-cors \
  --bucket social-platform-media \
  --cors-configuration file://cors.json

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket social-platform-media \
  --versioning-configuration Status=Enabled
```

#### 6. CloudFront CDN
```bash
# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name social-platform-media.s3.amazonaws.com \
  --default-root-object index.html
```

## CI/CD Pipeline

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.38.3'
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Frontend Tests
      run: |
        cd frontend
        flutter pub get
        flutter test
    
    - name: Backend Tests
      run: |
        cd backend
        npm ci
        npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Flutter Web
      run: |
        cd frontend
        flutter build web --release
    
    - name: Build Docker Images
      run: |
        docker build -t ${{ secrets.REGISTRY }}/api-gateway:${{ github.sha }} ./backend/api-gateway
        # Build other services...
    
    - name: Push to Registry
      run: |
        echo ${{ secrets.REGISTRY_PASSWORD }} | docker login -u ${{ secrets.REGISTRY_USERNAME }} --password-stdin
        docker push ${{ secrets.REGISTRY }}/api-gateway:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/api-gateway \
          api-gateway=${{ secrets.REGISTRY }}/api-gateway:${{ github.sha }} \
          -n social-platform
```

## Monitoring

### Setup Prometheus & Grafana

```bash
# Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus -n monitoring

# Install Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana -n monitoring
```

### Application Monitoring

```javascript
// Add to backend services
const prometheus = require('prom-client');

// Create metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(await prometheus.register.metrics());
});
```

## Rollback Strategy

### Quick Rollback (Kubernetes)

```bash
# View deployment history
kubectl rollout history deployment/auth-service -n social-platform

# Rollback to previous version
kubectl rollout undo deployment/auth-service -n social-platform

# Rollback to specific revision
kubectl rollout undo deployment/auth-service --to-revision=2 -n social-platform
```

### Database Rollback

```bash
# Create backup before deployment
mongodump --uri="$MONGODB_URI" --out=/backup/$(date +%Y%m%d)

# Restore if needed
mongorestore --uri="$MONGODB_URI" /backup/20251214
```

## Health Checks

### Backend Health Endpoint

```javascript
// Add to all services
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'auth-service',
    version: process.env.VERSION
  });
});
```

### Frontend Health Check

```bash
# Check if frontend is serving
curl -I https://yourdomain.com

# Should return 200 OK
```

## Troubleshooting

### Common Issues

1. **Service not starting**
   ```bash
   kubectl logs -f deployment/service-name -n social-platform
   ```

2. **Database connection failed**
   - Check MongoDB URI in environment variables
   - Verify network connectivity
   - Check firewall rules

3. **High memory usage**
   ```bash
   kubectl top pods -n social-platform
   kubectl describe pod pod-name -n social-platform
   ```

4. **SSL certificate issues**
   ```bash
   # Check certificate expiration
   openssl s_client -connect yourdomain.com:443 -servername yourdomain.com
   ```

---

**Last Updated**: December 14, 2025
**Version**: 1.0
