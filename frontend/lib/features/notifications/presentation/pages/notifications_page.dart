import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_models.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_item.dart';
import '../widgets/notification_filter_tabs.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  int _currentPage = 1;

  final List<NotificationType?> _filterTypes = [
    null, // All
    NotificationType.like,
    NotificationType.comment,
    NotificationType.follow,
    NotificationType.mention,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: _filterTypes.length, vsync: this);
    _scrollController.addListener(_onScroll);
    
    context.read<NotificationsBloc>().add(const LoadNotifications());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NotificationsBloc>().add(LoadNotifications(page: _currentPage + 1));
      _currentPage++;
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Activity',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.black,
            ),
            onPressed: () {
              _showOptionsBottomSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFDBDBDB),
                  width: 0.5,
                ),
              ),
            ),
            child: NotificationFilterTabs(
              tabController: _tabController,
              filterTypes: _filterTypes,
              onFilterChanged: (type) {
                context.read<NotificationsBloc>().add(FilterNotificationsByType(type));
                _currentPage = 1;
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<NotificationsBloc, NotificationsState>(
              listener: (context, state) {
                if (state is NotificationsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is NotificationHandled && state.navigationRoute != null) {
                  Navigator.pushNamed(context, state.navigationRoute!);
                } else if (state is AllNotificationsMarkedAsRead) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read')),
                  );
                } else if (state is AllNotificationsCleared) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications cleared')),
                  );
                }
              },
              builder: (context, state) {
                if (state is NotificationsLoading && _currentPage == 1) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NotificationsLoaded) {
                  if (state.notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NotificationsBloc>().add(RefreshNotifications());
                      _currentPage = 1;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasReachedMax
                          ? state.notifications.length
                          : state.notifications.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.notifications.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final notification = state.notifications[index];
                        return NotificationItem(
                          notification: notification,
                          onTap: () {
                            context.read<NotificationsBloc>().add(
                              HandleNotificationTap(notification),
                            );
                          },
                          onDismiss: () {
                            context.read<NotificationsBloc>().add(
                              DeleteNotification(notification.id),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                if (state is NotificationsError) {
                  return _buildErrorState(state.message);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 48,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Activity On Your Posts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'When someone likes or comments on one of your posts, you\'ll see it here.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E8E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationsBloc>().add(const LoadNotifications());
              _currentPage = 1;
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDBDBDB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.mark_email_read, color: Colors.black),
              title: const Text(
                'Mark all as read',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<NotificationsBloc>().add(MarkAllNotificationsAsRead());
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.black),
              title: const Text(
                'Clear all',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _showClearAllDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text(
                'Settings',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notification-settings');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Clear All Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF8E8E8E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationsBloc>().add(ClearAllNotifications());
            },
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}