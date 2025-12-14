import 'package:equatable/equatable.dart';

class TwoFactorAuth extends Equatable {
  final bool isEnabled;
  final String? backupCodes;
  final String? qrCode;
  final String? secret;
  final DateTime? enabledAt;

  const TwoFactorAuth({
    this.isEnabled = false,
    this.backupCodes,
    this.qrCode,
    this.secret,
    this.enabledAt,
  });

  @override
  List<Object?> get props => [isEnabled, secret, enabledAt];
}

class LoginAlert extends Equatable {
  final String id;
  final String userId;
  final String deviceInfo;
  final String ipAddress;
  final String location;
  final DateTime loginTime;
  final bool isSuspicious;
  final LoginStatus status;

  const LoginAlert({
    required this.id,
    required this.userId,
    required this.deviceInfo,
    required this.ipAddress,
    required this.location,
    required this.loginTime,
    this.isSuspicious = false,
    this.status = LoginStatus.success,
  });

  @override
  List<Object?> get props => [id, userId, ipAddress, loginTime, isSuspicious];
}

enum LoginStatus { success, failed, blocked, suspicious }

class Device extends Equatable {
  final String id;
  final String name;
  final String type;
  final String os;
  final String browser;
  final String ipAddress;
  final String location;
  final DateTime lastActive;
  final bool isCurrent;
  final bool isTrusted;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.os,
    required this.browser,
    required this.ipAddress,
    required this.location,
    required this.lastActive,
    this.isCurrent = false,
    this.isTrusted = false,
  });

  @override
  List<Object?> get props => [id, name, ipAddress, lastActive, isCurrent];
}

class SecuritySettings extends Equatable {
  final bool twoFactorEnabled;
  final bool loginAlertsEnabled;
  final bool suspiciousLoginDetection;
  final bool restrictModeEnabled;
  final SensitiveContentLevel sensitiveContentLevel;
  final bool spamFilterEnabled;
  final List<String> blockedKeywords;
  final bool aiContentScanningEnabled;
  final int rateLimitThreshold;

  const SecuritySettings({
    this.twoFactorEnabled = false,
    this.loginAlertsEnabled = true,
    this.suspiciousLoginDetection = true,
    this.restrictModeEnabled = false,
    this.sensitiveContentLevel = SensitiveContentLevel.medium,
    this.spamFilterEnabled = true,
    this.blockedKeywords = const [],
    this.aiContentScanningEnabled = true,
    this.rateLimitThreshold = 100,
  });

  @override
  List<Object?> get props => [
        twoFactorEnabled,
        loginAlertsEnabled,
        suspiciousLoginDetection,
        restrictModeEnabled,
        sensitiveContentLevel,
        spamFilterEnabled,
        blockedKeywords,
        aiContentScanningEnabled,
        rateLimitThreshold,
      ];
}

enum SensitiveContentLevel { low, medium, high, strict }

class Report extends Equatable {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String? reportedContentId;
  final ReportType type;
  final ReportReason reason;
  final String description;
  final List<String> evidence;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    this.reportedContentId,
    required this.type,
    required this.reason,
    required this.description,
    this.evidence = const [],
    this.status = ReportStatus.pending,
    required this.createdAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [id, reporterId, reportedUserId, type, reason, createdAt];
}

enum ReportType { spam, impersonation, violation, harassment, other }

enum ReportReason {
  spamAccount,
  fakeAccount,
  impersonation,
  harassment,
  hateSpeech,
  violence,
  nudity,
  selfHarm,
  terrorism,
  intellectualProperty,
  other,
}

enum ReportStatus { pending, underReview, resolved, dismissed }

class ContentFilter extends Equatable {
  final String id;
  final FilterType type;
  final List<String> keywords;
  final List<String> patterns;
  final bool isActive;
  final DateTime createdAt;

  const ContentFilter({
    required this.id,
    required this.type,
    required this.keywords,
    this.patterns = const [],
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, keywords, patterns, isActive];
}

enum FilterType { spam, profanity, harassment, sensitive }

class AIContentScan extends Equatable {
  final String id;
  final String contentId;
  final ContentType contentType;
  final double toxicityScore;
  final double spamScore;
  final double qualityScore;
  final List<String> detectedIssues;
  final ScanResult result;
  final DateTime scannedAt;

  const AIContentScan({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.toxicityScore,
    required this.spamScore,
    required this.qualityScore,
    this.detectedIssues = const [],
    required this.result,
    required this.scannedAt,
  });

  @override
  List<Object?> get props => [id, contentId, contentType, result, scannedAt];
}

enum ContentType { post, comment, message, story, reel }

enum ScanResult { approved, flagged, blocked, needsReview }

class RateLimit extends Equatable {
  final String userId;
  final String action;
  final int count;
  final DateTime windowStart;
  final int maxAllowed;
  final bool isBlocked;

  const RateLimit({
    required this.userId,
    required this.action,
    required this.count,
    required this.windowStart,
    required this.maxAllowed,
    this.isBlocked = false,
  });

  @override
  List<Object?> get props => [userId, action, count, windowStart, isBlocked];
}

class SecurityIncident extends Equatable {
  final String id;
  final String userId;
  final IncidentType type;
  final String description;
  final Map<String, dynamic> metadata;
  final IncidentSeverity severity;
  final DateTime occurredAt;
  final bool isResolved;

  const SecurityIncident({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    this.metadata = const {},
    required this.severity,
    required this.occurredAt,
    this.isResolved = false,
  });

  @override
  List<Object?> get props => [id, userId, type, severity, occurredAt];
}

enum IncidentType {
  suspiciousLogin,
  multipleFailedLogins,
  accountTakeover,
  spamDetection,
  maliciousContent,
  rateLimitExceeded,
}

enum IncidentSeverity { low, medium, high, critical }