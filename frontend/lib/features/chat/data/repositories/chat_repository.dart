import '../../../../core/services/api_service.dart';

class ChatRepository {
  Future<Map<String, dynamic>> getChats() async {
    return await ApiService.getChats();
  }
  
  Future<Map<String, dynamic>> sendMessage(String chatId, String message) async {
    return {'success': true, 'data': {'messageId': DateTime.now().millisecondsSinceEpoch.toString()}};
  }
  
  Future<Map<String, dynamic>> getChatMessages(String chatId, {int page = 1}) async {
    return {
      'success': true,
      'data': {
        'messages': [
          {
            'id': '1',
            'senderId': 'user1',
            'content': 'Hello!',
            'timestamp': DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
            'type': 'text'
          }
        ]
      }
    };
  }
}