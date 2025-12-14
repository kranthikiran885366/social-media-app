import 'package:flutter/material.dart';
import '../../data/models/notification_models.dart';

class NotificationFilterTabs extends StatelessWidget {
  final TabController tabController;
  final List<NotificationType?> filterTypes;
  final Function(NotificationType?) onFilterChanged;

  const NotificationFilterTabs({
    super.key,
    required this.tabController,
    required this.filterTypes,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        onTap: (index) => onFilterChanged(filterTypes[index]),
        tabs: filterTypes.map((type) => Tab(
          text: _getFilterLabel(type),
        )).toList(),
      ),
    );
  }

  String _getFilterLabel(NotificationType? type) {
    if (type == null) return 'All';
    
    switch (type) {
      case NotificationType.like:
        return 'Likes';
      case NotificationType.comment:
        return 'Comments';
      case NotificationType.mention:
        return 'Mentions';
      case NotificationType.follow:
        return 'Followers';
      case NotificationType.storyMention:
        return 'Story Mentions';
      case NotificationType.storyReply:
        return 'Story Replies';
      case NotificationType.liveVideo:
        return 'Live Videos';
      case NotificationType.igtvAlert:
        return 'IGTV';
      case NotificationType.reelsNotification:
        return 'Reels';
      case NotificationType.taggedInPhoto:
        return 'Tagged Photos';
      case NotificationType.taggedInReel:
        return 'Tagged Reels';
      case NotificationType.suggestedAccount:
        return 'Suggestions';
      case NotificationType.friendSuggestion:
        return 'Friends';
      case NotificationType.newMessage:
        return 'Messages';
      case NotificationType.securityAlert:
        return 'Security';
      case NotificationType.loginAlert:
        return 'Login';
      case NotificationType.verificationUpdate:
        return 'Verification';
      case NotificationType.shopping:
        return 'Shopping';
      case NotificationType.newFeature:
        return 'Features';
      case NotificationType.creatorUpdate:
        return 'Creator';
    }
  }
}