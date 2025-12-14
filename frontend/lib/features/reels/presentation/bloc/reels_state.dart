part of 'reels_bloc.dart';

abstract class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object> get props => [];
}

class ReelsInitial extends ReelsState {}

class ReelsLoading extends ReelsState {}

class ReelsLoaded extends ReelsState {
  final List<Reel> reels;
  final bool hasReachedMax;
  final int currentIndex;

  const ReelsLoaded({
    required this.reels,
    this.hasReachedMax = false,
    this.currentIndex = 0,
  });

  ReelsLoaded copyWith({
    List<Reel>? reels,
    bool? hasReachedMax,
    int? currentIndex,
  }) {
    return ReelsLoaded(
      reels: reels ?? this.reels,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [reels, hasReachedMax, currentIndex];
}

class ReelsLoadingMore extends ReelsState {
  final List<Reel> reels;

  const ReelsLoadingMore({required this.reels});

  @override
  List<Object> get props => [reels];
}

class ReelsError extends ReelsState {
  final String message;

  const ReelsError(this.message);

  @override
  List<Object> get props => [message];
}

// Recording States
class ReelRecording extends ReelsState {}

class ReelRecorded extends ReelsState {
  final String videoPath;

  const ReelRecorded({required this.videoPath});

  @override
  List<Object> get props => [videoPath];
}

class ReelUploading extends ReelsState {}

class ReelUploaded extends ReelsState {
  final String videoPath;

  const ReelUploaded({required this.videoPath});

  @override
  List<Object> get props => [videoPath];
}

// Editing States
class VideoTrimming extends ReelsState {}

class VideoTrimmed extends ReelsState {
  final String originalPath;
  final String trimmedPath;
  final double startTime;
  final double endTime;

  const VideoTrimmed({
    required this.originalPath,
    required this.trimmedPath,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [originalPath, trimmedPath, startTime, endTime];
}

class SpeedChanging extends ReelsState {}

class SpeedChanged extends ReelsState {
  final String videoPath;
  final double speed;

  const SpeedChanged({
    required this.videoPath,
    required this.speed,
  });

  @override
  List<Object> get props => [videoPath, speed];
}

class AudioAdding extends ReelsState {}

class AudioAdded extends ReelsState {
  final String videoPath;
  final ReelAudio audio;

  const AudioAdded({
    required this.videoPath,
    required this.audio,
  });

  @override
  List<Object> get props => [videoPath, audio];
}

class EffectAdding extends ReelsState {}

class EffectAdded extends ReelsState {
  final String videoPath;
  final ReelEffect effect;

  const EffectAdded({
    required this.videoPath,
    required this.effect,
  });

  @override
  List<Object> get props => [videoPath, effect];
}

class TemplateApplying extends ReelsState {}

class TemplateApplied extends ReelsState {
  final ReelTemplate template;
  final String videoPath;

  const TemplateApplied({
    required this.template,
    required this.videoPath,
  });

  @override
  List<Object> get props => [template, videoPath];
}

class VoiceOverAdding extends ReelsState {}

class VoiceOverAdded extends ReelsState {
  final String videoPath;
  final String audioPath;

  const VoiceOverAdded({
    required this.videoPath,
    required this.audioPath,
  });

  @override
  List<Object> get props => [videoPath, audioPath];
}

class VoiceEffectApplying extends ReelsState {}

class VoiceEffectApplied extends ReelsState {
  final String audioPath;
  final String effectType;

  const VoiceEffectApplied({
    required this.audioPath,
    required this.effectType,
  });

  @override
  List<Object> get props => [audioPath, effectType];
}

class TextToSpeechGenerating extends ReelsState {}

class TextToSpeechGenerated extends ReelsState {
  final String text;
  final String audioPath;

  const TextToSpeechGenerated({
    required this.text,
    required this.audioPath,
  });

  @override
  List<Object> get props => [text, audioPath];
}

class AutoCaptionsGenerating extends ReelsState {}

class AutoCaptionsGenerated extends ReelsState {
  final String videoPath;
  final List<Caption> captions;

  const AutoCaptionsGenerated({
    required this.videoPath,
    required this.captions,
  });

  @override
  List<Object> get props => [videoPath, captions];
}

class Caption {
  final String text;
  final double startTime;
  final double endTime;

  Caption({
    required this.text,
    required this.startTime,
    required this.endTime,
  });
}

// Draft States
class DraftSaving extends ReelsState {}

class DraftSaved extends ReelsState {
  final ReelDraft draft;

  const DraftSaved({required this.draft});

  @override
  List<Object> get props => [draft];
}

class DraftsLoading extends ReelsState {}

class DraftsLoaded extends ReelsState {
  final List<ReelDraft> drafts;

  const DraftsLoaded({required this.drafts});

  @override
  List<Object> get props => [drafts];
}

// Publishing States
class ReelPublishing extends ReelsState {}

class ReelPublished extends ReelsState {
  final Reel reel;

  const ReelPublished({required this.reel});

  @override
  List<Object> get props => [reel];
}

// Remix States
class ReelRemixing extends ReelsState {}

class ReelRemixed extends ReelsState {
  final String originalReelId;
  final String remixVideoPath;

  const ReelRemixed({
    required this.originalReelId,
    required this.remixVideoPath,
  });

  @override
  List<Object> get props => [originalReelId, remixVideoPath];
}

// Interaction States
class ReelLiked extends ReelsState {
  final String reelId;
  final bool isLiked;

  const ReelLiked({
    required this.reelId,
    required this.isLiked,
  });

  @override
  List<Object> get props => [reelId, isLiked];
}

class ReelSaved extends ReelsState {
  final String reelId;
  final bool isSaved;

  const ReelSaved({
    required this.reelId,
    required this.isSaved,
  });

  @override
  List<Object> get props => [reelId, isSaved];
}

class ReelShared extends ReelsState {
  final String reelId;

  const ReelShared(this.reelId);

  @override
  List<Object> get props => [reelId];
}

class UserFollowed extends ReelsState {
  final String userId;
  final bool isFollowing;

  const UserFollowed({
    required this.userId,
    required this.isFollowing,
  });

  @override
  List<Object> get props => [userId, isFollowing];
}

// Insights States
class InsightsLoading extends ReelsState {}

class InsightsLoaded extends ReelsState {
  final String reelId;
  final ReelInsights insights;

  const InsightsLoaded({
    required this.reelId,
    required this.insights,
  });

  @override
  List<Object> get props => [reelId, insights];
}

// Boost States
class ReelBoosting extends ReelsState {}

class ReelBoosted extends ReelsState {
  final String reelId;

  const ReelBoosted({required this.reelId});

  @override
  List<Object> get props => [reelId];
}

// Playlist States
class PlaylistCreating extends ReelsState {}

class PlaylistCreated extends ReelsState {
  final ReelPlaylist playlist;

  const PlaylistCreated({required this.playlist});

  @override
  List<Object> get props => [playlist];
}

class AddingToPlaylist extends ReelsState {}

class AddedToPlaylist extends ReelsState {
  final String reelId;
  final String playlistId;

  const AddedToPlaylist({
    required this.reelId,
    required this.playlistId,
  });

  @override
  List<Object> get props => [reelId, playlistId];
}

// Audio States
class TrendingAudioLoading extends ReelsState {}

class TrendingAudioLoaded extends ReelsState {
  final List<ReelAudio> trendingAudio;

  const TrendingAudioLoaded({required this.trendingAudio});

  @override
  List<Object> get props => [trendingAudio];
}

class MusicLibraryLoading extends ReelsState {}

class MusicLibraryLoaded extends ReelsState {
  final List<ReelAudio> musicLibrary;

  const MusicLibraryLoaded({required this.musicLibrary});

  @override
  List<Object> get props => [musicLibrary];
}

class AudioSearching extends ReelsState {}

class AudioSearchResults extends ReelsState {
  final String query;
  final List<ReelAudio> results;

  const AudioSearchResults({
    required this.query,
    required this.results,
  });

  @override
  List<Object> get props => [query, results];
}

// Effects States
class EffectsLoading extends ReelsState {}

class EffectsLoaded extends ReelsState {
  final String category;
  final List<ReelEffect> effects;

  const EffectsLoaded({
    required this.category,
    required this.effects,
  });

  @override
  List<Object> get props => [category, effects];
}

class AREffectsLoading extends ReelsState {}

class AREffectsLoaded extends ReelsState {
  final List<ReelEffect> arEffects;

  const AREffectsLoaded({required this.arEffects});

  @override
  List<Object> get props => [arEffects];
}

// Template States
class TemplatesLoading extends ReelsState {}

class TemplatesLoaded extends ReelsState {
  final String category;
  final List<ReelTemplate> templates;

  const TemplatesLoaded({
    required this.category,
    required this.templates,
  });

  @override
  List<Object> get props => [category, templates];
}