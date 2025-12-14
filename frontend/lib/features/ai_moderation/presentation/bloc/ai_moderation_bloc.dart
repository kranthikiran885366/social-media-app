import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'ai_moderation_event.dart';
part 'ai_moderation_state.dart';

class AiModerationBloc extends Bloc<AiModerationEvent, AiModerationState> {
  AiModerationBloc() : super(AiModerationInitial()) {
    on<AnalyzeContent>(_onAnalyzeContent);
    on<CheckContentQuality>(_onCheckContentQuality);
  }

  void _onAnalyzeContent(AnalyzeContent event, Emitter<AiModerationState> emit) async {
    emit(AiModerationLoading());
    
    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 2));
    
    final score = _calculateContentScore(event.content, event.mediaUrls);
    
    if (score >= 6.0) {
      emit(ContentApproved(score: score));
    } else {
      emit(ContentRejected(
        score: score,
        reasons: _getRejectReasons(score),
      ));
    }
  }

  void _onCheckContentQuality(CheckContentQuality event, Emitter<AiModerationState> emit) async {
    emit(AiModerationLoading());
    
    await Future.delayed(const Duration(seconds: 1));
    
    final qualityMetrics = ContentQualityMetrics(
      relevanceScore: 8.5,
      engagementPotential: 7.2,
      educationalValue: 6.8,
      originalityScore: 9.1,
    );
    
    emit(QualityAnalysisComplete(qualityMetrics));
  }

  double _calculateContentScore(String content, List<String> mediaUrls) {
    double score = 5.0;
    
    // Content length check
    if (content.length > 50) score += 1.0;
    
    // Media presence
    if (mediaUrls.isNotEmpty) score += 0.5;
    
    // Keyword analysis (simplified)
    final positiveKeywords = ['learn', 'inspire', 'create', 'achieve', 'grow'];
    for (final keyword in positiveKeywords) {
      if (content.toLowerCase().contains(keyword)) {
        score += 0.3;
      }
    }
    
    return score.clamp(0.0, 10.0);
  }

  List<String> _getRejectReasons(double score) {
    final reasons = <String>[];
    
    if (score < 4.0) reasons.add('Content appears to be low quality');
    if (score < 3.0) reasons.add('Lacks educational or inspirational value');
    if (score < 2.0) reasons.add('May be spam or irrelevant content');
    
    return reasons;
  }
}

class ContentQualityMetrics {
  final double relevanceScore;
  final double engagementPotential;
  final double educationalValue;
  final double originalityScore;

  ContentQualityMetrics({
    required this.relevanceScore,
    required this.engagementPotential,
    required this.educationalValue,
    required this.originalityScore,
  });
}