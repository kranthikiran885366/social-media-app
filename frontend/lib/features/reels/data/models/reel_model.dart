class Reel {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final List<String> hashtags;
  final List<String> mentions;
  final String? location;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final double qualityScore;
  final bool isVerified;
  final bool isLiked;
  final bool isSaved;
  final bool isFollowing;
  final ReelAudio? audio;
  final List<ReelEffect> effects;
  final ReelTemplate? template;
  final bool isSponsored;
  final bool isDraft;
  final ReelInsights? insights;
  final bool allowRemix;
  final String? originalReelId;
  final ReelType type;

  Reel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    this.hashtags = const [],
    this.mentions = const [],
    this.location,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    required this.qualityScore,
    this.isVerified = false,
    this.isLiked = false,
    this.isSaved = false,
    this.isFollowing = true,
    this.audio,
    this.effects = const [],
    this.template,
    this.isSponsored = false,
    this.isDraft = false,
    this.insights,
    this.allowRemix = true,
    this.originalReelId,
    this.type = ReelType.original,
  });

  Reel copyWith({
    bool? isLiked,
    bool? isSaved,
    bool? isFollowing,
    int? likes,
    int? views,
    bool? isDraft,
  }) {
    return Reel(
      id: id,
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      caption: caption,
      hashtags: hashtags,
      mentions: mentions,
      location: location,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      comments: comments,
      shares: shares,
      views: views ?? this.views,
      qualityScore: qualityScore,
      isVerified: isVerified,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isFollowing: isFollowing ?? this.isFollowing,
      audio: audio,
      effects: effects,
      template: template,
      isSponsored: isSponsored,
      isDraft: isDraft ?? this.isDraft,
      insights: insights,
      allowRemix: allowRemix,
      originalReelId: originalReelId,
      type: type,
    );
  }
}

enum ReelType { original, remix, duet, template }

class ReelAudio {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String coverUrl;
  final int duration;
  final bool isTrending;
  final bool isOriginal;
  final int usageCount;

  ReelAudio({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.coverUrl,
    required this.duration,
    this.isTrending = false,
    this.isOriginal = false,
    this.usageCount = 0,
  });
}

class ReelEffect {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> parameters;

  ReelEffect({
    required this.id,
    required this.name,
    required this.type,
    required this.parameters,
  });
}

class ReelTemplate {
  final String id;
  final String name;
  final String previewUrl;
  final List<String> requiredClips;
  final Map<String, dynamic> settings;

  ReelTemplate({
    required this.id,
    required this.name,
    required this.previewUrl,
    required this.requiredClips,
    required this.settings,
  });
}

class ReelInsights {
  final int totalViews;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalSaves;
  final Map<String, int> viewsByCountry;
  final Map<String, int> viewsByAge;
  final Map<String, int> viewsByGender;
  final double engagementRate;
  final int reachCount;
  final int impressions;

  ReelInsights({
    required this.totalViews,
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
    required this.totalSaves,
    required this.viewsByCountry,
    required this.viewsByAge,
    required this.viewsByGender,
    required this.engagementRate,
    required this.reachCount,
    required this.impressions,
  });
}

class ReelDraft {
  final String id;
  final String videoPath;
  final String? thumbnailPath;
  final String caption;
  final List<String> hashtags;
  final List<String> mentions;
  final String? location;
  final ReelAudio? audio;
  final List<ReelEffect> effects;
  final DateTime createdAt;
  final DateTime lastModified;

  ReelDraft({
    required this.id,
    required this.videoPath,
    this.thumbnailPath,
    this.caption = '',
    this.hashtags = const [],
    this.mentions = const [],
    this.location,
    this.audio,
    this.effects = const [],
    required this.createdAt,
    required this.lastModified,
  });
}

class ReelPlaylist {
  final String id;
  final String name;
  final String description;
  final String coverUrl;
  final List<String> reelIds;
  final String creatorId;
  final DateTime createdAt;
  final bool isPublic;

  ReelPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.reelIds,
    required this.creatorId,
    required this.createdAt,
    this.isPublic = true,
  });
}