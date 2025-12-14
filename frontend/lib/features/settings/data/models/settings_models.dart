import 'package:equatable/equatable.dart';

class PrivacySettings extends Equatable {
  final bool isPrivateAccount;
  final bool allowCommentsFromEveryone;
  final bool allowTagsFromEveryone;
  final bool allowMentionsFromEveryone;
  final bool allowStoryReplies;
  final bool allowStorySharing;
  final bool showActivityStatus;
  final bool showLikesCount;
  final CommentFilterLevel commentFilterLevel;
  final bool hideOffensiveComments;

  const PrivacySettings({
    this.isPrivateAccount = false,
    this.allowCommentsFromEveryone = true,
    this.allowTagsFromEveryone = true,
    this.allowMentionsFromEveryone = true,
    this.allowStoryReplies = true,
    this.allowStorySharing = true,
    this.showActivityStatus = true,
    this.showLikesCount = true,
    this.commentFilterLevel = CommentFilterLevel.some,
    this.hideOffensiveComments = true,
  });

  @override
  List<Object?> get props => [
        isPrivateAccount,
        allowCommentsFromEveryone,
        allowTagsFromEveryone,
        allowMentionsFromEveryone,
        allowStoryReplies,
        allowStorySharing,
        showActivityStatus,
        showLikesCount,
        commentFilterLevel,
        hideOffensiveComments,
      ];
}

enum CommentFilterLevel { off, some, most }

class NotificationSettings extends Equatable {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool likesNotifications;
  final bool commentsNotifications;
  final bool followersNotifications;
  final bool mentionsNotifications;
  final bool directMessagesNotifications;
  final bool liveNotifications;
  final bool reminderNotifications;

  const NotificationSettings({
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.smsNotifications = false,
    this.likesNotifications = true,
    this.commentsNotifications = true,
    this.followersNotifications = true,
    this.mentionsNotifications = true,
    this.directMessagesNotifications = true,
    this.liveNotifications = true,
    this.reminderNotifications = true,
  });

  @override
  List<Object?> get props => [
        pushNotifications,
        emailNotifications,
        smsNotifications,
        likesNotifications,
        commentsNotifications,
        followersNotifications,
        mentionsNotifications,
        directMessagesNotifications,
        liveNotifications,
        reminderNotifications,
      ];
}

class BlockedAccount extends Equatable {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatar;
  final DateTime blockedAt;

  const BlockedAccount({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatar,
    required this.blockedAt,
  });

  @override
  List<Object?> get props => [userId, username, blockedAt];
}

class MutedAccount extends Equatable {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatar;
  final DateTime mutedAt;
  final bool muteStories;
  final bool mutePosts;

  const MutedAccount({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatar,
    required this.mutedAt,
    this.muteStories = true,
    this.mutePosts = true,
  });

  @override
  List<Object?> get props => [userId, username, mutedAt, muteStories, mutePosts];
}

class RestrictedAccount extends Equatable {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatar;
  final DateTime restrictedAt;

  const RestrictedAccount({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatar,
    required this.restrictedAt,
  });

  @override
  List<Object?> get props => [userId, username, restrictedAt];
}

class AppSettings extends Equatable {
  final String language;
  final String theme;
  final bool autoPlayVideos;
  final bool useCellularData;
  final bool highQualityUploads;
  final bool saveOriginalPhotos;

  const AppSettings({
    this.language = 'en',
    this.theme = 'system',
    this.autoPlayVideos = true,
    this.useCellularData = true,
    this.highQualityUploads = false,
    this.saveOriginalPhotos = false,
  });

  @override
  List<Object?> get props => [
        language,
        theme,
        autoPlayVideos,
        useCellularData,
        highQualityUploads,
        saveOriginalPhotos,
      ];
}

class DataExportRequest extends Equatable {
  final String id;
  final String userId;
  final ExportStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? downloadUrl;
  final int? fileSizeBytes;

  const DataExportRequest({
    required this.id,
    required this.userId,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.downloadUrl,
    this.fileSizeBytes,
  });

  @override
  List<Object?> get props => [id, userId, status, requestedAt];
}

enum ExportStatus { pending, processing, completed, failed }

class AccountDeletionRequest extends Equatable {
  final String id;
  final String userId;
  final String reason;
  final DateTime requestedAt;
  final DateTime scheduledDeletionAt;
  final bool canCancel;

  const AccountDeletionRequest({
    required this.id,
    required this.userId,
    required this.reason,
    required this.requestedAt,
    required this.scheduledDeletionAt,
    this.canCancel = true,
  });

  @override
  List<Object?> get props => [id, userId, requestedAt, scheduledDeletionAt];
}

class SupportTicket extends Equatable {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final TicketCategory category;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<String> attachments;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.category,
    this.status = TicketStatus.open,
    required this.createdAt,
    this.resolvedAt,
    this.attachments = const [],
  });

  @override
  List<Object?> get props => [id, userId, subject, category, status, createdAt];
}

enum TicketCategory { technical, account, privacy, content, billing, other }

enum TicketStatus { open, inProgress, resolved, closed }