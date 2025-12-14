import 'package:equatable/equatable.dart';
import '../../data/models/notification_models.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  final int page;
  final int limit;

  const LoadNotifications({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

class RefreshNotifications extends NotificationsEvent {}

class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationsEvent {}

class DeleteNotification extends NotificationsEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class ClearAllNotifications extends NotificationsEvent {}

class FilterNotificationsByType extends NotificationsEvent {
  final NotificationType? type;

  const FilterNotificationsByType(this.type);

  @override
  List<Object?> get props => [type];
}

class LoadNotificationSettings extends NotificationsEvent {}

class UpdateNotificationSettings extends NotificationsEvent {
  final NotificationSettings settings;

  const UpdateNotificationSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleNotificationSetting extends NotificationsEvent {
  final String settingKey;
  final bool value;

  const ToggleNotificationSetting(this.settingKey, this.value);

  @override
  List<Object?> get props => [settingKey, value];
}

class HandleNotificationTap extends NotificationsEvent {
  final NotificationModel notification;

  const HandleNotificationTap(this.notification);

  @override
  List<Object?> get props => [notification];
}

class RequestNotificationPermission extends NotificationsEvent {}

class RegisterForPushNotifications extends NotificationsEvent {
  final String deviceToken;

  const RegisterForPushNotifications(this.deviceToken);

  @override
  List<Object?> get props => [deviceToken];
}

class HandlePushNotification extends NotificationsEvent {
  final Map<String, dynamic> payload;

  const HandlePushNotification(this.payload);

  @override
  List<Object?> get props => [payload];
}

class GetUnreadNotificationCount extends NotificationsEvent {}

class SubscribeToNotifications extends NotificationsEvent {}

class UnsubscribeFromNotifications extends NotificationsEvent {}