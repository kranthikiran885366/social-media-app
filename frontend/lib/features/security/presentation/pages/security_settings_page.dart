import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _twoFactorEnabled = false;
  bool _loginAlertsEnabled = true;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              _buildAppBar(isTablet),
              SliverPadding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSecurityOverview(isTablet),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildSection('Authentication', [
                      _buildSwitchItem(
                        Icons.security,
                        'Two-Factor Authentication',
                        'Add an extra layer of security',
                        _twoFactorEnabled,
                        (value) => setState(() => _twoFactorEnabled = value),
                        AppColors.primary,
                        isTablet,
                      ),
                      _buildSwitchItem(
                        Icons.fingerprint,
                        'Biometric Login',
                        'Use fingerprint or face ID',
                        _biometricEnabled,
                        (value) => setState(() => _biometricEnabled = value),
                        AppColors.secondary,
                        isTablet,
                      ),
                    ], isTablet),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildSection('Alerts & Monitoring', [
                      _buildSwitchItem(
                        Icons.notifications_active,
                        'Login Alerts',
                        'Get notified of new logins',
                        _loginAlertsEnabled,
                        (value) => setState(() => _loginAlertsEnabled = value),
                        AppColors.warning,
                        isTablet,
                      ),
                      _buildActionItem(
                        Icons.devices,
                        'Active Sessions',
                        'Manage logged in devices',
                        AppColors.info,
                        isTablet,
                      ),
                      _buildActionItem(
                        Icons.history,
                        'Login Activity',
                        'View recent login history',
                        AppColors.success,
                        isTablet,
                      ),
                    ], isTablet),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildSection('Account Security', [
                      _buildActionItem(
                        Icons.lock_reset,
                        'Change Password',
                        'Update your password',
                        AppColors.primary,
                        isTablet,
                      ),
                      _buildActionItem(
                        Icons.download,
                        'Download Data',
                        'Get a copy of your data',
                        AppColors.secondary,
                        isTablet,
                      ),
                      _buildActionItem(
                        Icons.delete_forever,
                        'Delete Account',
                        'Permanently delete your account',
                        AppColors.error,
                        isTablet,
                      ),
                    ], isTablet),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
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
          'Security',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isTablet ? 24 : 20,
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
    );
  }

  Widget _buildSecurityOverview(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 28 : 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: isTablet ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Score',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Good',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '75%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your account is well protected. Consider enabling two-factor authentication for better security.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
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

  Widget _buildSwitchItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    Color iconColor,
    bool isTablet,
  ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, Color iconColor, bool isTablet) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleActionTap(title),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
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
    );
  }

  void _handleActionTap(String action) {
    switch (action) {
      case 'Active Sessions':
        _showActiveSessions();
        break;
      case 'Login Activity':
        _showLoginActivity();
        break;
      case 'Change Password':
        _showChangePassword();
        break;
      case 'Download Data':
        _showDownloadData();
        break;
      case 'Delete Account':
        _showDeleteAccount();
        break;
    }
  }

  void _showActiveSessions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
                'Active Sessions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 3,
                itemBuilder: (context, index) => _buildSessionItem(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(int index) {
    final devices = ['iPhone 13', 'MacBook Pro', 'Chrome Browser'];
    final locations = ['New York, US', 'London, UK', 'Tokyo, JP'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              index == 0 ? Icons.phone_iphone : index == 1 ? Icons.laptop_mac : Icons.web,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  devices[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  locations[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (index == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Current',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () {},
              child: Text(
                'End Session',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLoginActivity() {}
  void _showChangePassword() {}
  void _showDownloadData() {}
  void _showDeleteAccount() {}
}