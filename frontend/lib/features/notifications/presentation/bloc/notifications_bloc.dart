import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/notification_models.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // StreamSubscription<RemoteMessage>? _messageSubscription;
  List<NotificationModel> _allNotifications = [];
  NotificationSettings _settings = const NotificationSettings();

  NotificationsBloc() : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<FilterNotificationsByType>(_onFilterNotificationsByType);
    on<LoadNotificationSettings>(_onLoadNotificationSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<ToggleNotificationSetting>(_onToggleNotificationSetting);
    on<HandleNotificationTap>(_onHandleNotificationTap);
    on<RequestNotificationPermission>(_onRequestNotificationPermission);
    on<RegisterForPushNotifications>(_onRegisterForPushNotifications);
    on<HandlePushNotification>(_onHandlePushNotification);
    on<GetUnreadNotificationCount>(_onGetUnreadNotificationCount);
    on<SubscribeToNotifications>(_onSubscribeToNotifications);
    on<UnsubscribeFromNotifications>(_onUnsubscribeFromNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (event.page == 1) {
        emit(NotificationsLoading());
      }

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final notifications = _generateMockNotifications(event.page, event.limit);
      
      if (event.page == 1) {
        _allNotifications = notifications;
      } else {
        _allNotifications.addAll(notifications);
      }

      final unreadCount = _allNotifications.where((n) => !n.isRead).length;
      
      emit(NotificationsLoaded(
        notifications: List.from(_allNotifications),
        hasReachedMax: notifications.length < event.limit,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError('Failed to load notifications: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    add(const LoadNotifications(page: 1));
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final index = _allNotifications.indexWhere((n) => n.id == event.notificationId);
      if (index != -1) {
        _allNotifications[index] = _allNotifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        
        final unreadCount = _allNotifications.where((n) => !n.isRead).length;
        
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          emit(currentState.copyWith(
            notifications: List.from(_allNotifications),
            unreadCount: unreadCount,
          ));
        }
        
        emit(NotificationMarkedAsRead(event.notificationId));
      }
    } catch (e) {
      emit(NotificationsError('Failed to mark notification as read'));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      _allNotifications = _allNotifications.map((n) => n.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      )).toList();
      
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        emit(currentState.copyWith(
          notifications: List.from(_allNotifications),
          unreadCount: 0,
        ));
      }
      
      emit(AllNotificationsMarkedAsRead());
    } catch (e) {
      emit(NotificationsError('Failed to mark all notifications as read'));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      _allNotifications.removeWhere((n) => n.id == event.notificationId);
      
      final unreadCount = _allNotifications.where((n) => !n.isRead).length;
      
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        emit(currentState.copyWith(
          notifications: List.from(_allNotifications),
          unreadCount: unreadCount,
        ));
      }
      
      emit(NotificationDeleted(event.notificationId));
    } catch (e) {
      emit(NotificationsError('Failed to delete notification'));
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      _allNotifications.clear();
      
      emit(const NotificationsLoaded(
        notifications: [],
        unreadCount: 0,
      ));
      
      emit(AllNotificationsCleared());
    } catch (e) {
      emit(NotificationsError('Failed to clear all notifications'));
    }
  }

  Future<void> _onFilterNotificationsByType(
    FilterNotificationsByType event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      List<NotificationModel> filteredNotifications;
      
      if (event.type == null) {
        filteredNotifications = _allNotifications;
      } else {
        filteredNotifications = _allNotifications
            .where((n) => n.type == event.type)
            .toList();
      }
      
      final unreadCount = filteredNotifications.where((n) => !n.isRead).length;
      
      emit(NotificationsLoaded(
        notifications: filteredNotifications,
        unreadCount: unreadCount,
        activeFilter: event.type,
      ));
    } catch (e) {
      emit(NotificationsError('Failed to filter notifications'));
    }
  }

  Future<void> _onLoadNotificationSettings(
    LoadNotificationSettings event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      emit(NotificationSettingsLoading());
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      emit(NotificationSettingsLoaded(_settings));
    } catch (e) {
      emit(NotificationSettingsError('Failed to load notification settings'));
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      _settings = event.settings;
      emit(NotificationSettingsLoaded(_settings));
    } catch (e) {
      emit(NotificationSettingsError('Failed to update notification settings'));
    }
  }

  Future<void> _onToggleNotificationSetting(
    ToggleNotificationSetting event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      switch (event.settingKey) {
        case 'likesEnabled':
          _settings = _settings.copyWith(likesEnabled: event.value);
          break;
        case 'commentsEnabled':
          _settings = _settings.copyWith(commentsEnabled: event.value);
          break;
        case 'mentionsEnabled':
          _settings = _settings.copyWith(mentionsEnabled: event.value);
          break;
        case 'followersEnabled':
          _settings = _settings.copyWith(followersEnabled: event.value);
          break;
        case 'pushNotificationsEnabled':
          _settings = _settings.copyWith(pushNotificationsEnabled: event.value);
          break;
      }
      
      emit(NotificationSettingUpdated(event.settingKey, event.value));
      emit(NotificationSettingsLoaded(_settings));
    } catch (e) {
      emit(NotificationSettingsError('Failed to update setting'));
    }
  }

  Future<void> _onHandleNotificationTap(
    HandleNotificationTap event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      // Mark as read if not already
      if (!event.notification.isRead) {
        add(MarkNotificationAsRead(event.notification.id));
      }
      
      // Determine navigation route based on notification type
      String? navigationRoute;
      switch (event.notification.type) {
        case NotificationType.like:
        case NotificationType.comment:
        case NotificationType.taggedInPhoto:
          navigationRoute = '/post/${event.notification.contentId}';
          break;
        case NotificationType.taggedInReel:
        case NotificationType.reelsNotification:
          navigationRoute = '/reel/${event.notification.contentId}';
          break;
        case NotificationType.follow:
        case NotificationType.mention:
          navigationRoute = '/profile/${event.notification.actionUserId}';
          break;
        case NotificationType.newMessage:
          navigationRoute = '/chat/${event.notification.actionUserId}';
          break;
        case NotificationType.storyMention:
        case NotificationType.storyReply:
          navigationRoute = '/story/${event.notification.contentId}';
          break;
        case NotificationType.liveVideo:
          navigationRoute = '/live/${event.notification.contentId}';
          break;
        default:
          navigationRoute = null;
      }
      
      emit(NotificationHandled(event.notification, navigationRoute: navigationRoute));
    } catch (e) {
      emit(NotificationsError('Failed to handle notification tap'));
    }
  }

  Future<void> _onRequestNotificationPermission(
    RequestNotificationPermission event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      emit(NotificationPermissionRequested());
      
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        emit(NotificationPermissionGranted());
        
        // Get FCM token
        // final token = await _firebaseMessaging.getToken();
        // if (token != null) {
        //   add(RegisterForPushNotifications(token));
        // }
      } else {
        emit(NotificationPermissionDenied());
      }
    } catch (e) {
      emit(NotificationsError('Failed to request notification permission'));
    }
  }

  Future<void> _onRegisterForPushNotifications(
    RegisterForPushNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      // Register device token with backend
      await Future.delayed(const Duration(milliseconds: 300));
      
      emit(PushNotificationRegistered(event.deviceToken));
    } catch (e) {
      emit(NotificationsError('Failed to register for push notifications'));
    }
  }

  Future<void> _onHandlePushNotification(
    HandlePushNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      // Convert push notification payload to NotificationModel
      final notification = NotificationModel.fromJson(event.payload);
      
      // Add to local notifications list
      _allNotifications.insert(0, notification);
      
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        emit(currentState.copyWith(
          notifications: List.from(_allNotifications),
          unreadCount: currentState.unreadCount + 1,
        ));
      }
    } catch (e) {
      emit(NotificationsError('Failed to handle push notification'));
    }
  }

  Future<void> _onGetUnreadNotificationCount(
    GetUnreadNotificationCount event,
    Emitter<NotificationsState> emit,
  ) async {
    final unreadCount = _allNotifications.where((n) => !n.isRead).length;
    
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      emit(currentState.copyWith(unreadCount: unreadCount));
    }
  }

  Future<void> _onSubscribeToNotifications(
    SubscribeToNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      // _messageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //   add(HandlePushNotification(message.data));
      // });
      
      emit(NotificationsSubscribed());
    } catch (e) {
      emit(NotificationsError('Failed to subscribe to notifications'));
    }
  }

  Future<void> _onUnsubscribeFromNotifications(
    UnsubscribeFromNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      // await _messageSubscription?.cancel();
      // _messageSubscription = null;
      
      emit(NotificationsUnsubscribed());
    } catch (e) {
      emit(NotificationsError('Failed to unsubscribe from notifications'));
    }
  }

  List<NotificationModel> _generateMockNotifications(int page, int limit) {
    final notifications = <NotificationModel>[];
    final now = DateTime.now();
    
    for (int i = 0; i < limit; i++) {
      final index = (page - 1) * limit + i;
      notifications.add(NotificationModel(
        id: 'notification_$index',
        userId: 'current_user_id',
        type: NotificationType.values[index % NotificationType.values.length],
        title: _getNotificationTitle(NotificationType.values[index % NotificationType.values.length]),
        message: _getNotificationMessage(NotificationType.values[index % NotificationType.values.length]),
        actionUserId: 'user_$index',
        actionUserName: 'User $index',
        actionUserAvatar: 'https://picsum.photos/100/100?random=$index',
        contentId: 'content_$index',
        contentType: 'post',
        contentThumbnail: 'https://picsum.photos/200/200?random=$index',
        isRead: index % 3 == 0,
        createdAt: now.subtract(Duration(hours: index)),
      ));
    }
    
    return notifications;
  }

  String _getNotificationTitle(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return 'New Like';
      case NotificationType.comment:
        return 'New Comment';
      case NotificationType.mention:
        return 'You were mentioned';
      case NotificationType.follow:
        return 'New Follower';
      case NotificationType.storyMention:
        return 'Story Mention';
      case NotificationType.storyReply:
        return 'Story Reply';
      case NotificationType.liveVideo:
        return 'Live Video';
      case NotificationType.igtvAlert:
        return 'IGTV Alert';
      case NotificationType.reelsNotification:
        return 'Reels Update';
      case NotificationType.taggedInPhoto:
        return 'Tagged in Photo';
      case NotificationType.taggedInReel:
        return 'Tagged in Reel';
      case NotificationType.suggestedAccount:
        return 'Suggested Account';
      case NotificationType.friendSuggestion:
        return 'Friend Suggestion';
      case NotificationType.newMessage:
        return 'New Message';
      case NotificationType.securityAlert:
        return 'Security Alert';
      case NotificationType.loginAlert:
        return 'Login Alert';
      case NotificationType.verificationUpdate:
        return 'Verification Update';
      case NotificationType.shopping:
        return 'Shopping Update';
      case NotificationType.newFeature:
        return 'New Feature';
      case NotificationType.creatorUpdate:
        return 'Creator Update';
    }
  }

  String _getNotificationMessage(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return 'liked your post';
      case NotificationType.comment:
        return 'commented on your post';
      case NotificationType.mention:
        return 'mentioned you in a comment';
      case NotificationType.follow:
        return 'started following you';
      case NotificationType.storyMention:
        return 'mentioned you in their story';
      case NotificationType.storyReply:
        return 'replied to your story';
      case NotificationType.liveVideo:
        return 'is live now';
      case NotificationType.igtvAlert:
        return 'posted a new IGTV video';
      case NotificationType.reelsNotification:
        return 'posted a new reel';
      case NotificationType.taggedInPhoto:
        return 'tagged you in a photo';
      case NotificationType.taggedInReel:
        return 'tagged you in a reel';
      case NotificationType.suggestedAccount:
        return 'You might know this person';
      case NotificationType.friendSuggestion:
        return 'is on Smart Social Platform';
      case NotificationType.newMessage:
        return 'sent you a message';
      case NotificationType.securityAlert:
        return 'New login detected';
      case NotificationType.loginAlert:
        return 'Login from new device';
      case NotificationType.verificationUpdate:
        return 'Your verification status has been updated';
      case NotificationType.shopping:
        return 'New products available';
      case NotificationType.newFeature:
        return 'Check out our new feature';
      case NotificationType.creatorUpdate:
        return 'New creator tools available';
    }
  }

  @override
  Future<void> close() {
    // _messageSubscription?.cancel();
    return super.close();
  }
}