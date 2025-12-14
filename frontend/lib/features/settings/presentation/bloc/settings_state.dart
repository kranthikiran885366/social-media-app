import 'package:equatable/equatable.dart';
import '../../data/models/settings_models.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class PrivacySettingsLoaded extends SettingsState {
  final PrivacySettings settings;

  const PrivacySettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class PrivacySettingsUpdated extends SettingsState {
  final PrivacySettings settings;

  const PrivacySettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

class BlockedAccountsLoaded extends SettingsState {
  final List<BlockedAccount> accounts;

  const BlockedAccountsLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountBlocked extends SettingsState {
  final String userId;

  const AccountBlocked(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AccountUnblocked extends SettingsState {
  final String userId;

  const AccountUnblocked(this.userId);

  @override
  List<Object?> get props => [userId];
}

class MutedAccountsLoaded extends SettingsState {
  final List<MutedAccount> accounts;

  const MutedAccountsLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountMuted extends SettingsState {
  final String userId;

  const AccountMuted(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AccountUnmuted extends SettingsState {
  final String userId;

  const AccountUnmuted(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RestrictedAccountsLoaded extends SettingsState {
  final List<RestrictedAccount> accounts;

  const RestrictedAccountsLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountRestricted extends SettingsState {
  final String userId;

  const AccountRestricted(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AccountUnrestricted extends SettingsState {
  final String userId;

  const AccountUnrestricted(this.userId);

  @override
  List<Object?> get props => [userId];
}

class NotificationSettingsLoaded extends SettingsState {
  final NotificationSettings settings;

  const NotificationSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class NotificationSettingsUpdated extends SettingsState {
  final NotificationSettings settings;

  const NotificationSettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

class AppSettingsLoaded extends SettingsState {
  final AppSettings settings;

  const AppSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class AppSettingsUpdated extends SettingsState {
  final AppSettings settings;

  const AppSettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

class LanguageChanged extends SettingsState {
  final String languageCode;

  const LanguageChanged(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class DataExportRequested extends SettingsState {
  final String requestId;

  const DataExportRequested(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class DataExportRequestsLoaded extends SettingsState {
  final List<DataExportRequest> requests;

  const DataExportRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class DataExportDownloaded extends SettingsState {
  final String requestId;
  final String downloadUrl;

  const DataExportDownloaded(this.requestId, this.downloadUrl);

  @override
  List<Object?> get props => [requestId, downloadUrl];
}

class AccountDeactivated extends SettingsState {}

class AccountReactivated extends SettingsState {}

class AccountDeletionRequested extends SettingsState {
  final AccountDeletionRequest request;

  const AccountDeletionRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class AccountDeletionCancelled extends SettingsState {
  final String requestId;

  const AccountDeletionCancelled(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class SupportTicketCreated extends SettingsState {
  final SupportTicket ticket;

  const SupportTicketCreated(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class SupportTicketsLoaded extends SettingsState {
  final List<SupportTicket> tickets;

  const SupportTicketsLoaded(this.tickets);

  @override
  List<Object?> get props => [tickets];
}

class ProblemReported extends SettingsState {
  final String ticketId;

  const ProblemReported(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}