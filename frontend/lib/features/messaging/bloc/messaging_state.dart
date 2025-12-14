part of 'messaging_bloc.dart';

abstract class MessagingState extends Equatable {
  const MessagingState();

  @override
  List<Object> get props => [];
}

class MessagingInitial extends MessagingState {}

class MessagingLoading extends MessagingState {}

class ChatsLoaded extends MessagingState {
  final List<Chat> chats;

  const ChatsLoaded(this.chats);

  @override
  List<Object> get props => [chats];
}

class MessagesLoaded extends MessagingState {
  final String chatId;
  final List<Message> messages;

  const MessagesLoaded(this.chatId, this.messages);

  @override
  List<Object> get props => [chatId, messages];
}

class MessagingError extends MessagingState {
  final String message;

  const MessagingError(this.message);

  @override
  List<Object> get props => [message];
}

class TypingIndicator extends MessagingState {
  final String chatId;
  final String userId;

  const TypingIndicator({required this.chatId, required this.userId});

  @override
  List<Object> get props => [chatId, userId];
}