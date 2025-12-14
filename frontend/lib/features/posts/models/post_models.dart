import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final bool isVerified;
  final String caption;
  final List<PostMedia> media;
  final PostLocation? location;
  final List<UserTag> taggedUsers;
  final List<ProductTag> taggedProducts;
  final List<String> hashtags;
  final List<String> mentions;
  final String? altText;
  final PostSettings settings;
  final PostInsights insights;
  final List<String> likes;
  final List<PostComment> comments;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final PostStatus status;
  final bool isArchived;
  final List<String> collaborators;
  final PostPromotion? promotion;

  const Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    this.isVerified = false,
    required this.caption,
    required this.media,
    this.location,
    this.taggedUsers = const [],
    this.taggedProducts = const [],
    this.hashtags = const [],
    this.mentions = const [],
    this.altText,
    required this.settings,
    required this.insights,
    this.likes = const [],
    this.comments = const [],
    required this.createdAt,
    this.scheduledAt,
    this.status = PostStatus.published,
    this.isArchived = false,
    this.collaborators = const [],
    this.promotion,
  });

  @override
  List<Object?> get props => [id, userId, caption, media, createdAt, status];
}

class PostMedia extends Equatable {
  final String id;
  final String url;
  final String? thumbnail;
  final MediaType type;
  final double width;
  final double height;
  final double? duration;
  final PostFilter? filter;
  final MediaAdjustments adjustments;
  final CropData? cropData;

  const PostMedia({
    required this.id,
    required this.url,
    this.thumbnail,
    required this.type,
    required this.width,
    required this.height,
    this.duration,
    this.filter,
    this.adjustments = const MediaAdjustments(),
    this.cropData,
  });

  @override
  List<Object?> get props => [id, url, type, width, height];
}

enum MediaType { photo, video }

class PostFilter extends Equatable {
  final String id;
  final String name;
  final double intensity;

  const PostFilter({
    required this.id,
    required this.name,
    this.intensity = 1.0,
  });

  @override
  List<Object?> get props => [id, name, intensity];
}

class MediaAdjustments extends Equatable {
  final double brightness;
  final double contrast;
  final double saturation;
  final double warmth;
  final double highlights;
  final double shadows;

  const MediaAdjustments({
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.warmth = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
  });

  @override
  List<Object?> get props => [brightness, contrast, saturation, warmth];
}

class PostLocation extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const PostLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude];
}

class UserTag extends Equatable {
  final String userId;
  final String username;
  final double x;
  final double y;

  const UserTag({
    required this.userId,
    required this.username,
    required this.x,
    required this.y,
  });

  @override
  List<Object?> get props => [userId, x, y];
}

class ProductTag extends Equatable {
  final String productId;
  final String name;
  final String brand;
  final double price;
  final double x;
  final double y;

  const ProductTag({
    required this.productId,
    required this.name,
    required this.brand,
    required this.price,
    required this.x,
    required this.y,
  });

  @override
  List<Object?> get props => [productId, name, x, y];
}

class PostSettings extends Equatable {
  final bool hideLikeCount;
  final bool turnOffComments;
  final PostVisibility visibility;

  const PostSettings({
    this.hideLikeCount = false,
    this.turnOffComments = false,
    this.visibility = PostVisibility.public,
  });

  @override
  List<Object?> get props => [hideLikeCount, turnOffComments, visibility];
}

enum PostVisibility { public, followers, closeFriends }

class PostInsights extends Equatable {
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final int reach;

  const PostInsights({
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.reach = 0,
  });

  @override
  List<Object?> get props => [views, likes, comments, shares, saves];
}

class PostComment extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String avatar;
  final String text;
  final List<String> likes;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.text,
    this.likes = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, text, createdAt];
}

enum PostStatus { draft, scheduled, published, archived, deleted }

class PostPromotion extends Equatable {
  final String id;
  final String campaignName;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;

  const PostPromotion({
    required this.id,
    required this.campaignName,
    required this.budget,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [id, campaignName, budget];
}

class PostDraft extends Equatable {
  final String id;
  final String userId;
  final String caption;
  final List<String> mediaPaths;
  final DateTime createdAt;

  const PostDraft({
    required this.id,
    required this.userId,
    required this.caption,
    required this.mediaPaths,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, caption, createdAt];
}