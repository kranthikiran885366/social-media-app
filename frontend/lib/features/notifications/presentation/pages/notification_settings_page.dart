import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_models.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(LoadNotificationSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationSettingsLoaded) {
            return _buildSettingsList(state.settings);
          }

          if (state is NotificationSettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationsBloc>().add(LoadNotificationSettings());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSettingsList(NotificationSettings settings) {
    return ListView(
      children: [
        _buildSectionHeader('Push Notifications'),
        _buildSwitchTile(
          'Enable Push Notifications',
          'Receive notifications on your device',
          settings.pushNotificationsEnabled,
          'pushNotificationsEnabled',
        ),
        
        _buildSectionHeader('Activity'),
        _buildSwitchTile(
          'Likes',
          'Someone likes your posts',
          settings.likesEnabled,
          'likesEnabled',
        ),
        _buildSwitchTile(
          'Comments',
          'Someone comments on your posts',
          settings.commentsEnabled,
          'commentsEnabled',
        ),
        _buildSwitchTile(
          'Mentions',
          'Someone mentions you in a comment',
          settings.mentionsEnabled,
          'mentionsEnabled',
        ),
        _buildSwitchTile(
          'New Followers',
          'Someone starts following you',
          settings.followersEnabled,
          'followersEnabled',
        ),
        
        _buildSectionHeader('Stories'),
        _buildSwitchTile(
          'Story Mentions',
          'Someone mentions you in their story',
          settings.storyMentionsEnabled,
          'storyMentionsEnabled',
        ),
        _buildSwitchTile(
          'Story Replies',
          'Someone replies to your story',
          settings.storyRepliesEnabled,
          'storyRepliesEnabled',
        ),
        
        _buildSectionHeader('Content'),
        _buildSwitchTile(
          'Live Videos',
          'Someone you follow goes live',
          settings.liveVideosEnabled,
          'liveVideosEnabled',
        ),
        _buildSwitchTile(
          'IGTV Alerts',
          'New IGTV videos from accounts you follow',
          settings.igtvAlertsEnabled,
          'igtvAlertsEnabled',
        ),
        _buildSwitchTile(
          'Reels Notifications',
          'New reels from accounts you follow',
          settings.reelsNotificationsEnabled,
          'reelsNotificationsEnabled',
        ),
        
        _buildSectionHeader('Tags'),
        _buildSwitchTile(
          'Tagged in Photos',
          'Someone tags you in a photo',
          settings.taggedInPhotoEnabled,
          'taggedInPhotoEnabled',
        ),
        _buildSwitchTile(
          'Tagged in Reels',
          'Someone tags you in a reel',
          settings.taggedInReelEnabled,
          'taggedInReelEnabled',
        ),
        
        _buildSectionHeader('Social'),
        _buildSwitchTile(
          'Suggested Accounts',
          'Accounts you might be interested in',
          settings.suggestedAccountsEnabled,
          'suggestedAccountsEnabled',
        ),
        _buildSwitchTile(
          'Friend Suggestions',
          'People you may know',
          settings.friendSuggestionsEnabled,
          'friendSuggestionsEnabled',
        ),
        
        _buildSectionHeader('Messages'),
        _buildSwitchTile(
          'New Message Alerts',
          'Someone sends you a direct message',
          settings.newMessageAlertsEnabled,
          'newMessageAlertsEnabled',
        ),
        
        _buildSectionHeader('Security'),
        _buildSwitchTile(
          'Security Alerts',
          'Important security notifications',
          settings.securityAlertsEnabled,
          'securityAlertsEnabled',
        ),
        _buildSwitchTile(
          'Login Alerts',
          'New login notifications',
          settings.loginAlertsEnabled,
          'loginAlertsEnabled',
        ),
        _buildSwitchTile(
          'Verification Updates',
          'Updates about your verification status',
          settings.verificationUpdatesEnabled,
          'verificationUpdatesEnabled',
        ),
        
        _buildSectionHeader('Shopping'),
        _buildSwitchTile(
          'Shopping Notifications',
          'Product updates and promotions',
          settings.shoppingNotificationsEnabled,
          'shoppingNotificationsEnabled',
        ),
        
        _buildSectionHeader('Platform Updates'),
        _buildSwitchTile(
          'New Features',
          'Announcements about new features',
          settings.newFeaturesEnabled,
          'newFeaturesEnabled',
        ),
        _buildSwitchTile(
          'Creator Updates',
          'Updates for content creators',
          settings.creatorUpdatesEnabled,
          'creatorUpdatesEnabled',
        ),
        
        _buildSectionHeader('Email & SMS'),
        _buildSwitchTile(
          'Email Notifications',
          'Receive notifications via email',
          settings.emailNotificationsEnabled,
          'emailNotificationsEnabled',
        ),
        _buildSwitchTile(
          'SMS Notifications',
          'Receive notifications via SMS',
          settings.smsNotificationsEnabled,
          'smsNotificationsEnabled',
        ),
        
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    String settingKey,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (newValue) {
        context.read<NotificationsBloc>().add(
          ToggleNotificationSetting(settingKey, newValue),
        );
      },
    );
  }
}