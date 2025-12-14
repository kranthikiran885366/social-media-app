import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';
import 'websocket_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
    _setupWebSocketListeners();
    _initialized = true;
  }
  
  static void _setupWebSocketListeners() {
    WebSocketService.onNotification((data) {
      _showNotification(
        title: data['title'] ?? 'New Notification',
        body: data['body'] ?? '',
        payload: data['payload'],
      );
    });
  }
  
  static Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'smart_social_channel',
      'Smart Social Notifications',
      channelDescription: 'Notifications from Smart Social Platform',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  static Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    return await ApiService.getNotifications();
  }
  
  static Future<void> markAsRead(String notificationId) async {
    await ApiService.markNotificationRead(notificationId);
  }
}