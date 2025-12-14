import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../feed/presentation/pages/home_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../create_post/presentation/pages/create_post_page.dart';
import '../../../reels/presentation/pages/reels_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../messaging/pages/messages_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const CreatePostPage(),
    const ReelsPage(),
    const ProfilePage(userId: 'current_user'),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Search',
    ),
    NavigationItem(
      icon: Icons.add_box_outlined,
      activeIcon: Icons.add_box,
      label: 'Create',
    ),
    NavigationItem(
      icon: Icons.video_library_outlined,
      activeIcon: Icons.video_library,
      label: 'Reels',
    ),
    NavigationItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 0 ? _buildFloatingActionButtons() : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: AppColors.border,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: isTablet ? 15 : 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: isTablet ? 72 : 60,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 8, 
                vertical: isTablet ? 12 : 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == _currentIndex;
                  
                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onTabTapped(index),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                        child: Container(
                          height: isTablet ? 52 : 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                            color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  size: isTablet ? 28 : 24,
                                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  margin: EdgeInsets.only(top: isTablet ? 4 : 2),
                                  width: isTablet ? 6 : 4,
                                  height: isTablet ? 6 : 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = MediaQuery.of(context).size.width > 600;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: Opacity(
                    opacity: _fabAnimation.value,
                    child: FloatingActionButton(
                      heroTag: "messages",
                      mini: !isTablet,
                      backgroundColor: AppColors.secondary,
                      onPressed: _navigateToMessages,
                      child: Icon(
                        Icons.message_outlined, 
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: isTablet ? 12 : 8),
            AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: Opacity(
                    opacity: _fabAnimation.value,
                    child: FloatingActionButton(
                      heroTag: "notifications",
                      mini: !isTablet,
                      backgroundColor: AppColors.info,
                      onPressed: _navigateToActivity,
                      child: Icon(
                        Icons.favorite_outline, 
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: isTablet ? 12 : 8),
            FloatingActionButton(
              heroTag: "main",
              mini: !isTablet,
              backgroundColor: AppColors.primary,
              onPressed: _toggleFABs,
              child: AnimatedRotation(
                turns: _fabAnimation.value * 0.125,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.add, 
                  color: Colors.white,
                  size: isTablet ? 32 : 28,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    HapticFeedback.lightImpact();
    
    if (_fabAnimationController.isCompleted) {
      _fabAnimationController.reverse();
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      _handleDoubleTap(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    HapticFeedback.selectionClick();
  }

  void _handleDoubleTap(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        _showQuickCreateOptions();
        break;
      case 3:
        break;
      case 4:
        break;
    }
  }

  void _toggleFABs() {
    if (_fabAnimationController.isCompleted) {
      _fabAnimationController.reverse();
    } else {
      _fabAnimationController.forward();
    }
    
    HapticFeedback.mediumImpact();
  }

  void _navigateToMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MessagesPage()),
    );
    _fabAnimationController.reverse();
  }

  void _navigateToActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
    _fabAnimationController.reverse();
  }

  void _showQuickCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Create',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _buildCreateOption(
              icon: Icons.photo_camera_outlined,
              title: 'Post',
              subtitle: 'Share a photo or video',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                _pageController.animateToPage(2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
            ),
            _buildCreateOption(
              icon: Icons.video_library_outlined,
              title: 'Reel',
              subtitle: 'Create a short video',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildCreateOption(
              icon: Icons.circle_outlined,
              title: 'Story',
              subtitle: 'Share a moment',
              color: AppColors.info,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildCreateOption(
              icon: Icons.live_tv_outlined,
              title: 'Live',
              subtitle: 'Go live with your followers',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}