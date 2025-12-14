import 'package:equatable/equatable.dart';

class ExploreContent extends Equatable {
  final String id;
  final String type;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String userId;
  final String username;
  final String userAvatar;
  final bool isVerified;
  final String caption;
  final List<String> hashtags;
  final ExploreCategory category;
  final int likes;
  final int views;
  final double aiScore;
  final bool isSponsored;
  final SponsoredContent? sponsoredData;
  final DateTime createdAt;
  final ExploreLocation? location;
  final List<String> tags;
  final String? musicId;
  final String? musicTitle;
  final String? musicArtist;

  const ExploreContent({
    required this.id,
    required this.type,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.userId,
    required this.username,
    required this.userAvatar,
    this.isVerified = false,
    required this.caption,
    this.hashtags = const [],
    required this.category,
    this.likes = 0,
    this.views = 0,
    this.aiScore = 5.0,
    this.isSponsored = false,
    this.sponsoredData,
    required this.createdAt,
    this.location,
    this.tags = const [],
    this.musicId,
    this.musicTitle,
    this.musicArtist,
  });

  @override
  List<Object?> get props => [id, type, mediaUrl, userId, createdAt];
}

enum ExploreCategory {
  all,
  travel,
  food,
  art,
  fashion,
  fitness,
  technology,
  music,
  nature,
  photography,
  lifestyle,
  business,
  education,
  entertainment,
  sports,
  beauty,
  diy,
  pets,
  gaming,
  science
}

class ExploreLocation extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final int postCount;

  const ExploreLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.postCount = 0,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude];
}

class TrendingHashtag extends Equatable {
  final String hashtag;
  final int postCount;
  final int trendingScore;
  final ExploreCategory category;
  final bool isRising;
  final double growthRate;

  const TrendingHashtag({
    required this.hashtag,
    required this.postCount,
    required this.trendingScore,
    required this.category,
    this.isRising = false,
    this.growthRate = 0.0,
  });

  @override
  List<Object?> get props => [hashtag, postCount, trendingScore];
}

class SuggestedAccount extends Equatable {
  final String userId;
  final String username;
  final String fullName;
  final String avatar;
  final bool isVerified;
  final bool isFollowing;
  final int followersCount;
  final String bio;
  final List<String> mutualFollowers;
  final SuggestionReason reason;
  final double relevanceScore;

  const SuggestedAccount({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.avatar,
    this.isVerified = false,
    this.isFollowing = false,
    this.followersCount = 0,
    required this.bio,
    this.mutualFollowers = const [],
    required this.reason,
    this.relevanceScore = 0.0,
  });

  @override
  List<Object?> get props => [userId, username, relevanceScore];
}

enum SuggestionReason {
  mutualFollowers,
  similarInterests,
  location,
  contacts,
  facebook,
  popular,
  newToInstagram
}

class ShoppableProduct extends Equatable {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String currency;
  final String imageUrl;
  final String productUrl;
  final List<String> tags;
  final ExploreCategory category;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final String? discount;

  const ShoppableProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.productUrl,
    this.tags = const [],
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.discount,
  });

  @override
  List<Object?> get props => [id, name, brand, price];
}

class TrendingSound extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String? coverUrl;
  final int usageCount;
  final bool isOriginal;
  final bool isTrending;
  final ExploreCategory category;
  final int duration;

  const TrendingSound({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    this.coverUrl,
    this.usageCount = 0,
    this.isOriginal = false,
    this.isTrending = false,
    required this.category,
    required this.duration,
  });

  @override
  List<Object?> get props => [id, title, artist, usageCount];
}

class SponsoredContent extends Equatable {
  final String campaignId;
  final String advertiserName;
  final String callToAction;
  final String targetUrl;
  final SponsoredType type;

  const SponsoredContent({
    required this.campaignId,
    required this.advertiserName,
    required this.callToAction,
    required this.targetUrl,
    required this.type,
  });

  @override
  List<Object?> get props => [campaignId, advertiserName, type];
}

enum SponsoredType { post, reel, story, product }

class SearchResult extends Equatable {
  final String id;
  final SearchResultType type;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final int? count;
  final Map<String, dynamic> data;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.count,
    this.data = const {},
  });

  @override
  List<Object?> get props => [id, type, title];
}

enum SearchResultType { user, hashtag, location, sound, product }

class ExploreFilter extends Equatable {
  final ExploreCategory? category;
  final ExploreLocation? location;
  final DateRange? dateRange;
  final List<String> hashtags;
  final bool includeReels;
  final bool includePosts;
  final bool includeSponsored;

  const ExploreFilter({
    this.category,
    this.location,
    this.dateRange,
    this.hashtags = const [],
    this.includeReels = true,
    this.includePosts = true,
    this.includeSponsored = true,
  });

  @override
  List<Object?> get props => [category, location, dateRange, hashtags];
}

class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

class ExploreRecommendation extends Equatable {
  final String userId;
  final List<ExploreContent> recommendedContent;
  final List<SuggestedAccount> suggestedAccounts;
  final List<TrendingHashtag> trendingHashtags;
  final List<ShoppableProduct> products;
  final List<TrendingSound> sounds;
  final DateTime generatedAt;
  final double confidenceScore;

  const ExploreRecommendation({
    required this.userId,
    this.recommendedContent = const [],
    this.suggestedAccounts = const [],
    this.trendingHashtags = const [],
    this.products = const [],
    this.sounds = const [],
    required this.generatedAt,
    this.confidenceScore = 0.0,
  });

  @override
  List<Object?> get props => [userId, generatedAt, confidenceScore];
}