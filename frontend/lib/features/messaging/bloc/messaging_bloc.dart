import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/websocket_service.dart';

part 'messaging_event.dart';
part 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  MessagingBloc() : super(MessagingInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);
    
    _setupWebSocketListeners();
  }

  void _setupWebSocketListeners() {
    WebSocketService.onNewMessage((data) {
      add(ReceiveMessage(
        chatId: data['chatId'],
        message: Message.fromJson(data),
      ));
    });
  }

  void _onLoadChats(LoadChats event, Emitter<MessagingState> emit) async {
    emit(MessagingLoading());
    try {
      final result = await ApiService.getChats();
      if (result['success']) {
        final chatsData = result['data']['chats'] as List? ?? [];
        final chats = chatsData.map((data) => Chat.fromJson(data)).toList();
        emit(ChatsLoaded(chats));
      } else {
        emit(MessagingError(result['error']));
      }
    } catch (e) {
      emit(MessagingError(e.toString()));
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<MessagingState> emit) async {
    emit(MessagingLoading());
    try {
      // Mock messages - integrate with chat repository
      final messages = [
        Message(
          id: '1',
          senderId: 'user1',
          content: 'Hello!',
          timestamp: DateTime.now(),
          type: MessageType.text,
        ),
      ];
      emit(MessagesLoaded(event.chatId, messages));
    } catch (e) {
      emit(MessagingError(e.toString()));
    }
  }

  void _onSendMessage(SendMessage event, Emitter<MessagingState> emit) async {
    try {
      WebSocketService.sendMessage(event.chatId, event.content);
      
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'currentUser',
        content: event.content,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      
      if (state is MessagesLoaded) {
        final currentState = state as MessagesLoaded;
        emit(MessagesLoaded(
          currentState.chatId,
          [...currentState.messages, message],
        ));
      }
    } catch (e) {
      emit(MessagingError(e.toString()));
    }
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<MessagingState> emit) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      if (currentState.chatId == event.chatId) {
        emit(MessagesLoaded(
          currentState.chatId,
          [...currentState.messages, event.message],
        ));
      }
    }
  }

  void _onStartTyping(StartTyping event, Emitter<MessagingState> emit) {
    // Handle typing indicator
  }

  void _onStopTyping(StopTyping event, Emitter<MessagingState> emit) {
    // Handle stop typing
  }
}

class Chat {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  Chat({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: DateTime.tryParse(json['lastMessageTime'] ?? '') ?? DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      isRead: json['isRead'] ?? false,
    );
  }
}

enum MessageType { text, image, video, audio, file }