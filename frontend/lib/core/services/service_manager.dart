import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ServiceManager {
  static const String _baseUrl = 'http://localhost:8000/api';
  static final Map<String, bool> _serviceStatus = {};
  static Timer? _healthCheckTimer;

  // Initialize service manager
  static Future<void> initialize() async {
    await _checkAllServicesHealth();
    _startHealthMonitoring();
  }

  // Check health of all services
  static Future<void> _checkAllServicesHealth() async {
    final services = [
      'auth', 'users', 'content', 'feed', 'search', 
      'notifications', 'analytics', 'chat', 'media', 
      'live', 'payments', 'moderation', 'ml', 'creator',
      'recommendations', 'security', 'admin'
    ];

    for (String service in services) {
      _serviceStatus[service] = await _checkServiceHealth(service);
    }
  }

  // Check individual service health
  static Future<bool> _checkServiceHealth(String serviceName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$serviceName/health'),
        headers: await ApiService.getHeaders(),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Start health monitoring
  static void _startHealthMonitoring() {
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _checkAllServicesHealth(),
    );
  }

  // Get service status
  static bool isServiceHealthy(String serviceName) {
    return _serviceStatus[serviceName] ?? false;
  }

  // Get all service statuses
  static Map<String, bool> getAllServiceStatuses() {
    return Map.from(_serviceStatus);
  }

  // Execute request with fallback
  static Future<Map<String, dynamic>> executeWithFallback(
    String serviceName,
    Future<Map<String, dynamic>> Function() primaryRequest,
    {Future<Map<String, dynamic>> Function()? fallbackRequest}
  ) async {
    try {
      if (!isServiceHealthy(serviceName)) {
        throw Exception('Service $serviceName is not healthy');
      }
      
      final result = await primaryRequest();
      
      if (result['success'] == true) {
        return result;
      } else {
        throw Exception(result['error'] ?? 'Request failed');
      }
    } catch (e) {
      if (fallbackRequest != null) {
        try {
          return await fallbackRequest();
        } catch (fallbackError) {
          return {
            'success': false,
            'error': 'Both primary and fallback requests failed',
            'primaryError': e.toString(),
            'fallbackError': fallbackError.toString(),
          };
        }
      }
      
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Dispose resources
  static void dispose() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
  }
}

// Service-specific managers
class AuthServiceManager {
  static Future<Map<String, dynamic>> login(String email, String password) {
    return ServiceManager.executeWithFallback(
      'auth',
      () => ApiService.login(email, password),
    );
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) {
    return ServiceManager.executeWithFallback(
      'auth',
      () => ApiService.register(userData),
    );
  }
}

class ContentServiceManager {
  static Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) {
    return ServiceManager.executeWithFallback(
      'content',
      () => ApiService.createPost(postData),
    );
  }

  static Future<Map<String, dynamic>> getPosts({int page = 1, int limit = 20}) {
    return ServiceManager.executeWithFallback(
      'content',
      () => ApiService.getPosts(page: page, limit: limit),
    );
  }
}

class FeedServiceManager {
  static Future<Map<String, dynamic>> getPersonalizedFeed({int page = 1}) {
    return ServiceManager.executeWithFallback(
      'feed',
      () => ApiService.getPersonalizedFeed(page: page),
    );
  }
}

class PaymentServiceManager {
  static Future<Map<String, dynamic>> processPayment(Map<String, dynamic> paymentData) {
    return ServiceManager.executeWithFallback(
      'payments',
      () => ApiService.processPayment(paymentData),
    );
  }

  static Future<Map<String, dynamic>> getPaymentHistory(String userId) {
    return ServiceManager.executeWithFallback(
      'payments',
      () => ApiService.getPaymentHistory(userId),
    );
  }
}

class MediaServiceManager {
  static Future<Map<String, dynamic>> uploadMedia(Map<String, dynamic> mediaData) {
    return ServiceManager.executeWithFallback(
      'media',
      () => ApiService.uploadMedia(mediaData),
    );
  }
}

class NotificationServiceManager {
  static Future<Map<String, dynamic>> getNotifications() {
    return ServiceManager.executeWithFallback(
      'notifications',
      () => ApiService.getNotifications(),
    );
  }
}

class SearchServiceManager {
  static Future<Map<String, dynamic>> searchContent(String query) {
    return ServiceManager.executeWithFallback(
      'search',
      () => ApiService.searchContent(query),
    );
  }
}

class ChatServiceManager {
  static Future<Map<String, dynamic>> getChats() {
    return ServiceManager.executeWithFallback(
      'chat',
      () => ApiService.getChats(),
    );
  }
}

class AnalyticsServiceManager {
  static Future<Map<String, dynamic>> getAnalytics(String userId) {
    return ServiceManager.executeWithFallback(
      'analytics',
      () => ApiService.getAnalytics(userId),
    );
  }
}

class CreatorServiceManager {
  static Future<Map<String, dynamic>> getCreatorDashboard() {
    return ServiceManager.executeWithFallback(
      'creator',
      () => ApiService.getCreatorDashboard(),
    );
  }
}

class LiveServiceManager {
  static Future<Map<String, dynamic>> getLiveStreams() {
    return ServiceManager.executeWithFallback(
      'live',
      () => ApiService.getLiveStreams(),
    );
  }
}