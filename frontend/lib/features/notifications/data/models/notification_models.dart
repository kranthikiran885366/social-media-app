import 'package:equatable/equatable.dart';

enum NotificationType {
  like,
  comment,
  mention,
  follow,
  storyMention,
  storyReply,
  liveVideo,
  igtvAlert,
  reelsNotification,
  taggedInPhoto,
  taggedInReel,
  suggestedAccount,
  friendSuggestion,
  newMessage,
  securityAlert,
  loginAlert,
  verificationUpdate,
  shopping,
  newFeature,
  creatorUpdate,
}

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? actionUserId;
  final String? actionUserName;
  final String? actionUserAvatar;
  final String? contentId;
  final String? contentType;
  final String? contentThumbnail;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.actionUserId,
    this.actionUserName,
    this.actionUserAvatar,
    this.contentId,
    this.contentType,
    this.contentThumbnail,
    this.metadata,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      title: json['title'],
      message: json['message'],
      actionUserId: json['actionUserId'],
      actionUserName: json['actionUserName'],
      actionUserAvatar: json['actionUserAvatar'],
      contentId: json['contentId'],
      contentType: json['contentType'],
      contentThumbnail: json['contentThumbnail'],
      metadata: json['metadata'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'actionUserId': actionUserId,
      'actionUserName': actionUserName,
      'actionUserAvatar': actionUserAvatar,
      'contentId': contentId,
      'contentType': contentType,
      'contentThumbnail': contentThumbnail,
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? actionUserId,
    String? actionUserName,
    String? actionUserAvatar,
    String? contentId,
    String? contentType,
    String? contentThumbnail,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actionUserId: actionUserId ?? this.actionUserId,
      actionUserName: actionUserName ?? this.actionUserName,
      actionUserAvatar: actionUserAvatar ?? this.actionUserAvatar,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      contentThumbnail: contentThumbnail ?? this.contentThumbnail,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        message,
        actionUserId,
        actionUserName,
        actionUserAvatar,
        contentId,
        contentType,
        contentThumbnail,
        metadata,
        isRead,
        createdAt,
        readAt,
      ];
}

class NotificationSettings extends Equatable {
  final bool likesEnabled;
  final bool commentsEnabled;
  final bool mentionsEnabled;
  final bool followersEnabled;
  final bool storyMentionsEnabled;
  final bool storyRepliesEnabled;
  final bool liveVideosEnabled;
  final bool igtvAlertsEnabled;
  final bool reelsNotificationsEnabled;
  final bool taggedInPhotoEnabled;
  final bool taggedInReelEnabled;
  final bool suggestedAccountsEnabled;
  final bool friendSuggestionsEnabled;
  final bool newMessageAlertsEnabled;
  final bool securityAlertsEnabled;
  final bool loginAlertsEnabled;
  final bool verificationUpdatesEnabled;
  final bool shoppingNotificationsEnabled;
  final bool newFeaturesEnabled;
  final bool creatorUpdatesEnabled;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool smsNotificationsEnabled;

