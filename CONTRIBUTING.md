# Contributing to Smart Social Platform

Thank you for considering contributing to Smart Social Platform! This document provides guidelines and instructions for contributing.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/social-media-app.git`
3. Add upstream remote: `git remote add upstream https://github.com/kranthikiran885366/social-media-app.git`
4. Create a new branch: `git checkout -b feature/your-feature-name`

## Development Setup

### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### Backend (Node.js)
```bash
cd backend
npm install
npm run dev
```

### Database
- MongoDB: Configure connection in `.env`
- Redis: Setup for caching and sessions

## How to Contribute

### Reporting Bugs
- Use the GitHub issue tracker
- Describe the bug in detail
- Include steps to reproduce
- Add screenshots if applicable
- Specify your environment (OS, browser, versions)

### Suggesting Enhancements
- Use the GitHub issue tracker
- Clearly describe the enhancement
- Explain why it would be useful
- Provide examples if possible

### Code Contributions
1. Pick an issue or create one
2. Comment on the issue to claim it
3. Fork and create a branch
4. Write your code
5. Write tests
6. Update documentation
7. Submit a pull request

## Pull Request Process

1. **Before Submitting**
   - Ensure all tests pass
   - Update documentation
   - Follow coding standards
   - Rebase on latest main branch

2. **PR Description**
   - Reference related issues
   - Describe changes clearly
   - Add screenshots for UI changes
   - List breaking changes if any

3. **Review Process**
   - Address reviewer comments
   - Keep PR focused and small
   - Be responsive to feedback

4. **After Merge**
   - Delete your branch
   - Update your fork

## Coding Standards

### Flutter/Dart
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `dart format` before committing
- Run `dart analyze` to check for issues
- Write widget tests for UI components
- Use meaningful variable names
- Add comments for complex logic

### Node.js/JavaScript
- Follow [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Use ESLint configuration provided
- Write unit tests with Jest
- Use async/await over callbacks
- Handle errors properly
- Use environment variables for configuration

### General Guidelines
- Keep functions small and focused
- Write self-documenting code
- Add comments only when necessary
- Avoid code duplication
- Use descriptive commit messages
- Write tests for new features

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```
feat(auth): add social login with Google

Implement Google OAuth 2.0 authentication flow
- Add Google sign-in button to login page
- Configure Firebase authentication
- Handle authentication state changes

Closes #123
```

```
fix(feed): resolve infinite scroll bug

Fixed issue where feed would load duplicate posts
when scrolling quickly

Fixes #456
```

## Project Structure

```
smart_social_platform/
├── frontend/              # Flutter mobile/web app
│   ├── lib/
│   │   ├── core/         # Core utilities, themes, routes
│   │   ├── features/     # Feature modules
│   │   └── main.dart     # Entry point
│   └── test/             # Tests
├── backend/              # Node.js backend services
│   ├── api-gateway/      # API Gateway
│   └── services/         # Microservices
├── docs/                 # Documentation
└── infrastructure/       # Infrastructure as code
```

## Testing

### Frontend Tests
```bash
cd frontend
flutter test
flutter test --coverage
```

### Backend Tests
```bash
cd backend
npm test
npm run test:coverage
```

## Documentation

- Update README.md for major changes
- Add JSDoc/DartDoc comments for public APIs
- Update API documentation for endpoint changes
- Include examples in documentation

## Questions?

- Open an issue for questions
- Join our community discussions
- Check existing documentation

Thank you for contributing to Smart Social Platform! 🚀
