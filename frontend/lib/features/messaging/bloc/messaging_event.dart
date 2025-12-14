part of 'messaging_bloc.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();

  @override
  List<Object> get props => [];
}

class LoadChats extends MessagingEvent {}

class LoadMessages extends MessagingEvent {
  final String chatId;

  const LoadMessages({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

class SendMessage extends MessagingEvent {
  final String chatId;
  final String content;
  final MessageType type;

  const SendMessage({
    required this.chatId,
    required this.content,
    this.type = MessageType.text,
  });

  @override
  List<Object> get props => [chatId, content, type];
}

class ReceiveMessage extends MessagingEvent {
  final String chatId;
  final Message message;

  const ReceiveMessage({required this.chatId, required this.message});

  @override
  List<Object> get props => [chatId, message];
}

class StartTyping extends MessagingEvent {
  final String chatId;

  const StartTyping({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

class StopTyping extends MessagingEvent {
  final String chatId;

  const StopTyping({required this.chatId});

  @override
  List<Object> get props => [chatId];
}