  const NotificationSettings({
    this.likesEnabled = true,
    this.commentsEnabled = true,
    this.mentionsEnabled = true,
    this.followersEnabled = true,
    this.storyMentionsEnabled = true,
    this.storyRepliesEnabled = true,
    this.liveVideosEnabled = true,
    this.igtvAlertsEnabled = false,
    this.reelsNotificationsEnabled = true,
    this.taggedInPhotoEnabled = true,
    this.taggedInReelEnabled = true,
    this.suggestedAccountsEnabled = false,
    this.friendSuggestionsEnabled = false,
    this.newMessageAlertsEnabled = true,
    this.securityAlertsEnabled = true,
    this.loginAlertsEnabled = true,
    this.verificationUpdatesEnabled = true,
    this.shoppingNotificationsEnabled = false,
    this.newFeaturesEnabled = true,
    this.creatorUpdatesEnabled = false,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = false,
    this.smsNotificationsEnabled = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      likesEnabled: json['likesEnabled'] ?? true,
      commentsEnabled: json['commentsEnabled'] ?? true,
      mentionsEnabled: json['mentionsEnabled'] ?? true,
      followersEnabled: json['followersEnabled'] ?? true,
      storyMentionsEnabled: json['storyMentionsEnabled'] ?? true,
      storyRepliesEnabled: json['storyRepliesEnabled'] ?? true,
      liveVideosEnabled: json['liveVideosEnabled'] ?? true,
      igtvAlertsEnabled: json['igtvAlertsEnabled'] ?? false,
      reelsNotificationsEnabled: json['reelsNotificationsEnabled'] ?? true,
      taggedInPhotoEnabled: json['taggedInPhotoEnabled'] ?? true,
      taggedInReelEnabled: json['taggedInReelEnabled'] ?? true,
      suggestedAccountsEnabled: json['suggestedAccountsEnabled'] ?? false,
      friendSuggestionsEnabled: json['friendSuggestionsEnabled'] ?? false,
      newMessageAlertsEnabled: json['newMessageAlertsEnabled'] ?? true,
      securityAlertsEnabled: json['securityAlertsEnabled'] ?? true,
      loginAlertsEnabled: json['loginAlertsEnabled'] ?? true,
      verificationUpdatesEnabled: json['verificationUpdatesEnabled'] ?? true,
      shoppingNotificationsEnabled: json['shoppingNotificationsEnabled'] ?? false,
      newFeaturesEnabled: json['newFeaturesEnabled'] ?? true,
      creatorUpdatesEnabled: json['creatorUpdatesEnabled'] ?? false,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: json['emailNotificationsEnabled'] ?? false,
      smsNotificationsEnabled: json['smsNotificationsEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likesEnabled': likesEnabled,
      'commentsEnabled': commentsEnabled,
      'mentionsEnabled': mentionsEnabled,
      'followersEnabled': followersEnabled,
      'storyMentionsEnabled': storyMentionsEnabled,
      'storyRepliesEnabled': storyRepliesEnabled,
      'liveVideosEnabled': liveVideosEnabled,
      'igtvAlertsEnabled': igtvAlertsEnabled,
      'reelsNotificationsEnabled': reelsNotificationsEnabled,
      'taggedInPhotoEnabled': taggedInPhotoEnabled,
      'taggedInReelEnabled': taggedInReelEnabled,
      'suggestedAccountsEnabled': suggestedAccountsEnabled,
      'friendSuggestionsEnabled': friendSuggestionsEnabled,
      'newMessageAlertsEnabled': newMessageAlertsEnabled,
      'securityAlertsEnabled': securityAlertsEnabled,
      'loginAlertsEnabled': loginAlertsEnabled,
      'verificationUpdatesEnabled': verificationUpdatesEnabled,
      'shoppingNotificationsEnabled': shoppingNotificationsEnabled,
      'newFeaturesEnabled': newFeaturesEnabled,
      'creatorUpdatesEnabled': creatorUpdatesEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'smsNotificationsEnabled': smsNotificationsEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? likesEnabled,
    bool? commentsEnabled,
    bool? mentionsEnabled,
    bool? followersEnabled,
    bool? storyMentionsEnabled,
    bool? storyRepliesEnabled,
    bool? liveVideosEnabled,
    bool? igtvAlertsEnabled,
    bool? reelsNotificationsEnabled,
    bool? taggedInPhotoEnabled,
    bool? taggedInReelEnabled,
    bool? suggestedAccountsEnabled,
    bool? friendSuggestionsEnabled,
    bool? newMessageAlertsEnabled,
    bool? securityAlertsEnabled,
    bool? loginAlertsEnabled,
    bool? verificationUpdatesEnabled,
    bool? shoppingNotificationsEnabled,
    bool? newFeaturesEnabled,
    bool? creatorUpdatesEnabled,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
  }) {
    return NotificationSettings(
      likesEnabled: likesEnabled ?? this.likesEnabled,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      mentionsEnabled: mentionsEnabled ?? this.mentionsEnabled,
      followersEnabled: followersEnabled ?? this.followersEnabled,
      storyMentionsEnabled: storyMentionsEnabled ?? this.storyMentionsEnabled,
      storyRepliesEnabled: storyRepliesEnabled ?? this.storyRepliesEnabled,
      liveVideosEnabled: liveVideosEnabled ?? this.liveVideosEnabled,
      igtvAlertsEnabled: igtvAlertsEnabled ?? this.igtvAlertsEnabled,
      reelsNotificationsEnabled: reelsNotificationsEnabled ?? this.reelsNotificationsEnabled,
      taggedInPhotoEnabled: taggedInPhotoEnabled ?? this.taggedInPhotoEnabled,
      taggedInReelEnabled: taggedInReelEnabled ?? this.taggedInReelEnabled,
      suggestedAccountsEnabled: suggestedAccountsEnabled ?? this.suggestedAccountsEnabled,
      friendSuggestionsEnabled: friendSuggestionsEnabled ?? this.friendSuggestionsEnabled,
      newMessageAlertsEnabled: newMessageAlertsEnabled ?? this.newMessageAlertsEnabled,
      securityAlertsEnabled: securityAlertsEnabled ?? this.securityAlertsEnabled,
      loginAlertsEnabled: loginAlertsEnabled ?? this.loginAlertsEnabled,
      verificationUpdatesEnabled: verificationUpdatesEnabled ?? this.verificationUpdatesEnabled,
      shoppingNotificationsEnabled: shoppingNotificationsEnabled ?? this.shoppingNotificationsEnabled,
      newFeaturesEnabled: newFeaturesEnabled ?? this.newFeaturesEnabled,
      creatorUpdatesEnabled: creatorUpdatesEnabled ?? this.creatorUpdatesEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled: smsNotificationsEnabled ?? this.smsNotificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        likesEnabled,
        commentsEnabled,
        mentionsEnabled,
        followersEnabled,
        storyMentionsEnabled,
        storyRepliesEnabled,
        liveVideosEnabled,
        igtvAlertsEnabled,
        reelsNotificationsEnabled,
        taggedInPhotoEnabled,
        taggedInReelEnabled,
        suggestedAccountsEnabled,
        friendSuggestionsEnabled,
        newMessageAlertsEnabled,
        securityAlertsEnabled,
        loginAlertsEnabled,
        verificationUpdatesEnabled,
        shoppingNotificationsEnabled,
        newFeaturesEnabled,
        creatorUpdatesEnabled,
        pushNotificationsEnabled,
        emailNotificationsEnabled,
        smsNotificationsEnabled,
      ];
}