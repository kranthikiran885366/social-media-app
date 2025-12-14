part of 'ai_moderation_bloc.dart';

abstract class AiModerationState extends Equatable {
  const AiModerationState();

  @override
  List<Object> get props => [];
}

class AiModerationInitial extends AiModerationState {}

class AiModerationLoading extends AiModerationState {}

class ContentApproved extends AiModerationState {
  final double score;

  const ContentApproved({required this.score});

  @override
  List<Object> get props => [score];
}

class ContentRejected extends AiModerationState {
  final double score;
  final List<String> reasons;

  const ContentRejected({
    required this.score,
    required this.reasons,
  });

  @override
  List<Object> get props => [score, reasons];
}

class QualityAnalysisComplete extends AiModerationState {
  final ContentQualityMetrics metrics;

  const QualityAnalysisComplete(this.metrics);

  @override
  List<Object> get props => [metrics];
}