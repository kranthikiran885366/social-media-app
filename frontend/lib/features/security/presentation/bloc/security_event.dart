import 'package:equatable/equatable.dart';
import '../../data/models/security_models.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class EnableTwoFactorAuth extends SecurityEvent {
  final String password;

  const EnableTwoFactorAuth(this.password);

  @override
  List<Object?> get props => [password];
}

class DisableTwoFactorAuth extends SecurityEvent {
  final String password;
  final String? backupCode;

  const DisableTwoFactorAuth(this.password, {this.backupCode});

  @override
  List<Object?> get props => [password, backupCode];
}

class VerifyTwoFactorCode extends SecurityEvent {
  final String code;

  const VerifyTwoFactorCode(this.code);

  @override
  List<Object?> get props => [code];
}

class GenerateBackupCodes extends SecurityEvent {}

class LoadLoginAlerts extends SecurityEvent {}

class LoadDevices extends SecurityEvent {}

class RemoveDevice extends SecurityEvent {
  final String deviceId;

  const RemoveDevice(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class TrustDevice extends SecurityEvent {
  final String deviceId;

  const TrustDevice(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class ChangePassword extends SecurityEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePassword(this.currentPassword, this.newPassword);

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ReportSpamAccount extends SecurityEvent {
  final String userId;
  final String description;
  final List<String> evidence;

  const ReportSpamAccount(this.userId, this.description, {this.evidence = const []});

  @override
  List<Object?> get props => [userId, description, evidence];
}

class ReportImpersonation extends SecurityEvent {
  final String userId;
  final String description;
  final List<String> evidence;

  const ReportImpersonation(this.userId, this.description, {this.evidence = const []});

  @override
  List<Object?> get props => [userId, description, evidence];
}

class ReportViolation extends SecurityEvent {
  final String userId;
  final String? contentId;
  final ReportReason reason;
  final String description;
  final List<String> evidence;

  const ReportViolation(
    this.userId,
    this.reason,
    this.description, {
    this.contentId,
    this.evidence = const [],
  });

  @override
  List<Object?> get props => [userId, contentId, reason, description, evidence];
}

class LoadSecuritySettings extends SecurityEvent {}

class UpdateSecuritySettings extends SecurityEvent {
  final SecuritySettings settings;

  const UpdateSecuritySettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleRestrictMode extends SecurityEvent {
  final bool enabled;

  const ToggleRestrictMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateSensitiveContentLevel extends SecurityEvent {
  final SensitiveContentLevel level;

  const UpdateSensitiveContentLevel(this.level);

  @override
  List<Object?> get props => [level];
}

class AddBlockedKeyword extends SecurityEvent {
  final String keyword;

  const AddBlockedKeyword(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class RemoveBlockedKeyword extends SecurityEvent {
  final String keyword;

  const RemoveBlockedKeyword(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class ScanContent extends SecurityEvent {
  final String contentId;
  final ContentType contentType;
  final String content;

  const ScanContent(this.contentId, this.contentType, this.content);

  @override
  List<Object?> get props => [contentId, contentType, content];
}

class CheckRateLimit extends SecurityEvent {
  final String action;

  const CheckRateLimit(this.action);

  @override
  List<Object?> get props => [action];
}

class DetectSuspiciousLogin extends SecurityEvent {
  final String ipAddress;
  final String deviceInfo;
  final String location;

  const DetectSuspiciousLogin(this.ipAddress, this.deviceInfo, this.location);

  @override
  List<Object?> get props => [ipAddress, deviceInfo, location];
}

class LoadSecurityIncidents extends SecurityEvent {}

class ResolveSecurityIncident extends SecurityEvent {
  final String incidentId;

  const ResolveSecurityIncident(this.incidentId);

  @override
  List<Object?> get props => [incidentId];
}

class LoadReports extends SecurityEvent {}

class UpdateReportStatus extends SecurityEvent {
  final String reportId;
  final ReportStatus status;

  const UpdateReportStatus(this.reportId, this.status);

  @override
  List<Object?> get props => [reportId, status];
}