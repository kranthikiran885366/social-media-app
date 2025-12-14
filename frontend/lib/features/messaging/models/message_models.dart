import 'package:equatable/equatable.dart';

enum MessageType { text, image, video, voice, gif, sticker, post, story, location, contact, file }
enum MessageStatus { sending, sent, delivered, read, failed }
enum ChatType { direct, group }

class Message extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String? replyToId;
  final MessageType type;
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isDisappearing;
  final Duration? disappearAfter;
  final List<MessageReaction> reactions;
  final bool isForwarded;
  final bool isEdited;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.replyToId,
    required this.type,
    required this.content,
    this.metadata,
    required this.timestamp,
    required this.status,
    this.isDisappearing = false,
    this.disappearAfter,
    this.reactions = const [],
    this.isForwarded = false,
    this.isEdited = false,
  });

  @override
  List<Object?> get props => [id, chatId, senderId, type, content, timestamp, status];
}

class MessageReaction extends Equatable {
  final String userId;
  final String emoji;
  final DateTime timestamp;

  const MessageReaction({required this.userId, required this.emoji, required this.timestamp});

  @override
  List<Object> get props => [userId, emoji, timestamp];
}

class Chat extends Equatable {
  final String id;
  final ChatType type;
  final List<String> participants;
  final String? name;
  final String? avatar;
  final Message? lastMessage;
  final DateTime? lastActivity;
  final Map<String, DateTime> lastSeen;
  final Map<String, int> unreadCount;
  final bool isPinned;
  final bool isMuted;
  final bool isVanishMode;
  final String? theme;

  const Chat({
    required this.id,
    required this.type,
    required this.participants,
    this.name,
    this.avatar,
    this.lastMessage,
    this.lastActivity,
    this.lastSeen = const {},
    this.unreadCount = const {},
    this.isPinned = false,
    this.isMuted = false,
    this.isVanishMode = false,
    this.theme,
  });

  @override
  List<Object?> get props => [id, type, participants, lastMessage, isPinned, isMuted];
}

class CallData extends Equatable {
  final String id;
  final String chatId;
  final String callerId;
  final List<String> participants;
  final bool isVideo;
  final DateTime startTime;
  final String status;

  const CallData({
    required this.id,
    required this.chatId,
    required this.callerId,
    required this.participants,
    required this.isVideo,
    required this.startTime,
    required this.status,
  });

  @override
  List<Object> get props => [id, chatId, callerId, isVideo, startTime, status];
}