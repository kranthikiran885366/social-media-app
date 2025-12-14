import 'package:equatable/equatable.dart';
import '../../data/models/security_models.dart';

abstract class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class TwoFactorAuthLoaded extends SecurityState {
  final TwoFactorAuth twoFactorAuth;

  const TwoFactorAuthLoaded(this.twoFactorAuth);

  @override
  List<Object?> get props => [twoFactorAuth];
}

class TwoFactorAuthEnabled extends SecurityState {
  final String qrCode;
  final List<String> backupCodes;

  const TwoFactorAuthEnabled(this.qrCode, this.backupCodes);

  @override
  List<Object?> get props => [qrCode, backupCodes];
}

class TwoFactorAuthDisabled extends SecurityState {}

class TwoFactorCodeVerified extends SecurityState {}

class TwoFactorCodeInvalid extends SecurityState {}

class BackupCodesGenerated extends SecurityState {
  final List<String> backupCodes;

  const BackupCodesGenerated(this.backupCodes);

  @override
  List<Object?> get props => [backupCodes];
}

class LoginAlertsLoaded extends SecurityState {
  final List<LoginAlert> alerts;

  const LoginAlertsLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

class DevicesLoaded extends SecurityState {
  final List<Device> devices;

  const DevicesLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DeviceRemoved extends SecurityState {
  final String deviceId;

  const DeviceRemoved(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class DeviceTrusted extends SecurityState {
  final String deviceId;

  const DeviceTrusted(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class PasswordChanged extends SecurityState {}

class ReportSubmitted extends SecurityState {
  final String reportId;
  final ReportType type;

  const ReportSubmitted(this.reportId, this.type);

  @override
  List<Object?> get props => [reportId, type];
}

class SecuritySettingsLoaded extends SecurityState {
  final SecuritySettings settings;

  const SecuritySettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SecuritySettingsUpdated extends SecurityState {
  final SecuritySettings settings;

  const SecuritySettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

class RestrictModeToggled extends SecurityState {
  final bool enabled;

  const RestrictModeToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SensitiveContentLevelUpdated extends SecurityState {
  final SensitiveContentLevel level;

  const SensitiveContentLevelUpdated(this.level);

  @override
  List<Object?> get props => [level];
}

class BlockedKeywordAdded extends SecurityState {
  final String keyword;

  const BlockedKeywordAdded(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class BlockedKeywordRemoved extends SecurityState {
  final String keyword;

  const BlockedKeywordRemoved(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class ContentScanned extends SecurityState {
  final AIContentScan scanResult;

  const ContentScanned(this.scanResult);

  @override
  List<Object?> get props => [scanResult];
}

class RateLimitChecked extends SecurityState {
  final RateLimit rateLimit;

  const RateLimitChecked(this.rateLimit);

  @override
  List<Object?> get props => [rateLimit];
}

class RateLimitExceeded extends SecurityState {
  final String action;
  final int retryAfter;

  const RateLimitExceeded(this.action, this.retryAfter);

  @override
  List<Object?> get props => [action, retryAfter];
}

class SuspiciousLoginDetected extends SecurityState {
  final LoginAlert alert;

  const SuspiciousLoginDetected(this.alert);

  @override
  List<Object?> get props => [alert];
}

class SecurityIncidentsLoaded extends SecurityState {
  final List<SecurityIncident> incidents;

  const SecurityIncidentsLoaded(this.incidents);

  @override
  List<Object?> get props => [incidents];
}

class SecurityIncidentResolved extends SecurityState {
  final String incidentId;

  const SecurityIncidentResolved(this.incidentId);

  @override
  List<Object?> get props => [incidentId];
}

class ReportsLoaded extends SecurityState {
  final List<Report> reports;

  const ReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ReportStatusUpdated extends SecurityState {
  final String reportId;
  final ReportStatus status;

  const ReportStatusUpdated(this.reportId, this.status);

  @override
  List<Object?> get props => [reportId, status];
}

class SecurityError extends SecurityState {
  final String message;

  const SecurityError(this.message);

  @override
  List<Object?> get props => [message];
}