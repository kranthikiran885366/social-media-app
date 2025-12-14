import 'package:equatable/equatable.dart';

enum LiveStatus { waiting, live, ended }
enum LiveType { solo, guest, room }

class LiveStream extends Equatable {
  final String id;
  final String hostId;
  final String title;
  final String? description;
  final LiveStatus status;
  final LiveType type;
  final DateTime startTime;
  final DateTime? endTime;
  final int viewerCount;
  final int likeCount;
  final List<String> guests;
  final List<LiveComment> comments;
  final LiveSettings settings;
  final Map<String, dynamic> metadata;

  const LiveStream({
    required this.id,
    required this.hostId,
    required this.title,
    this.description,
    required this.status,
    required this.type,
    required this.startTime,
    this.endTime,
    this.viewerCount = 0,
    this.likeCount = 0,
    this.guests = const [],
    this.comments = const [],
    required this.settings,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [id, hostId, status, startTime, viewerCount];
}

class LiveComment extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime timestamp;
  final bool isPinned;

  const LiveComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
    this.isPinned = false,
  });

  @override
  List<Object> get props => [id, userId, content, timestamp];
}

class LiveSettings extends Equatable {
  final bool commentsEnabled;
  final bool guestsEnabled;
  final bool shoppingEnabled;
  final bool questionsEnabled;
  final bool donationsEnabled;
  final List<String> moderators;

  const LiveSettings({
    this.commentsEnabled = true,
    this.guestsEnabled = true,
    this.shoppingEnabled = false,
    this.questionsEnabled = true,
    this.donationsEnabled = false,
    this.moderators = const [],
  });

  @override
  List<Object> get props => [commentsEnabled, guestsEnabled, shoppingEnabled];
}

class LiveQuestion extends Equatable {
  final String id;
  final String userId;
  final String question;
  final DateTime timestamp;
  final bool isAnswered;

  const LiveQuestion({
    required this.id,
    required this.userId,
    required this.question,
    required this.timestamp,
    this.isAnswered = false,
  });

  @override
  List<Object> get props => [id, userId, question, timestamp];
}

class LiveDonation extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String? message;
  final DateTime timestamp;

  const LiveDonation({
    required this.id,
    required this.userId,
    required this.amount,
    this.message,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, amount, timestamp];
}