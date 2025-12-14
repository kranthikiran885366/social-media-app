class SearchResult {
  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int? followersCount;
  final int? postsCount;
  final bool isVerified;
  final bool isFollowing;
  final double relevanceScore;
  final Map<String, dynamic> metadata;

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.followersCount,
    this.postsCount,
    this.isVerified = false,
    this.isFollowing = false,
    required this.relevanceScore,
    this.metadata = const {},
  });
}

enum SearchResultType { account, hashtag, sound, location, post, reel }

class SearchAccount {
  final String id;
  final String username;
  final String fullName;
  final String avatar;
  final bool isVerified;
  final bool isFollowing;
  final int followersCount;
  final int postsCount;
  final String? bio;
  final String? category;

  SearchAccount({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatar,
    this.isVerified = false,
    this.isFollowing = false,
    required this.followersCount,
    required this.postsCount,
    this.bio,
    this.category,
  });
}

class SearchHashtag {
  final String id;
  final String name;
  final int postsCount;
  final bool isTrending;
  final String? description;
  final String? thumbnailUrl;
  final List<String> relatedHashtags;

  SearchHashtag({
    required this.id,
    required this.name,
    required this.postsCount,
    this.isTrending = false,
    this.description,
    this.thumbnailUrl,
    this.relatedHashtags = const [],
  });
}

class SearchSound {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String coverUrl;
  final int duration;
  final int usageCount;
  final bool isTrending;
  final bool isOriginal;

  SearchSound({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.coverUrl,
    required this.duration,
    required this.usageCount,
    this.isTrending = false,
    this.isOriginal = false,
  });
}

class SearchLocation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int postsCount;
  final String? category;
  final String? thumbnailUrl;

  SearchLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.postsCount,
    this.category,
    this.thumbnailUrl,
  });
}

class SearchPost {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String thumbnailUrl;
  final String caption;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final bool isVideo;

  SearchPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.thumbnailUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.isVideo = false,
  });
}

class SearchSuggestion {
  final String id;
  final String text;
  final SearchResultType type;
  final String? iconUrl;
  final bool isTrending;

  SearchSuggestion({
    required this.id,
    required this.text,
    required this.type,
    this.iconUrl,
    this.isTrending = false,
  });
}

class RecentSearch {
  final String id;
  final String query;
  final SearchResultType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  RecentSearch({
    required this.id,
    required this.query,
    required this.type,
    required this.timestamp,
    this.metadata = const {},
  });
}

class TrendingSearch {
  final String id;
  final String query;
  final SearchResultType type;
  final int searchCount;
  final double trendingScore;
  final String? description;

  TrendingSearch({
    required this.id,
    required this.query,
    required this.type,
    required this.searchCount,
    required this.trendingScore,
    this.description,
  });
}