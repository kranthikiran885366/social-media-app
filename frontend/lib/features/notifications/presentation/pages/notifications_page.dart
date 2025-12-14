import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                floating: true,
                snap: true,
                expandedHeight: isTablet ? 120 : 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient.scale(0.1),
                    ),
                  ),
                  title: Text(
                    'Activity',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 28 : 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: false,
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(
                      right: isTablet ? 24 : 16,
                      top: isTablet ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: AppColors.textPrimary,
                        size: isTablet ? 28 : 24,
                      ),
                      onPressed: () {
                        _showOptionsBottomSheet(isTablet);
                      },
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: isTablet ? 15 : 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
              ),
              SliverFillRemaining(
                child: BlocConsumer<NotificationsBloc, NotificationsState>(
                  listener: (context, state) {
                    if (state is NotificationsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    } else if (state is NotificationHandled && state.navigationRoute != null) {
                      Navigator.pushNamed(context, state.navigationRoute!);
                    } else if (state is AllNotificationsMarkedAsRead) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('All notifications marked as read'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else if (state is AllNotificationsCleared) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('All notifications cleared'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is NotificationsLoading && _currentPage == 1) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      );
                    }

                    if (state is NotificationsLoaded) {
                      if (state.notifications.isEmpty) {
                        return _buildEmptyState(isTablet);
                      }

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          context.read<NotificationsBloc>().add(RefreshNotifications());
                          _currentPage = 1;
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 16,
                          ),
                          itemCount: state.hasReachedMax
                              ? state.notifications.length
                              : state.notifications.length + 1,
                          itemBuilder: (context, index) {
                            if (index >= state.notifications.length) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 3,
                                  ),
                                ),
                              );
                            }

                            final notification = state.notifications[index];
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: isTablet ? 12 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: isTablet ? 8 : 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: NotificationItem(
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
                              ),
                            );
                          },
                        ),
                      );
                    }

                    if (state is NotificationsError) {
                      return _buildErrorState(state.message, isTablet);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? 120 : 96,
              height: isTablet ? 120 : 96,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient.scale(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: isTablet ? 20 : 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                size: isTablet ? 60 : 48,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),
            Text(
              'No Activity Yet',
              style: TextStyle(
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 16,
              ),
              child: Text(
                'When someone likes or comments on one of your posts, you\'ll see it here.',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? 100 : 80,
              height: isTablet ? 100 : 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: isTablet ? 50 : 40,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Container(
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: isTablet ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.read<NotificationsBloc>().add(const LoadNotifications());
                  _currentPage = 1;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(bool isTablet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTablet ? 24 : 16),
        ),
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
              leading: Icon(
                Icons.mark_email_read,
                color: AppColors.primary,
                size: isTablet ? 28 : 24,
              ),
              title: Text(
                'Mark all as read',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<NotificationsBloc>().add(MarkAllNotificationsAsRead());
              },
            ),
            ListTile(
              leading: Icon(
                Icons.clear_all,
                color: AppColors.warning,
                size: isTablet ? 28 : 24,
              ),
              title: Text(
                'Clear all',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showClearAllDialog();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: AppColors.textSecondary,
                size: isTablet ? 28 : 24,
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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