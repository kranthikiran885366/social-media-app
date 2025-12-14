import 'package:equatable/equatable.dart';
import '../../data/models/notification_models.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final bool hasReachedMax;
  final int unreadCount;
  final NotificationType? activeFilter;

  const NotificationsLoaded({
    required this.notifications,
    this.hasReachedMax = false,
    this.unreadCount = 0,
    this.activeFilter,
  });

  NotificationsLoaded copyWith({
    List<NotificationModel>? notifications,
    bool? hasReachedMax,
    int? unreadCount,
    NotificationType? activeFilter,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadCount: unreadCount ?? this.unreadCount,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [notifications, hasReachedMax, unreadCount, activeFilter];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationSettingsLoading extends NotificationsState {}

class NotificationSettingsLoaded extends NotificationsState {
  final NotificationSettings settings;

  const NotificationSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class NotificationSettingsError extends NotificationsState {
  final String message;

  const NotificationSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationPermissionRequested extends NotificationsState {}

class NotificationPermissionGranted extends NotificationsState {}

class NotificationPermissionDenied extends NotificationsState {}

class PushNotificationRegistered extends NotificationsState {
  final String deviceToken;

  const PushNotificationRegistered(this.deviceToken);

  @override
  List<Object?> get props => [deviceToken];
}

class NotificationHandled extends NotificationsState {
  final NotificationModel notification;
  final String? navigationRoute;

  const NotificationHandled(this.notification, {this.navigationRoute});

  @override
  List<Object?> get props => [notification, navigationRoute];
}

class NotificationsSubscribed extends NotificationsState {}

class NotificationsUnsubscribed extends NotificationsState {}

class NotificationMarkedAsRead extends NotificationsState {
  final String notificationId;

  const NotificationMarkedAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class AllNotificationsMarkedAsRead extends NotificationsState {}

class NotificationDeleted extends NotificationsState {
  final String notificationId;

  const NotificationDeleted(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class AllNotificationsCleared extends NotificationsState {}

class NotificationSettingUpdated extends NotificationsState {
  final String settingKey;
  final bool value;

  const NotificationSettingUpdated(this.settingKey, this.value);

  @override
  List<Object?> get props => [settingKey, value];
}