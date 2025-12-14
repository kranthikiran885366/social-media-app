import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                    'Settings',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 28 : 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: false,
                ),
                leading: Container(
                  margin: EdgeInsets.only(
                    left: isTablet ? 24 : 16,
                    top: isTablet ? 12 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: isTablet ? 28 : 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSection('Account', [
                      _buildSettingItem(
                        Icons.person_outline,
                        'Edit Profile',
                        'Update your profile information',
                        AppColors.primary,
                        isTablet,
                      ),
                      _buildSettingItem(
                        Icons.lock_outline,
                        'Privacy',
                        'Manage your privacy settings',
                        AppColors.secondary,
                        isTablet,
                      ),
                      _buildSettingItem(
                        Icons.security,
                        'Security',
                        'Password and security options',
                        AppColors.info,
                        isTablet,
                      ),
                    ], isTablet),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildSection('Preferences', [
                      _buildSettingItem(
                        Icons.notifications_outlined,
                        'Notifications',
                        'Manage notification preferences',
                        AppColors.warning,
                        isTablet,
                      ),
                      _buildSettingItem(
                        Icons.dark_mode_outlined,
                        'Theme',
                        'Choose your preferred theme',
                        AppColors.textSecondary,
                        isTablet,
                      ),
                      _buildSettingItem(
                        Icons.language,
                        'Language',
                        'Select your language',
                        AppColors.success,
                        isTablet,
                      ),
                    ], isTablet),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildSection('Support', [
                      _buildSettingItem(
                        Icons.help_outline,
                        'Help Center',
                        'Get help and support',
                        AppColors.info,
                        isTablet,
                      ),
                      _buildSettingItem(
                        Icons.feedback_outlined,
                        'Send Feedback',
                        'Share your thoughts with us',
                        AppColors.secondary,
                        isTablet,
                      ),
                      _buildSettingItem(
                        Icons.info_outline,
                        'About',
                        'App version and information',
                        AppColors.textTertiary,
                        isTablet,
                      ),
                    ], isTablet),
                    SizedBox(height: isTablet ? 48 : 32),
                    _buildLogoutButton(context, isTablet),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isTablet ? 8 : 4,
            bottom: isTablet ? 16 : 12,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: isTablet ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, Color iconColor, bool isTablet) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Container(
                width: isTablet ? 52 : 44,
                height: isTablet ? 52 : 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(0.15),
                      iconColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: isTablet ? 26 : 22,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: isTablet ? 24 : 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isTablet) {
    return Container(
      width: double.infinity,
      height: isTablet ? 64 : 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.1),
            AppColors.error.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.1),
            blurRadius: isTablet ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          onTap: () => _showLogoutDialog(context, isTablet),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                color: AppColors.error,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                'Log Out',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isTablet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle logout
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}