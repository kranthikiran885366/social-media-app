import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const _storage = FlutterSecureStorage();
  
  static Future<String?> getToken() async => await _storage.read(key: 'auth_token');
  static Future<void> setToken(String token) async => await _storage.write(key: 'auth_token', value: token);
  static Future<void> clearToken() async => await _storage.delete(key: 'auth_token');
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Auth Service
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await getHeaders(),
      body: jsonEncode(userData),
    );
    return _handleResponse(response);
  }
  
  // User Service
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile/$userId'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }
  
  // Content Service
  static Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/content/posts'),
      headers: await getHeaders(),
      body: jsonEncode(postData),
    );
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> getPosts({int page = 1, int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/posts?page=$page&limit=$limit'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // Feed Service
  static Future<Map<String, dynamic>> getPersonalizedFeed({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/feed/personalized?page=$page'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // Search Service
  static Future<Map<String, dynamic>> searchContent(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/content?q=$query'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // Chat Service
  static Future<Map<String, dynamic>> getChats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/chats'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // Notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // Creator Service
  static Future<Map<String, dynamic>> getCreatorDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/creator/dashboard'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // Live Service
  static Future<Map<String, dynamic>> getLiveStreams() async {
    final response = await http.get(
      Uri.parse('$baseUrl/live/streams'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // Payment Service
  static Future<Map<String, dynamic>> processPayment(Map<String, dynamic> paymentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/process'),
      headers: await getHeaders(),
      body: jsonEncode(paymentData),
    );
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> getPaymentHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/history/$userId'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // AI Moderation Service
  static Future<Map<String, dynamic>> moderateContent(Map<String, dynamic> contentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/moderation/moderate/content'),
      headers: await getHeaders(),
      body: jsonEncode(contentData),
    );
    return _handleResponse(response);
  }
  
  // Media Service
  static Future<Map<String, dynamic>> uploadMedia(Map<String, dynamic> mediaData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/media/upload'),
      headers: await getHeaders(),
      body: jsonEncode(mediaData),
    );
    return _handleResponse(response);
  }
  
  // Analytics Service
  static Future<Map<String, dynamic>> getAnalytics(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/user/$userId'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // Recommendation Service
  static Future<Map<String, dynamic>> getRecommendations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations/user/$userId'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // Security Service
  static Future<Map<String, dynamic>> checkSecurity(Map<String, dynamic> securityData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/security/check'),
      headers: await getHeaders(),
      body: jsonEncode(securityData),
    );
    return _handleResponse(response);
  }
  
  // ML Service
  static Future<Map<String, dynamic>> getMLPredictions(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ml/predict'),
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }
  
  // Admin Service
  static Future<Map<String, dynamic>> getAdminDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: await getHeaders(),
    );
    return _handleResponse(response);
  }
  
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'error': data['error'] ?? 'Unknown error'};
    }
  }
}