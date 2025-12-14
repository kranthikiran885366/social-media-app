part of 'reels_bloc.dart';

abstract class ReelsEvent extends Equatable {
  const ReelsEvent();

  @override
  List<Object> get props => [];
}

class LoadReels extends ReelsEvent {}

class LoadMoreReels extends ReelsEvent {}

class LikeReel extends ReelsEvent {
  final String reelId;
  const LikeReel(this.reelId);
  
  @override
  List<Object> get props => [reelId];
}

class SaveReel extends ReelsEvent {
  final String reelId;
  const SaveReel(this.reelId);
  
  @override
  List<Object> get props => [reelId];
}

class ShareReel extends ReelsEvent {
  final String reelId;
  const ShareReel(this.reelId);
  
  @override
  List<Object> get props => [reelId];
}

class FollowUser extends ReelsEvent {
  final String userId;
  const FollowUser(this.userId);
  
  @override
  List<Object> get props => [userId];
}

class RecordReel extends ReelsEvent {
  final int duration;
  final double speed;
  final bool useTimer;
  final int timerDuration;
  
  const RecordReel({
    this.duration = 30,
    this.speed = 1.0,
    this.useTimer = false,
    this.timerDuration = 3,
  });
  
  @override
  List<Object> get props => [duration, speed, useTimer, timerDuration];
}

class UploadReel extends ReelsEvent {
  final String videoPath;
  const UploadReel(this.videoPath);
  
  @override
  List<Object> get props => [videoPath];
}

class TrimVideo extends ReelsEvent {
  final String videoPath;
  final double startTime;
  final double endTime;
  
  const TrimVideo({
    required this.videoPath,
    required this.startTime,
    required this.endTime,
  });
  
  @override
  List<Object> get props => [videoPath, startTime, endTime];
}

class ChangeSpeed extends ReelsEvent {
  final String videoPath;
  final double speed;
  
  const ChangeSpeed({
    required this.videoPath,
    required this.speed,
  });
  
  @override
  List<Object> get props => [videoPath, speed];
}

class AddAudio extends ReelsEvent {
  final String videoPath;
  final ReelAudio audio;
  final double startTime;
  final double volume;
  
  const AddAudio({
    required this.videoPath,
    required this.audio,
    this.startTime = 0.0,
    this.volume = 1.0,
  });
  
  @override
  List<Object> get props => [videoPath, audio, startTime, volume];
}

class AddEffect extends ReelsEvent {
  final String videoPath;
  final ReelEffect effect;
  
  const AddEffect({
    required this.videoPath,
    required this.effect,
  });
  
  @override
  List<Object> get props => [videoPath, effect];
}

class AddTemplate extends ReelsEvent {
  final ReelTemplate template;
  final List<String> videoPaths;
  
  const AddTemplate({
    required this.template,
    required this.videoPaths,
  });
  
  @override
  List<Object> get props => [template, videoPaths];
}

class AddVoiceOver extends ReelsEvent {
  final String videoPath;
  final String audioPath;
  final double startTime;
  
  const AddVoiceOver({
    required this.videoPath,
    required this.audioPath,
    this.startTime = 0.0,
  });
  
  @override
  List<Object> get props => [videoPath, audioPath, startTime];
}

class AddVoiceEffect extends ReelsEvent {
  final String audioPath;
  final String effectType;
  
  const AddVoiceEffect({
    required this.audioPath,
    required this.effectType,
  });
  
  @override
  List<Object> get props => [audioPath, effectType];
}

class AddTextToSpeech extends ReelsEvent {
  final String text;
  final String voice;
  final double speed;
  
  const AddTextToSpeech({
    required this.text,
    required this.voice,
    this.speed = 1.0,
  });
  
  @override
  List<Object> get props => [text, voice, speed];
}

class GenerateAutoCaptions extends ReelsEvent {
  final String videoPath;
  const GenerateAutoCaptions(this.videoPath);
  
  @override
  List<Object> get props => [videoPath];
}

class AddSticker extends ReelsEvent {
  final String videoPath;
  final String stickerId;
  final double x;
  final double y;
  final double scale;
  final double rotation;
  
  const AddSticker({
    required this.videoPath,
    required this.stickerId,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
  
  @override
  List<Object> get props => [videoPath, stickerId, x, y, scale, rotation];
}

class TagPeople extends ReelsEvent {
  final String videoPath;
  final List<String> userIds;
  final List<Map<String, double>> positions;
  
  const TagPeople({
    required this.videoPath,
    required this.userIds,
    required this.positions,
  });
  
  @override
  List<Object> get props => [videoPath, userIds, positions];
}

class AddLocation extends ReelsEvent {
  final String videoPath;
  final String location;
  final double latitude;
  final double longitude;
  
  const AddLocation({
    required this.videoPath,
    required this.location,
    required this.latitude,
    required this.longitude,
  });
  
  @override
  List<Object> get props => [videoPath, location, latitude, longitude];
}

class SaveDraft extends ReelsEvent {
  final ReelDraft draft;
  const SaveDraft(this.draft);
  
  @override
  List<Object> get props => [draft];
}

class LoadDrafts extends ReelsEvent {}

class PublishReel extends ReelsEvent {
  final ReelDraft draft;
  const PublishReel(this.draft);
  
  @override
  List<Object> get props => [draft];
}

class RemixReel extends ReelsEvent {
  final String originalReelId;
  final String newVideoPath;
  final RemixType type;
  
  const RemixReel({
    required this.originalReelId,
    required this.newVideoPath,
    this.type = RemixType.duet,
  });
  
  @override
  List<Object> get props => [originalReelId, newVideoPath, type];
}

enum RemixType { duet, remix, template }

class ViewReel extends ReelsEvent {
  final String reelId;
  const ViewReel(this.reelId);
  
  @override
  List<Object> get props => [reelId];
}

class LoadReelInsights extends ReelsEvent {
  final String reelId;
  const LoadReelInsights(this.reelId);
  
  @override
  List<Object> get props => [reelId];
}

class BoostReel extends ReelsEvent {
  final String reelId;
  final double budget;
  final int duration;
  final List<String> targetAudience;
  
  const BoostReel({
    required this.reelId,
    required this.budget,
    required this.duration,
    required this.targetAudience,
  });
  
  @override
  List<Object> get props => [reelId, budget, duration, targetAudience];
}

class CreatePlaylist extends ReelsEvent {
  final String name;
  final String description;
  
  const CreatePlaylist({
    required this.name,
    required this.description,
  });
  
  @override
  List<Object> get props => [name, description];
}

class AddToPlaylist extends ReelsEvent {
  final String reelId;
  final String playlistId;
  
  const AddToPlaylist({
    required this.reelId,
    required this.playlistId,
  });
  
  @override
  List<Object> get props => [reelId, playlistId];
}

class LoadTrendingAudio extends ReelsEvent {}

class LoadMusicLibrary extends ReelsEvent {
  final String? genre;
  final String? mood;
  
  const LoadMusicLibrary({this.genre, this.mood});
  
  @override
  List<Object> get props => [genre ?? '', mood ?? ''];
}

class SearchAudio extends ReelsEvent {
  final String query;
  const SearchAudio(this.query);
  
  @override
  List<Object> get props => [query];
}

class LoadEffects extends ReelsEvent {
  final String category;
  const LoadEffects(this.category);
  
  @override
  List<Object> get props => [category];
}

class LoadAREffects extends ReelsEvent {}

class LoadTemplates extends ReelsEvent {
  final String category;
  const LoadTemplates(this.category);
  
  @override
  List<Object> get props => [category];
}