part of 'ai_moderation_bloc.dart';

abstract class AiModerationEvent extends Equatable {
  const AiModerationEvent();

  @override
  List<Object> get props => [];
}

class AnalyzeContent extends AiModerationEvent {
  final String content;
  final List<String> mediaUrls;
  final String contentType;

  const AnalyzeContent({
    required this.content,
    required this.mediaUrls,
    required this.contentType,
  });

  @override
  List<Object> get props => [content, mediaUrls, contentType];
}

class CheckContentQuality extends AiModerationEvent {
  final String postId;

  const CheckContentQuality(this.postId);

  @override
  List<Object> get props => [postId];
}