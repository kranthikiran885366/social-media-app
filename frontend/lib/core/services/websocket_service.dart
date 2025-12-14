import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  
  static void connect() {
    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    
    _socket!.connect();
    
    _socket!.onConnect((_) {
      _isConnected = true;
      print('Connected to WebSocket');
    });
    
    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('Disconnected from WebSocket');
    });
  }
  
  static void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
  }
  
  static bool get isConnected => _isConnected;
  
  // Chat events
  static void joinChat(String chatId) {
    _socket?.emit('join_chat', {'chatId': chatId});
  }
  
  static void sendMessage(String chatId, String message) {
    _socket?.emit('send_message', {
      'chatId': chatId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static void onNewMessage(Function(Map<String, dynamic>) callback) {
    _socket?.on('new_message', (data) => callback(data));
  }
  
  // Notification events
  static void onNotification(Function(Map<String, dynamic>) callback) {
    _socket?.on('notification', (data) => callback(data));
  }
  
  // Live stream events
  static void joinLiveStream(String streamId) {
    _socket?.emit('join_stream', {'streamId': streamId});
  }
  
  static void onLiveStreamUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on('stream_update', (data) => callback(data));
  }
  
  // Feed updates
  static void onFeedUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on('feed_update', (data) => callback(data));
  }
}