import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final bool isVerified;
  final StoryMedia media;
  final List<StoryElement> elements;
  final StorySettings settings;
  final List<StoryView> views;
  final List<StoryReply> replies;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isHighlight;
  final String? highlightId;

  const Story({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    this.isVerified = false,
    required this.media,
    this.elements = const [],
    required this.settings,
    this.views = const [],
    this.replies = const [],
    required this.createdAt,
    required this.expiresAt,
    this.isHighlight = false,
    this.highlightId,
  });

  @override
  List<Object?> get props => [id, userId, media, elements, createdAt];
}

class StoryMedia extends Equatable {
  final String url;
  final String? thumbnail;
  final MediaType type;
  final double duration;
  final double width;
  final double height;
  final String? musicUrl;
  final String? musicTitle;
  final String? musicArtist;

  const StoryMedia({
    required this.url,
    this.thumbnail,
    required this.type,
    this.duration = 15.0,
    required this.width,
    required this.height,
    this.musicUrl,
    this.musicTitle,
    this.musicArtist,
  });

  @override
  List<Object?> get props => [url, type, duration, width, height];
}

enum MediaType { photo, video, boomerang, superzoom, layout, multiCapture }

class StoryElement extends Equatable {
  final String id;
  final ElementType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final double scale;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const StoryElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
    this.scale = 1.0,
    required this.data,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, type, x, y, width, height, data];
}

enum ElementType {
  text,
  sticker,
  gif,
  poll,
  question,
  quiz,
  emojiSlider,
  music,
  link,
  location,
  hashtag,
  mention,
  countdown,
  timeWeather,
  drawing,
  arFilter
}

class StorySettings extends Equatable {
  final StoryVisibility visibility;
  final bool allowReplies;
  final bool allowSharing;
  final bool showViewers;
  final List<String> closeFriends;
  final List<String> hiddenFrom;

  const StorySettings({
    this.visibility = StoryVisibility.followers,
    this.allowReplies = true,
    this.allowSharing = true,
    this.showViewers = true,
    this.closeFriends = const [],
    this.hiddenFrom = const [],
  });

  @override
  List<Object?> get props => [visibility, allowReplies, allowSharing, showViewers];
}

enum StoryVisibility { everyone, followers, closeFriends, custom }

class StoryView extends Equatable {
  final String userId;
  final String username;
  final String avatar;
  final DateTime viewedAt;

  const StoryView({
    required this.userId,
    required this.username,
    required this.avatar,
    required this.viewedAt,
  });

  @override
  List<Object?> get props => [userId, viewedAt];
}

class StoryReply extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String avatar;
  final String message;
  final ReplyType type;
  final DateTime createdAt;

  const StoryReply({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, message, createdAt];
}

enum ReplyType { text, emoji, gif }

class StoryHighlight extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String coverUrl;
  final List<String> storyIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoryHighlight({
    required this.id,
    required this.userId,
    required this.title,
    required this.coverUrl,
    required this.storyIds,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, storyIds, updatedAt];
}

class CameraFilter extends Equatable {
  final String id;
  final String name;
  final String thumbnail;
  final FilterType type;
  final Map<String, dynamic> parameters;
  final bool isPremium;

  const CameraFilter({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.type,
    required this.parameters,
    this.isPremium = false,
  });

  @override
  List<Object?> get props => [id, name, type, parameters];
}

enum FilterType { color, beauty, ar, effect }

class ARFilter extends Equatable {
  final String id;
  final String name;
  final String creator;
  final String thumbnail;
  final String modelUrl;
  final List<String> tags;
  final int downloads;
  final double rating;

  const ARFilter({
    required this.id,
    required this.name,
    required this.creator,
    required this.thumbnail,
    required this.modelUrl,
    required this.tags,
    this.downloads = 0,
    this.rating = 0.0,
  });

  @override
  List<Object?> get props => [id, name, creator, modelUrl];
}

class StoryTemplate extends Equatable {
  final String id;
  final String name;
  final String thumbnail;
  final List<TemplateLayer> layers;
  final String category;
  final bool isPremium;

  const StoryTemplate({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.layers,
    required this.category,
    this.isPremium = false,
  });

  @override
  List<Object?> get props => [id, name, layers, category];
}

class TemplateLayer extends Equatable {
  final String type;
  final Map<String, dynamic> properties;
  final double x;
  final double y;
  final double width;
  final double height;

  const TemplateLayer({
    required this.type,
    required this.properties,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [type, properties, x, y, width, height];
}