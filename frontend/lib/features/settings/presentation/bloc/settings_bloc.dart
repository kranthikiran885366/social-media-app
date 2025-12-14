import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/settings_models.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  PrivacySettings _privacySettings = const PrivacySettings();
  NotificationSettings _notificationSettings = const NotificationSettings();
  AppSettings _appSettings = const AppSettings();
  List<BlockedAccount> _blockedAccounts = [];
  List<MutedAccount> _mutedAccounts = [];
  List<RestrictedAccount> _restrictedAccounts = [];
  List<DataExportRequest> _dataExportRequests = [];
  List<SupportTicket> _supportTickets = [];

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadPrivacySettings>(_onLoadPrivacySettings);
    on<UpdatePrivacySettings>(_onUpdatePrivacySettings);
    on<TogglePrivateAccount>(_onTogglePrivateAccount);
    on<UpdateCommentControls>(_onUpdateCommentControls);
    on<UpdateTagControls>(_onUpdateTagControls);
    on<UpdateMentionControls>(_onUpdateMentionControls);
    on<UpdateStoryControls>(_onUpdateStoryControls);
    on<ToggleActivityStatus>(_onToggleActivityStatus);
    on<ToggleShowLikes>(_onToggleShowLikes);
    on<LoadBlockedAccounts>(_onLoadBlockedAccounts);
    on<BlockAccount>(_onBlockAccount);
    on<UnblockAccount>(_onUnblockAccount);
    on<LoadMutedAccounts>(_onLoadMutedAccounts);
    on<MuteAccount>(_onMuteAccount);
    on<UnmuteAccount>(_onUnmuteAccount);
    on<LoadRestrictedAccounts>(_onLoadRestrictedAccounts);
    on<RestrictAccount>(_onRestrictAccount);
    on<UnrestrictAccount>(_onUnrestrictAccount);
    on<LoadNotificationSettings>(_onLoadNotificationSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<LoadAppSettings>(_onLoadAppSettings);
    on<UpdateAppSettings>(_onUpdateAppSettings);
    on<ChangeLanguage>(_onChangeLanguage);
    on<RequestDataExport>(_onRequestDataExport);
    on<LoadDataExportRequests>(_onLoadDataExportRequests);
    on<DownloadDataExport>(_onDownloadDataExport);
    on<DeactivateAccount>(_onDeactivateAccount);
    on<ReactivateAccount>(_onReactivateAccount);
    on<RequestAccountDeletion>(_onRequestAccountDeletion);
    on<CancelAccountDeletion>(_onCancelAccountDeletion);
    on<CreateSupportTicket>(_onCreateSupportTicket);
    on<LoadSupportTickets>(_onLoadSupportTickets);
    on<ReportProblem>(_onReportProblem);
  }

  Future<void> _onLoadPrivacySettings(LoadPrivacySettings event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(PrivacySettingsLoaded(_privacySettings));
    } catch (e) {
      emit(const SettingsError('Failed to load privacy settings'));
    }
  }

  Future<void> _onUpdatePrivacySettings(UpdatePrivacySettings event, Emitter<SettingsState> emit) async {
    try {
      _privacySettings = event.settings;
      emit(PrivacySettingsUpdated(_privacySettings));
    } catch (e) {
      emit(const SettingsError('Failed to update privacy settings'));
    }
  }

  Future<void> _onTogglePrivateAccount(TogglePrivateAccount event, Emitter<SettingsState> emit) async {
    try {
      _privacySettings = PrivacySettings(
        isPrivateAccount: event.isPrivate,
        allowCommentsFromEveryone: _privacySettings.allowCommentsFromEveryone,
        allowTagsFromEveryone: _privacySettings.allowTagsFromEveryone,
        allowMentionsFromEveryone: _privacySettings.allowMentionsFromEveryone,
        allowStoryReplies: _privacySettings.allowStoryReplies,
        allowStorySharing: _privacySettings.allowStorySharing,
        showActivityStatus: _privacySettings.showActivityStatus,
        showLikesCount: _privacySettings.showLikesCount,
        commentFilterLevel: _privacySettings.commentFilterLevel,
        hideOffensiveComments: _privacySettings.hideOffensiveComments,
      );
      emit(PrivacySettingsUpdated(_privacySettings));
    } catch (e) {
      emit(const SettingsError('Failed to toggle private account'));
    }
  }

  Future<void> _onUpdateCommentControls(UpdateCommentControls event, Emitter<SettingsState> emit) async {
    try {
      _privacySettings = PrivacySettings(
        isPrivateAccount: _privacySettings.isPrivateAccount,
        allowCommentsFromEveryone: event.allowFromEveryone,
        allowTagsFromEveryone: _privacySettings.allowTagsFromEveryone,
        allowMentionsFromEveryone: _privacySettings.allowMentionsFromEveryone,
        allowStoryReplies: _privacySettings.allowStoryReplies,
        allowStorySharing: _privacySettings.allowStorySharing,
        showActivityStatus: _privacySettings.showActivityStatus,
        showLikesCount: _privacySettings.showLikesCount,
        commentFilterLevel: event.filterLevel,
        hideOffensiveComments: event.hideOffensive,
      );
      emit(PrivacySettingsUpdated(_privacySettings));
    } catch (e) {
      emit(const SettingsError('Failed to update comment controls'));
    }
  }

  Future<void> _onUpdateTagControls(UpdateTagControls event, Emitter<SettingsState> emit) async {
    try {
      _privacySettings = PrivacySettings(
        isPrivateAccount: _privacySettings.isPrivateAccount,
        allowCommentsFromEveryone: _privacySettings.allowCommentsFromEveryone,
        allowTagsFromEveryone: event.allowFromEveryone,
        allowMentionsFromEveryone: _privacySettings.allowMentionsFromEveryone,
        allowStoryReplies: _privacySettings.allowStoryReplies,
        allowStorySharing: _privacySettings.allowStorySharing,
        showActivityStatus: _privacySettings.showActivityStatus,
        showLikesCount: _privacySettings.showLikesCount,
        commentFilterLevel: _privacySettings.commentFilterLevel,
        hideOffensiveComments: _privacySettings.hideOffensiveComments,
      );
      emit(PrivacySettingsUpdated(_privacySettings));
    } catch (e) {
      emit(const SettingsError('Failed to update tag controls'));
    }
  }

  Future<void> _onUpdateMentionControls(UpdateMentionControls event, Emitter<SettingsState> emit) async {
    try {
      _privacySettings = PrivacySettings(
        isPrivateAccount: _privacySettings.isPrivateAccount,
        allowCommentsFromEveryone: _privacySettings.allowCommentsFromEveryone,
        allowTagsFromEveryone: _privacySettings.allowTagsFromEveryone,
        allowMentionsFromEveryone: event.allowFromEveryone,
        allowStoryReplies: _privacySettings.allowStoryReplies,
        allowStorySharing: _privacySettings.allowStorySharing,
        showActivityStatus: _privacySettings.showActivityStatus,
        showLikesCount: _privacySettings.showLikesCount,
        commentFilterLevel: _privacySettings.commentFilterLevel,
        hideOffensiveComments: _privacySettings.hideOffensiveComments,
      );
      emit(PrivacySettingsUpdated(_privacySettings));
    } catch (e) {
      emit(const SettingsError('Failed to update mention controls'));
    }
  }

  Future<void> _onUpdateStoryControls(UpdateStoryControls event, Emitter<SettingsState> emit) async {
    try {
      _privacySettings = PrivacySettings(
        isPrivateAccount: _privacySettings.isPrivateAccount,
        allowCommentsFromEveryone: _privacySettings.allowCommentsFromEveryone,
        allowTagsFromEveryone: _privacySettings.allowTagsFromEveryone,
        allowMentionsFromEveryone: _privacySettings.allowMentionsFromEveryone,
        allowStoryReplies: event.allowReplies,
        allowStorySharing: event.allowSharing,
        showActivityStatus: _privacySettings.showActivityStatus,
        showLikesCount: _privacySettings.showLikesCount,
        commentFilterLevel: _privacySettings.commentFilterLevel,
        hideOffensiveComments: _privacySettings.hideOffensiveComments,
      );
      emit(PrivacySettingsUpdated(_privacySettings));
    } catch (e) {
      emit(const SettingsError('Failed to update story controls'));
    }
  }

  Future<void> _onToggleActivityStatus(ToggleActivityStatus event, Emitter<SettingsState> emit) async {
    try {
      _privacySettings = PrivacySettings(
        isPrivateAccount: _privacySettings.isPrivateAccount,
        allowCommentsFromEveryone: _privacySettings.allowCommentsFromEveryone,
        allowTagsFromEveryone: _privacySettings.allowTagsFromEveryone,
        allowMentionsFromEveryone: _privacySettings.allowMentionsFromEveryone,
        allowStoryReplies: _privacySettings.allowStoryReplies,
        allowStorySharing: _privacySettings.allowStorySharing,
        showActivityStatus: event.showStatus,
        showLikesCount: _privacySettings.showLikesCount,
        commentFilterLevel: _privacySettings.commentFilterLevel,
        hideOffensiveComments: _privacySettings.hideOffensiveComments,
      );
      emit(PrivacySettingsUpdated(_privacySettings));
    } catch (e) {
      emit(const SettingsError('Failed to toggle activity status'));
    }
  }

  Future<void> _onToggleShowLikes(ToggleShowLikes event, Emitter<SettingsState> emit) async {
    try {
      _privacySettings = PrivacySettings(
        isPrivateAccount: _privacySettings.isPrivateAccount,
        allowCommentsFromEveryone: _privacySettings.allowCommentsFromEveryone,
        allowTagsFromEveryone: _privacySettings.allowTagsFromEveryone,
        allowMentionsFromEveryone: _privacySettings.allowMentionsFromEveryone,
        allowStoryReplies: _privacySettings.allowStoryReplies,
        allowStorySharing: _privacySettings.allowStorySharing,
        showActivityStatus: _privacySettings.showActivityStatus,
        showLikesCount: event.showLikes,
        commentFilterLevel: _privacySettings.commentFilterLevel,
        hideOffensiveComments: _privacySettings.hideOffensiveComments,
      );
      emit(PrivacySettingsUpdated(_privacySettings));
    } catch (e) {
      emit(const SettingsError('Failed to toggle show likes'));
    }
  }

  Future<void> _onLoadBlockedAccounts(LoadBlockedAccounts event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      _blockedAccounts = _generateMockBlockedAccounts();
      emit(BlockedAccountsLoaded(_blockedAccounts));
    } catch (e) {
      emit(const SettingsError('Failed to load blocked accounts'));
    }
  }

  Future<void> _onBlockAccount(BlockAccount event, Emitter<SettingsState> emit) async {
    try {
      final blockedAccount = BlockedAccount(
        userId: event.userId,
        username: 'user_${event.userId}',
        displayName: 'User ${event.userId}',
        avatar: 'https://picsum.photos/100/100?random=${event.userId}',
        blockedAt: DateTime.now(),
      );
      _blockedAccounts.add(blockedAccount);
      emit(AccountBlocked(event.userId));
      emit(BlockedAccountsLoaded(_blockedAccounts));
    } catch (e) {
      emit(const SettingsError('Failed to block account'));
    }
  }

  Future<void> _onUnblockAccount(UnblockAccount event, Emitter<SettingsState> emit) async {
    try {
      _blockedAccounts.removeWhere((account) => account.userId == event.userId);
      emit(AccountUnblocked(event.userId));
      emit(BlockedAccountsLoaded(_blockedAccounts));
    } catch (e) {
      emit(const SettingsError('Failed to unblock account'));
    }
  }

  Future<void> _onLoadMutedAccounts(LoadMutedAccounts event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      _mutedAccounts = _generateMockMutedAccounts();
      emit(MutedAccountsLoaded(_mutedAccounts));
    } catch (e) {
      emit(const SettingsError('Failed to load muted accounts'));
    }
  }

  Future<void> _onMuteAccount(MuteAccount event, Emitter<SettingsState> emit) async {
    try {
      final mutedAccount = MutedAccount(
        userId: event.userId,
        username: 'user_${event.userId}',
        displayName: 'User ${event.userId}',
        avatar: 'https://picsum.photos/100/100?random=${event.userId}',
        mutedAt: DateTime.now(),
        muteStories: event.muteStories,
        mutePosts: event.mutePosts,
      );
      _mutedAccounts.add(mutedAccount);
      emit(AccountMuted(event.userId));
      emit(MutedAccountsLoaded(_mutedAccounts));
    } catch (e) {
      emit(const SettingsError('Failed to mute account'));
    }
  }

  Future<void> _onUnmuteAccount(UnmuteAccount event, Emitter<SettingsState> emit) async {
    try {
      _mutedAccounts.removeWhere((account) => account.userId == event.userId);
      emit(AccountUnmuted(event.userId));
      emit(MutedAccountsLoaded(_mutedAccounts));
    } catch (e) {
      emit(const SettingsError('Failed to unmute account'));
    }
  }

  Future<void> _onLoadRestrictedAccounts(LoadRestrictedAccounts event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      _restrictedAccounts = _generateMockRestrictedAccounts();
      emit(RestrictedAccountsLoaded(_restrictedAccounts));
    } catch (e) {
      emit(const SettingsError('Failed to load restricted accounts'));
    }
  }

  Future<void> _onRestrictAccount(RestrictAccount event, Emitter<SettingsState> emit) async {
    try {
      final restrictedAccount = RestrictedAccount(
        userId: event.userId,
        username: 'user_${event.userId}',
        displayName: 'User ${event.userId}',
        avatar: 'https://picsum.photos/100/100?random=${event.userId}',
        restrictedAt: DateTime.now(),
      );
      _restrictedAccounts.add(restrictedAccount);
      emit(AccountRestricted(event.userId));
      emit(RestrictedAccountsLoaded(_restrictedAccounts));
    } catch (e) {
      emit(const SettingsError('Failed to restrict account'));
    }
  }

  Future<void> _onUnrestrictAccount(UnrestrictAccount event, Emitter<SettingsState> emit) async {
    try {
      _restrictedAccounts.removeWhere((account) => account.userId == event.userId);
      emit(AccountUnrestricted(event.userId));
      emit(RestrictedAccountsLoaded(_restrictedAccounts));
    } catch (e) {
      emit(const SettingsError('Failed to unrestrict account'));
    }
  }

  Future<void> _onLoadNotificationSettings(LoadNotificationSettings event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(NotificationSettingsLoaded(_notificationSettings));
    } catch (e) {
      emit(const SettingsError('Failed to load notification settings'));
    }
  }

  Future<void> _onUpdateNotificationSettings(UpdateNotificationSettings event, Emitter<SettingsState> emit) async {
    try {
      _notificationSettings = event.settings;
      emit(NotificationSettingsUpdated(_notificationSettings));
    } catch (e) {
      emit(const SettingsError('Failed to update notification settings'));
    }
  }

  Future<void> _onLoadAppSettings(LoadAppSettings event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(AppSettingsLoaded(_appSettings));
    } catch (e) {
      emit(const SettingsError('Failed to load app settings'));
    }
  }

  Future<void> _onUpdateAppSettings(UpdateAppSettings event, Emitter<SettingsState> emit) async {
    try {
      _appSettings = event.settings;
      emit(AppSettingsUpdated(_appSettings));
    } catch (e) {
      emit(const SettingsError('Failed to update app settings'));
    }
  }

  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<SettingsState> emit) async {
    try {
      _appSettings = AppSettings(
        language: event.languageCode,
        theme: _appSettings.theme,
        autoPlayVideos: _appSettings.autoPlayVideos,
        useCellularData: _appSettings.useCellularData,
        highQualityUploads: _appSettings.highQualityUploads,
        saveOriginalPhotos: _appSettings.saveOriginalPhotos,
      );
      emit(LanguageChanged(event.languageCode));
      emit(AppSettingsUpdated(_appSettings));
    } catch (e) {
      emit(const SettingsError('Failed to change language'));
    }
  }

  Future<void> _onRequestDataExport(RequestDataExport event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(seconds: 1));
      
      final request = DataExportRequest(
        id: 'export_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user_id',
        status: ExportStatus.pending,
        requestedAt: DateTime.now(),
      );
      
      _dataExportRequests.add(request);
      emit(DataExportRequested(request.id));
    } catch (e) {
      emit(const SettingsError('Failed to request data export'));
    }
  }

  Future<void> _onLoadDataExportRequests(LoadDataExportRequests event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(DataExportRequestsLoaded(_dataExportRequests));
    } catch (e) {
      emit(const SettingsError('Failed to load data export requests'));
    }
  }

  Future<void> _onDownloadDataExport(DownloadDataExport event, Emitter<SettingsState> emit) async {
    try {
      const downloadUrl = 'https://example.com/download/data-export.zip';
      emit(DataExportDownloaded(event.requestId, downloadUrl));
    } catch (e) {
      emit(const SettingsError('Failed to download data export'));
    }
  }

  Future<void> _onDeactivateAccount(DeactivateAccount event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(AccountDeactivated());
    } catch (e) {
      emit(const SettingsError('Failed to deactivate account'));
    }
  }

  Future<void> _onReactivateAccount(ReactivateAccount event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(AccountReactivated());
    } catch (e) {
      emit(const SettingsError('Failed to reactivate account'));
    }
  }

  Future<void> _onRequestAccountDeletion(RequestAccountDeletion event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(seconds: 1));
      
      final request = AccountDeletionRequest(
        id: 'deletion_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user_id',
        reason: event.reason,
        requestedAt: DateTime.now(),
        scheduledDeletionAt: DateTime.now().add(const Duration(days: 30)),
      );
      
      emit(AccountDeletionRequested(request));
    } catch (e) {
      emit(const SettingsError('Failed to request account deletion'));
    }
  }

  Future<void> _onCancelAccountDeletion(CancelAccountDeletion event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AccountDeletionCancelled(event.requestId));
    } catch (e) {
      emit(const SettingsError('Failed to cancel account deletion'));
    }
  }

  Future<void> _onCreateSupportTicket(CreateSupportTicket event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      
      final ticket = SupportTicket(
        id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user_id',
        subject: event.subject,
        description: event.description,
        category: event.category,
        createdAt: DateTime.now(),
        attachments: event.attachments,
      );
      
      _supportTickets.add(ticket);
      emit(SupportTicketCreated(ticket));
    } catch (e) {
      emit(const SettingsError('Failed to create support ticket'));
    }
  }

  Future<void> _onLoadSupportTickets(LoadSupportTickets event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(SupportTicketsLoaded(_supportTickets));
    } catch (e) {
      emit(const SettingsError('Failed to load support tickets'));
    }
  }

  Future<void> _onReportProblem(ReportProblem event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      
      final ticketId = 'problem_${DateTime.now().millisecondsSinceEpoch}';
      emit(ProblemReported(ticketId));
    } catch (e) {
      emit(const SettingsError('Failed to report problem'));
    }
  }

  List<BlockedAccount> _generateMockBlockedAccounts() {
    return [
      BlockedAccount(
        userId: 'blocked_1',
        username: 'blocked_user1',
        displayName: 'Blocked User 1',
        avatar: 'https://picsum.photos/100/100?random=1',
        blockedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      BlockedAccount(
        userId: 'blocked_2',
        username: 'blocked_user2',
        displayName: 'Blocked User 2',
        avatar: 'https://picsum.photos/100/100?random=2',
        blockedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  List<MutedAccount> _generateMockMutedAccounts() {
    return [
      MutedAccount(
        userId: 'muted_1',
        username: 'muted_user1',
        displayName: 'Muted User 1',
        avatar: 'https://picsum.photos/100/100?random=3',
        mutedAt: DateTime.now().subtract(const Duration(days: 3)),
        muteStories: true,
        mutePosts: false,
      ),
    ];
  }

  List<RestrictedAccount> _generateMockRestrictedAccounts() {
    return [
      RestrictedAccount(
        userId: 'restricted_1',
        username: 'restricted_user1',
        displayName: 'Restricted User 1',
        avatar: 'https://picsum.photos/100/100?random=4',
        restrictedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}