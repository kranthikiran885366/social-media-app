import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/reel_model.dart';

part 'reels_event.dart';
part 'reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  ReelsBloc() : super(ReelsInitial()) {
    on<LoadReels>(_onLoadReels);
    on<LoadMoreReels>(_onLoadMoreReels);
    on<LikeReel>(_onLikeReel);
    on<SaveReel>(_onSaveReel);
    on<ShareReel>(_onShareReel);
    on<FollowUser>(_onFollowUser);
    on<RecordReel>(_onRecordReel);
    on<UploadReel>(_onUploadReel);
    on<TrimVideo>(_onTrimVideo);
    on<ChangeSpeed>(_onChangeSpeed);
    on<AddAudio>(_onAddAudio);
    on<AddEffect>(_onAddEffect);
    on<AddTemplate>(_onAddTemplate);
    on<SaveDraft>(_onSaveDraft);
    on<LoadDrafts>(_onLoadDrafts);
    on<PublishReel>(_onPublishReel);
    on<RemixReel>(_onRemixReel);
    on<ViewReel>(_onViewReel);
    on<LoadReelInsights>(_onLoadReelInsights);
    on<BoostReel>(_onBoostReel);
    on<CreatePlaylist>(_onCreatePlaylist);
    on<AddToPlaylist>(_onAddToPlaylist);
  }

  void _onLoadReels(LoadReels event, Emitter<ReelsState> emit) async {
    emit(ReelsLoading());
    await Future.delayed(const Duration(seconds: 1));
    final reels = _generateMockReels();
    emit(ReelsLoaded(reels: reels));
  }

  void _onLoadMoreReels(LoadMoreReels event, Emitter<ReelsState> emit) async {
    if (state is ReelsLoaded) {
      final currentState = state as ReelsLoaded;
      emit(ReelsLoadingMore(reels: currentState.reels));
      await Future.delayed(const Duration(seconds: 1));
      final newReels = _generateMockReels();
      emit(ReelsLoaded(reels: [...currentState.reels, ...newReels]));
    }
  }

  void _onLikeReel(LikeReel event, Emitter<ReelsState> emit) async {
    if (state is ReelsLoaded) {
      final currentState = state as ReelsLoaded;
      final updatedReels = currentState.reels.map((reel) {
        if (reel.id == event.reelId) {
          return reel.copyWith(
            isLiked: !reel.isLiked,
            likes: reel.isLiked ? reel.likes - 1 : reel.likes + 1,
          );
        }
        return reel;
      }).toList();
      emit(ReelsLoaded(reels: updatedReels));
    }
  }

  void _onSaveReel(SaveReel event, Emitter<ReelsState> emit) async {
    if (state is ReelsLoaded) {
      final currentState = state as ReelsLoaded;
      final updatedReels = currentState.reels.map((reel) {
        if (reel.id == event.reelId) {
          return reel.copyWith(isSaved: !reel.isSaved);
        }
        return reel;
      }).toList();
      emit(ReelsLoaded(reels: updatedReels));
    }
  }

  void _onShareReel(ShareReel event, Emitter<ReelsState> emit) async {
    emit(ReelShared(event.reelId));
  }

  void _onFollowUser(FollowUser event, Emitter<ReelsState> emit) async {
    if (state is ReelsLoaded) {
      final currentState = state as ReelsLoaded;
      final updatedReels = currentState.reels.map((reel) {
        if (reel.userId == event.userId) {
          return reel.copyWith(isFollowing: !reel.isFollowing);
        }
        return reel;
      }).toList();
      emit(ReelsLoaded(reels: updatedReels));
    }
  }

  void _onRecordReel(RecordReel event, Emitter<ReelsState> emit) async {
    emit(ReelRecording());
    await Future.delayed(const Duration(seconds: 3));
    emit(ReelRecorded(videoPath: '/path/to/recorded/video.mp4'));
  }

  void _onUploadReel(UploadReel event, Emitter<ReelsState> emit) async {
    emit(ReelUploading());
    await Future.delayed(const Duration(seconds: 2));
    emit(ReelUploaded(videoPath: event.videoPath));
  }

  void _onTrimVideo(TrimVideo event, Emitter<ReelsState> emit) async {
    emit(VideoTrimming());
    await Future.delayed(const Duration(seconds: 2));
    emit(VideoTrimmed(
      originalPath: event.videoPath,
      trimmedPath: '/path/to/trimmed/video.mp4',
      startTime: event.startTime,
      endTime: event.endTime,
    ));
  }

  void _onChangeSpeed(ChangeSpeed event, Emitter<ReelsState> emit) async {
    emit(SpeedChanging());
    await Future.delayed(const Duration(seconds: 1));
    emit(SpeedChanged(
      videoPath: event.videoPath,
      speed: event.speed,
    ));
  }

  void _onAddAudio(AddAudio event, Emitter<ReelsState> emit) async {
    emit(AudioAdding());
    await Future.delayed(const Duration(seconds: 1));
    emit(AudioAdded(
      videoPath: event.videoPath,
      audio: event.audio,
    ));
  }

  void _onAddEffect(AddEffect event, Emitter<ReelsState> emit) async {
    emit(EffectAdding());
    await Future.delayed(const Duration(seconds: 1));
    emit(EffectAdded(
      videoPath: event.videoPath,
      effect: event.effect,
    ));
  }

  void _onAddTemplate(AddTemplate event, Emitter<ReelsState> emit) async {
    emit(TemplateApplying());
    await Future.delayed(const Duration(seconds: 2));
    emit(TemplateApplied(
      template: event.template,
      videoPath: '/path/to/template/video.mp4',
    ));
  }

  void _onSaveDraft(SaveDraft event, Emitter<ReelsState> emit) async {
    emit(DraftSaving());
    await Future.delayed(const Duration(seconds: 1));
    emit(DraftSaved(draft: event.draft));
  }

  void _onLoadDrafts(LoadDrafts event, Emitter<ReelsState> emit) async {
    emit(DraftsLoading());
    await Future.delayed(const Duration(seconds: 1));
    final drafts = _generateMockDrafts();
    emit(DraftsLoaded(drafts: drafts));
  }

  void _onPublishReel(PublishReel event, Emitter<ReelsState> emit) async {
    emit(ReelPublishing());
    await Future.delayed(const Duration(seconds: 2));
    final reel = _createReelFromDraft(event.draft);
    emit(ReelPublished(reel: reel));
  }

  void _onRemixReel(RemixReel event, Emitter<ReelsState> emit) async {
    emit(ReelRemixing());
    await Future.delayed(const Duration(seconds: 2));
    emit(ReelRemixed(
      originalReelId: event.originalReelId,
      remixVideoPath: '/path/to/remix/video.mp4',
    ));
  }

  void _onViewReel(ViewReel event, Emitter<ReelsState> emit) async {
    if (state is ReelsLoaded) {
      final currentState = state as ReelsLoaded;
      final updatedReels = currentState.reels.map((reel) {
        if (reel.id == event.reelId) {
          return reel.copyWith(views: reel.views + 1);
        }
        return reel;
      }).toList();
      emit(ReelsLoaded(reels: updatedReels));
    }
  }

  void _onLoadReelInsights(LoadReelInsights event, Emitter<ReelsState> emit) async {
    emit(InsightsLoading());
    await Future.delayed(const Duration(seconds: 1));
    final insights = _generateMockInsights();
    emit(InsightsLoaded(reelId: event.reelId, insights: insights));
  }

  void _onBoostReel(BoostReel event, Emitter<ReelsState> emit) async {
    emit(ReelBoosting());
    await Future.delayed(const Duration(seconds: 1));
    emit(ReelBoosted(reelId: event.reelId));
  }

  void _onCreatePlaylist(CreatePlaylist event, Emitter<ReelsState> emit) async {
    emit(PlaylistCreating());
    await Future.delayed(const Duration(seconds: 1));
    final playlist = ReelPlaylist(
      id: 'playlist_${DateTime.now().millisecondsSinceEpoch}',
      name: event.name,
      description: event.description,
      coverUrl: 'https://example.com/playlist_cover.jpg',
      reelIds: [],
      creatorId: 'current_user_id',
      createdAt: DateTime.now(),
    );
    emit(PlaylistCreated(playlist: playlist));
  }

  void _onAddToPlaylist(AddToPlaylist event, Emitter<ReelsState> emit) async {
    emit(AddingToPlaylist());
    await Future.delayed(const Duration(seconds: 1));
    emit(AddedToPlaylist(
      reelId: event.reelId,
      playlistId: event.playlistId,
    ));
  }

  List<Reel> _generateMockReels() {
    return [
      Reel(
        id: 'reel_1',
        userId: 'user_1',
        username: 'creator_one',
        userAvatar: 'https://example.com/avatar1.jpg',
        videoUrl: 'https://example.com/reel1.mp4',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        caption: 'Amazing dance moves! 💃 #dance #trending',
        hashtags: ['dance', 'trending'],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 1250,
        comments: 89,
        shares: 45,
        views: 15000,
        qualityScore: 8.5,
        isVerified: true,
        audio: ReelAudio(
          id: 'audio_1',
          title: 'Trending Beat',
          artist: 'DJ Music',
          audioUrl: 'https://example.com/audio1.mp3',
          coverUrl: 'https://example.com/audio_cover1.jpg',
          duration: 30,
          isTrending: true,
          usageCount: 5000,
        ),
        allowRemix: true,
      ),
      Reel(
        id: 'reel_2',
        userId: 'user_2',
        username: 'tech_guru',
        userAvatar: 'https://example.com/avatar2.jpg',
        videoUrl: 'https://example.com/reel2.mp4',
        thumbnailUrl: 'https://example.com/thumb2.jpg',
        caption: 'Quick coding tip! 👨‍💻 #coding #tech #programming',
        hashtags: ['coding', 'tech', 'programming'],
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 890,
        comments: 67,
        shares: 23,
        views: 8500,
        qualityScore: 9.2,
        isVerified: true,
        audio: ReelAudio(
          id: 'audio_2',
          title: 'Original Audio',
          artist: 'tech_guru',
          audioUrl: 'https://example.com/audio2.mp3',
          coverUrl: 'https://example.com/audio_cover2.jpg',
          duration: 25,
          isOriginal: true,
          usageCount: 150,
        ),
      ),
    ];
  }

  List<ReelDraft> _generateMockDrafts() {
    return [
      ReelDraft(
        id: 'draft_1',
        videoPath: '/path/to/draft1.mp4',
        caption: 'My awesome reel draft',
        hashtags: ['draft', 'awesome'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        lastModified: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  ReelInsights _generateMockInsights() {
    return ReelInsights(
      totalViews: 15000,
      totalLikes: 1250,
      totalComments: 89,
      totalShares: 45,
      totalSaves: 234,
      viewsByCountry: {'US': 5000, 'UK': 3000, 'CA': 2000},
      viewsByAge: {'18-24': 6000, '25-34': 5000, '35-44': 3000},
      viewsByGender: {'Male': 7500, 'Female': 7500},
      engagementRate: 8.5,
      reachCount: 12000,
      impressions: 18000,
    );
  }

  Reel _createReelFromDraft(ReelDraft draft) {
    return Reel(
      id: 'reel_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user_id',
      username: 'current_user',
      userAvatar: 'https://example.com/current_avatar.jpg',
      videoUrl: 'https://example.com/published_reel.mp4',
      thumbnailUrl: 'https://example.com/published_thumb.jpg',
      caption: draft.caption,
      hashtags: draft.hashtags,
      mentions: draft.mentions,
      location: draft.location,
      timestamp: DateTime.now(),
      qualityScore: 7.5,
      audio: draft.audio,
      effects: draft.effects,
    );
  }
}