import 'package:equatable/equatable.dart';
import '../../data/models/settings_models.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrivacySettings extends SettingsEvent {}

class UpdatePrivacySettings extends SettingsEvent {
  final PrivacySettings settings;

  const UpdatePrivacySettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class TogglePrivateAccount extends SettingsEvent {
  final bool isPrivate;

  const TogglePrivateAccount(this.isPrivate);

  @override
  List<Object?> get props => [isPrivate];
}

class UpdateCommentControls extends SettingsEvent {
  final bool allowFromEveryone;
  final CommentFilterLevel filterLevel;
  final bool hideOffensive;

  const UpdateCommentControls(this.allowFromEveryone, this.filterLevel, this.hideOffensive);

  @override
  List<Object?> get props => [allowFromEveryone, filterLevel, hideOffensive];
}

class UpdateTagControls extends SettingsEvent {
  final bool allowFromEveryone;

  const UpdateTagControls(this.allowFromEveryone);

  @override
  List<Object?> get props => [allowFromEveryone];
}

class UpdateMentionControls extends SettingsEvent {
  final bool allowFromEveryone;

  const UpdateMentionControls(this.allowFromEveryone);

  @override
  List<Object?> get props => [allowFromEveryone];
}

class UpdateStoryControls extends SettingsEvent {
  final bool allowReplies;
  final bool allowSharing;

  const UpdateStoryControls(this.allowReplies, this.allowSharing);

  @override
  List<Object?> get props => [allowReplies, allowSharing];
}

class ToggleActivityStatus extends SettingsEvent {
  final bool showStatus;

  const ToggleActivityStatus(this.showStatus);

  @override
  List<Object?> get props => [showStatus];
}

class ToggleShowLikes extends SettingsEvent {
  final bool showLikes;

  const ToggleShowLikes(this.showLikes);

  @override
  List<Object?> get props => [showLikes];
}

class LoadBlockedAccounts extends SettingsEvent {}

class BlockAccount extends SettingsEvent {
  final String userId;

  const BlockAccount(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnblockAccount extends SettingsEvent {
  final String userId;

  const UnblockAccount(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadMutedAccounts extends SettingsEvent {}

class MuteAccount extends SettingsEvent {
  final String userId;
  final bool muteStories;
  final bool mutePosts;

  const MuteAccount(this.userId, {this.muteStories = true, this.mutePosts = true});

  @override
  List<Object?> get props => [userId, muteStories, mutePosts];
}

class UnmuteAccount extends SettingsEvent {
  final String userId;

  const UnmuteAccount(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadRestrictedAccounts extends SettingsEvent {}

class RestrictAccount extends SettingsEvent {
  final String userId;

  const RestrictAccount(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnrestrictAccount extends SettingsEvent {
  final String userId;

  const UnrestrictAccount(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadNotificationSettings extends SettingsEvent {}

class UpdateNotificationSettings extends SettingsEvent {
  final NotificationSettings settings;

  const UpdateNotificationSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class LoadAppSettings extends SettingsEvent {}

class UpdateAppSettings extends SettingsEvent {
  final AppSettings settings;

  const UpdateAppSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ChangeLanguage extends SettingsEvent {
  final String languageCode;

  const ChangeLanguage(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class RequestDataExport extends SettingsEvent {}

class LoadDataExportRequests extends SettingsEvent {}

class DownloadDataExport extends SettingsEvent {
  final String requestId;

  const DownloadDataExport(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class DeactivateAccount extends SettingsEvent {
  final String reason;

  const DeactivateAccount(this.reason);

  @override
  List<Object?> get props => [reason];
}

class ReactivateAccount extends SettingsEvent {}

class RequestAccountDeletion extends SettingsEvent {
  final String reason;

  const RequestAccountDeletion(this.reason);

  @override
  List<Object?> get props => [reason];
}

class CancelAccountDeletion extends SettingsEvent {
  final String requestId;

  const CancelAccountDeletion(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class CreateSupportTicket extends SettingsEvent {
  final String subject;
  final String description;
  final TicketCategory category;
  final List<String> attachments;

  const CreateSupportTicket(
    this.subject,
    this.description,
    this.category, {
    this.attachments = const [],
  });

  @override
  List<Object?> get props => [subject, description, category, attachments];
}

class LoadSupportTickets extends SettingsEvent {}

class ReportProblem extends SettingsEvent {
  final String description;
  final String category;
  final List<String> attachments;

  const ReportProblem(this.description, this.category, {this.attachments = const []});

  @override
  List<Object?> get props => [description, category, attachments];
}