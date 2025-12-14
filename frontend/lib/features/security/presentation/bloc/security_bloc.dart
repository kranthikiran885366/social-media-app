import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/security_models.dart';
import 'security_event.dart';
import 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  TwoFactorAuth _twoFactorAuth = const TwoFactorAuth();
  SecuritySettings _settings = const SecuritySettings();
  List<LoginAlert> _loginAlerts = [];
  List<Device> _devices = [];
  List<SecurityIncident> _incidents = [];
  List<Report> _reports = [];
  final Map<String, RateLimit> _rateLimits = {};

  SecurityBloc() : super(SecurityInitial()) {
    on<EnableTwoFactorAuth>(_onEnableTwoFactorAuth);
    on<DisableTwoFactorAuth>(_onDisableTwoFactorAuth);
    on<VerifyTwoFactorCode>(_onVerifyTwoFactorCode);
    on<GenerateBackupCodes>(_onGenerateBackupCodes);
    on<LoadLoginAlerts>(_onLoadLoginAlerts);
    on<LoadDevices>(_onLoadDevices);
    on<RemoveDevice>(_onRemoveDevice);
    on<TrustDevice>(_onTrustDevice);
    on<ChangePassword>(_onChangePassword);
    on<ReportSpamAccount>(_onReportSpamAccount);
    on<ReportImpersonation>(_onReportImpersonation);
    on<ReportViolation>(_onReportViolation);
    on<LoadSecuritySettings>(_onLoadSecuritySettings);
    on<UpdateSecuritySettings>(_onUpdateSecuritySettings);
    on<ToggleRestrictMode>(_onToggleRestrictMode);
    on<UpdateSensitiveContentLevel>(_onUpdateSensitiveContentLevel);
    on<AddBlockedKeyword>(_onAddBlockedKeyword);
    on<RemoveBlockedKeyword>(_onRemoveBlockedKeyword);
    on<ScanContent>(_onScanContent);
    on<CheckRateLimit>(_onCheckRateLimit);
    on<DetectSuspiciousLogin>(_onDetectSuspiciousLogin);
    on<LoadSecurityIncidents>(_onLoadSecurityIncidents);
    on<ResolveSecurityIncident>(_onResolveSecurityIncident);
    on<LoadReports>(_onLoadReports);
    on<UpdateReportStatus>(_onUpdateReportStatus);
  }

  Future<void> _onEnableTwoFactorAuth(EnableTwoFactorAuth event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      
      // Simulate password verification
      await Future.delayed(const Duration(milliseconds: 500));
      
      final secret = _generateSecret();
      final qrCode = _generateQRCode(secret);
      final backupCodes = _generateBackupCodes();
      
      _twoFactorAuth = TwoFactorAuth(
        isEnabled: true,
        secret: secret,
        qrCode: qrCode,
        backupCodes: backupCodes.join(','),
        enabledAt: DateTime.now(),
      );
      
      emit(TwoFactorAuthEnabled(qrCode, backupCodes));
    } catch (e) {
      emit(const SecurityError('Failed to enable two-factor authentication'));
    }
  }

  Future<void> _onDisableTwoFactorAuth(DisableTwoFactorAuth event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      
      _twoFactorAuth = const TwoFactorAuth();
      emit(TwoFactorAuthDisabled());
    } catch (e) {
      emit(const SecurityError('Failed to disable two-factor authentication'));
    }
  }

  Future<void> _onVerifyTwoFactorCode(VerifyTwoFactorCode event, Emitter<SecurityState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Simulate code verification
      if (event.code.length == 6 && event.code != '000000') {
        emit(TwoFactorCodeVerified());
      } else {
        emit(TwoFactorCodeInvalid());
      }
    } catch (e) {
      emit(const SecurityError('Failed to verify code'));
    }
  }

  Future<void> _onGenerateBackupCodes(GenerateBackupCodes event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      final backupCodes = _generateBackupCodes();
      emit(BackupCodesGenerated(backupCodes));
    } catch (e) {
      emit(const SecurityError('Failed to generate backup codes'));
    }
  }

  Future<void> _onLoadLoginAlerts(LoadLoginAlerts event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      _loginAlerts = _generateMockLoginAlerts();
      emit(LoginAlertsLoaded(_loginAlerts));
    } catch (e) {
      emit(const SecurityError('Failed to load login alerts'));
    }
  }

  Future<void> _onLoadDevices(LoadDevices event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      _devices = _generateMockDevices();
      emit(DevicesLoaded(_devices));
    } catch (e) {
      emit(const SecurityError('Failed to load devices'));
    }
  }

  Future<void> _onRemoveDevice(RemoveDevice event, Emitter<SecurityState> emit) async {
    try {
      _devices.removeWhere((device) => device.id == event.deviceId);
      emit(DeviceRemoved(event.deviceId));
      emit(DevicesLoaded(_devices));
    } catch (e) {
      emit(const SecurityError('Failed to remove device'));
    }
  }

  Future<void> _onTrustDevice(TrustDevice event, Emitter<SecurityState> emit) async {
    try {
      final index = _devices.indexWhere((device) => device.id == event.deviceId);
      if (index != -1) {
        _devices[index] = Device(
          id: _devices[index].id,
          name: _devices[index].name,
          type: _devices[index].type,
          os: _devices[index].os,
          browser: _devices[index].browser,
          ipAddress: _devices[index].ipAddress,
          location: _devices[index].location,
          lastActive: _devices[index].lastActive,
          isCurrent: _devices[index].isCurrent,
          isTrusted: true,
        );
      }
      
      emit(DeviceTrusted(event.deviceId));
      emit(DevicesLoaded(_devices));
    } catch (e) {
      emit(const SecurityError('Failed to trust device'));
    }
  }

  Future<void> _onChangePassword(ChangePassword event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate password change
      emit(PasswordChanged());
    } catch (e) {
      emit(const SecurityError('Failed to change password'));
    }
  }

  Future<void> _onReportSpamAccount(ReportSpamAccount event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      
      final report = Report(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        reporterId: 'current_user_id',
        reportedUserId: event.userId,
        type: ReportType.spam,
        reason: ReportReason.spamAccount,
        description: event.description,
        evidence: event.evidence,
        createdAt: DateTime.now(),
      );
      
      _reports.add(report);
      emit(ReportSubmitted(report.id, ReportType.spam));
    } catch (e) {
      emit(const SecurityError('Failed to submit spam report'));
    }
  }

  Future<void> _onReportImpersonation(ReportImpersonation event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      
      final report = Report(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        reporterId: 'current_user_id',
        reportedUserId: event.userId,
        type: ReportType.impersonation,
        reason: ReportReason.impersonation,
        description: event.description,
        evidence: event.evidence,
        createdAt: DateTime.now(),
      );
      
      _reports.add(report);
      emit(ReportSubmitted(report.id, ReportType.impersonation));
    } catch (e) {
      emit(const SecurityError('Failed to submit impersonation report'));
    }
  }

  Future<void> _onReportViolation(ReportViolation event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      
      final report = Report(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        reporterId: 'current_user_id',
        reportedUserId: event.userId,
        reportedContentId: event.contentId,
        type: ReportType.violation,
        reason: event.reason,
        description: event.description,
        evidence: event.evidence,
        createdAt: DateTime.now(),
      );
      
      _reports.add(report);
      emit(ReportSubmitted(report.id, ReportType.violation));
    } catch (e) {
      emit(const SecurityError('Failed to submit violation report'));
    }
  }

  Future<void> _onLoadSecuritySettings(LoadSecuritySettings event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      emit(SecuritySettingsLoaded(_settings));
    } catch (e) {
      emit(const SecurityError('Failed to load security settings'));
    }
  }

  Future<void> _onUpdateSecuritySettings(UpdateSecuritySettings event, Emitter<SecurityState> emit) async {
    try {
      _settings = event.settings;
      emit(SecuritySettingsUpdated(_settings));
    } catch (e) {
      emit(const SecurityError('Failed to update security settings'));
    }
  }

  Future<void> _onToggleRestrictMode(ToggleRestrictMode event, Emitter<SecurityState> emit) async {
    try {
      _settings = SecuritySettings(
        twoFactorEnabled: _settings.twoFactorEnabled,
        loginAlertsEnabled: _settings.loginAlertsEnabled,
        suspiciousLoginDetection: _settings.suspiciousLoginDetection,
        restrictModeEnabled: event.enabled,
        sensitiveContentLevel: _settings.sensitiveContentLevel,
        spamFilterEnabled: _settings.spamFilterEnabled,
        blockedKeywords: _settings.blockedKeywords,
        aiContentScanningEnabled: _settings.aiContentScanningEnabled,
        rateLimitThreshold: _settings.rateLimitThreshold,
      );
      
      emit(RestrictModeToggled(event.enabled));
      emit(SecuritySettingsLoaded(_settings));
    } catch (e) {
      emit(const SecurityError('Failed to toggle restrict mode'));
    }
  }

  Future<void> _onUpdateSensitiveContentLevel(UpdateSensitiveContentLevel event, Emitter<SecurityState> emit) async {
    try {
      _settings = SecuritySettings(
        twoFactorEnabled: _settings.twoFactorEnabled,
        loginAlertsEnabled: _settings.loginAlertsEnabled,
        suspiciousLoginDetection: _settings.suspiciousLoginDetection,
        restrictModeEnabled: _settings.restrictModeEnabled,
        sensitiveContentLevel: event.level,
        spamFilterEnabled: _settings.spamFilterEnabled,
        blockedKeywords: _settings.blockedKeywords,
        aiContentScanningEnabled: _settings.aiContentScanningEnabled,
        rateLimitThreshold: _settings.rateLimitThreshold,
      );
      
      emit(SensitiveContentLevelUpdated(event.level));
      emit(SecuritySettingsLoaded(_settings));
    } catch (e) {
      emit(const SecurityError('Failed to update sensitive content level'));
    }
  }

  Future<void> _onAddBlockedKeyword(AddBlockedKeyword event, Emitter<SecurityState> emit) async {
    try {
      final updatedKeywords = List<String>.from(_settings.blockedKeywords);
      if (!updatedKeywords.contains(event.keyword.toLowerCase())) {
        updatedKeywords.add(event.keyword.toLowerCase());
        
        _settings = SecuritySettings(
          twoFactorEnabled: _settings.twoFactorEnabled,
          loginAlertsEnabled: _settings.loginAlertsEnabled,
          suspiciousLoginDetection: _settings.suspiciousLoginDetection,
          restrictModeEnabled: _settings.restrictModeEnabled,
          sensitiveContentLevel: _settings.sensitiveContentLevel,
          spamFilterEnabled: _settings.spamFilterEnabled,
          blockedKeywords: updatedKeywords,
          aiContentScanningEnabled: _settings.aiContentScanningEnabled,
          rateLimitThreshold: _settings.rateLimitThreshold,
        );
        
        emit(BlockedKeywordAdded(event.keyword));
        emit(SecuritySettingsLoaded(_settings));
      }
    } catch (e) {
      emit(const SecurityError('Failed to add blocked keyword'));
    }
  }

  Future<void> _onRemoveBlockedKeyword(RemoveBlockedKeyword event, Emitter<SecurityState> emit) async {
    try {
      final updatedKeywords = List<String>.from(_settings.blockedKeywords);
      updatedKeywords.remove(event.keyword.toLowerCase());
      
      _settings = SecuritySettings(
        twoFactorEnabled: _settings.twoFactorEnabled,
        loginAlertsEnabled: _settings.loginAlertsEnabled,
        suspiciousLoginDetection: _settings.suspiciousLoginDetection,
        restrictModeEnabled: _settings.restrictModeEnabled,
        sensitiveContentLevel: _settings.sensitiveContentLevel,
        spamFilterEnabled: _settings.spamFilterEnabled,
        blockedKeywords: updatedKeywords,
        aiContentScanningEnabled: _settings.aiContentScanningEnabled,
        rateLimitThreshold: _settings.rateLimitThreshold,
      );
      
      emit(BlockedKeywordRemoved(event.keyword));
      emit(SecuritySettingsLoaded(_settings));
    } catch (e) {
      emit(const SecurityError('Failed to remove blocked keyword'));
    }
  }

  Future<void> _onScanContent(ScanContent event, Emitter<SecurityState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final scanResult = _performAIContentScan(event.content);
      emit(ContentScanned(scanResult));
    } catch (e) {
      emit(const SecurityError('Failed to scan content'));
    }
  }

  Future<void> _onCheckRateLimit(CheckRateLimit event, Emitter<SecurityState> emit) async {
    try {
      final userId = 'current_user_id';
      final key = '${userId}_${event.action}';
      final now = DateTime.now();
      
      if (_rateLimits.containsKey(key)) {
        final rateLimit = _rateLimits[key]!;
        
        if (now.difference(rateLimit.windowStart).inMinutes >= 1) {
          // Reset window
          _rateLimits[key] = RateLimit(
            userId: userId,
            action: event.action,
            count: 1,
            windowStart: now,
            maxAllowed: _settings.rateLimitThreshold,
          );
        } else {
          // Increment count
          final newCount = rateLimit.count + 1;
          _rateLimits[key] = RateLimit(
            userId: userId,
            action: event.action,
            count: newCount,
            windowStart: rateLimit.windowStart,
            maxAllowed: rateLimit.maxAllowed,
            isBlocked: newCount > rateLimit.maxAllowed,
          );
          
          if (newCount > rateLimit.maxAllowed) {
            emit(RateLimitExceeded(event.action, 60));
            return;
          }
        }
      } else {
        _rateLimits[key] = RateLimit(
          userId: userId,
          action: event.action,
          count: 1,
          windowStart: now,
          maxAllowed: _settings.rateLimitThreshold,
        );
      }
      
      emit(RateLimitChecked(_rateLimits[key]!));
    } catch (e) {
      emit(const SecurityError('Failed to check rate limit'));
    }
  }

  Future<void> _onDetectSuspiciousLogin(DetectSuspiciousLogin event, Emitter<SecurityState> emit) async {
    try {
      final isSuspicious = _detectSuspiciousActivity(event.ipAddress, event.location);
      
      final alert = LoginAlert(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user_id',
        deviceInfo: event.deviceInfo,
        ipAddress: event.ipAddress,
        location: event.location,
        loginTime: DateTime.now(),
        isSuspicious: isSuspicious,
        status: isSuspicious ? LoginStatus.suspicious : LoginStatus.success,
      );
      
      _loginAlerts.insert(0, alert);
      
      if (isSuspicious) {
        emit(SuspiciousLoginDetected(alert));
      }
    } catch (e) {
      emit(const SecurityError('Failed to detect suspicious login'));
    }
  }

  Future<void> _onLoadSecurityIncidents(LoadSecurityIncidents event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      _incidents = _generateMockSecurityIncidents();
      emit(SecurityIncidentsLoaded(_incidents));
    } catch (e) {
      emit(const SecurityError('Failed to load security incidents'));
    }
  }

  Future<void> _onResolveSecurityIncident(ResolveSecurityIncident event, Emitter<SecurityState> emit) async {
    try {
      final index = _incidents.indexWhere((incident) => incident.id == event.incidentId);
      if (index != -1) {
        _incidents[index] = SecurityIncident(
          id: _incidents[index].id,
          userId: _incidents[index].userId,
          type: _incidents[index].type,
          description: _incidents[index].description,
          metadata: _incidents[index].metadata,
          severity: _incidents[index].severity,
          occurredAt: _incidents[index].occurredAt,
          isResolved: true,
        );
      }
      
      emit(SecurityIncidentResolved(event.incidentId));
      emit(SecurityIncidentsLoaded(_incidents));
    } catch (e) {
      emit(const SecurityError('Failed to resolve security incident'));
    }
  }

  Future<void> _onLoadReports(LoadReports event, Emitter<SecurityState> emit) async {
    try {
      emit(SecurityLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      emit(ReportsLoaded(_reports));
    } catch (e) {
      emit(const SecurityError('Failed to load reports'));
    }
  }

  Future<void> _onUpdateReportStatus(UpdateReportStatus event, Emitter<SecurityState> emit) async {
    try {
      final index = _reports.indexWhere((report) => report.id == event.reportId);
      if (index != -1) {
        _reports[index] = Report(
          id: _reports[index].id,
          reporterId: _reports[index].reporterId,
          reportedUserId: _reports[index].reportedUserId,
          reportedContentId: _reports[index].reportedContentId,
          type: _reports[index].type,
          reason: _reports[index].reason,
          description: _reports[index].description,
          evidence: _reports[index].evidence,
          status: event.status,
          createdAt: _reports[index].createdAt,
          resolvedAt: event.status == ReportStatus.resolved ? DateTime.now() : null,
        );
      }
      
      emit(ReportStatusUpdated(event.reportId, event.status));
      emit(ReportsLoaded(_reports));
    } catch (e) {
      emit(const SecurityError('Failed to update report status'));
    }
  }

  String _generateSecret() => 'JBSWY3DPEHPK3PXP';

  String _generateQRCode(String secret) => 'otpauth://totp/SmartSocial?secret=$secret';

  List<String> _generateBackupCodes() {
    final random = Random();
    return List.generate(10, (index) => 
      '${random.nextInt(900000) + 100000}-${random.nextInt(900000) + 100000}'
    );
  }

  List<LoginAlert> _generateMockLoginAlerts() {
    return [
      LoginAlert(
        id: 'alert_1',
        userId: 'current_user_id',
        deviceInfo: 'iPhone 14 Pro',
        ipAddress: '192.168.1.100',
        location: 'New York, NY',
        loginTime: DateTime.now().subtract(const Duration(hours: 2)),
        isSuspicious: false,
        status: LoginStatus.success,
      ),
      LoginAlert(
        id: 'alert_2',
        userId: 'current_user_id',
        deviceInfo: 'Unknown Device',
        ipAddress: '203.0.113.1',
        location: 'Moscow, Russia',
        loginTime: DateTime.now().subtract(const Duration(days: 1)),
        isSuspicious: true,
        status: LoginStatus.suspicious,
      ),
    ];
  }

  List<Device> _generateMockDevices() {
    return [
      Device(
        id: 'device_1',
        name: 'iPhone 14 Pro',
        type: 'Mobile',
        os: 'iOS 17.0',
        browser: 'Safari',
        ipAddress: '192.168.1.100',
        location: 'New York, NY',
        lastActive: DateTime.now(),
        isCurrent: true,
        isTrusted: true,
      ),
      Device(
        id: 'device_2',
        name: 'MacBook Pro',
        type: 'Desktop',
        os: 'macOS 14.0',
        browser: 'Chrome',
        ipAddress: '192.168.1.101',
        location: 'New York, NY',
        lastActive: DateTime.now().subtract(const Duration(hours: 3)),
        isTrusted: true,
      ),
    ];
  }

  List<SecurityIncident> _generateMockSecurityIncidents() {
    return [
      SecurityIncident(
        id: 'incident_1',
        userId: 'current_user_id',
        type: IncidentType.suspiciousLogin,
        description: 'Login attempt from unusual location',
        severity: IncidentSeverity.medium,
        occurredAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      SecurityIncident(
        id: 'incident_2',
        userId: 'current_user_id',
        type: IncidentType.multipleFailedLogins,
        description: 'Multiple failed login attempts detected',
        severity: IncidentSeverity.high,
        occurredAt: DateTime.now().subtract(const Duration(days: 2)),
        isResolved: true,
      ),
    ];
  }

  AIContentScan _performAIContentScan(String content) {
    final random = Random();
    final toxicityScore = random.nextDouble();
    final spamScore = random.nextDouble();
    final qualityScore = random.nextDouble() * 10;
    
    final detectedIssues = <String>[];
    if (toxicityScore > 0.7) detectedIssues.add('High toxicity');
    if (spamScore > 0.8) detectedIssues.add('Potential spam');
    if (qualityScore < 3) detectedIssues.add('Low quality');
    
    ScanResult result;
    if (detectedIssues.isNotEmpty) {
      result = toxicityScore > 0.9 ? ScanResult.blocked : ScanResult.flagged;
    } else {
      result = ScanResult.approved;
    }
    
    return AIContentScan(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      contentId: 'content_${DateTime.now().millisecondsSinceEpoch}',
      contentType: ContentType.post,
      toxicityScore: toxicityScore,
      spamScore: spamScore,
      qualityScore: qualityScore,
      detectedIssues: detectedIssues,
      result: result,
      scannedAt: DateTime.now(),
    );
  }

  bool _detectSuspiciousActivity(String ipAddress, String location) {
    // Simple heuristic for suspicious activity detection
    return ipAddress.startsWith('203.') || location.contains('Russia') || location.contains('China');
  }
}