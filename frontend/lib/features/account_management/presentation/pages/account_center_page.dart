import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AccountCenterPage extends StatefulWidget {
  const AccountCenterPage({super.key});

  @override
  State<AccountCenterPage> createState() => _AccountCenterPageState();
}

class _AccountCenterPageState extends State<AccountCenterPage> {
  final List<ConnectedAccount> _connectedAccounts = [
    ConnectedAccount(
      platform: 'Instagram',
      username: '@john_doe',
      isConnected: true,
      profileImage: 'https://example.com/instagram.jpg',
    ),
    ConnectedAccount(
      platform: 'Facebook',
      username: 'John Doe',
      isConnected: true,
      profileImage: 'https://example.com/facebook.jpg',
    ),
    ConnectedAccount(
      platform: 'WhatsApp',
      username: '+1 234 567 8900',
      isConnected: false,
      profileImage: 'https://example.com/whatsapp.jpg',
    ),
  ];

  bool _crossAppMessaging = true;
  bool _crossAppSharing = true;
  bool _unifiedNotifications = false;
  bool _dataSharing = true;

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
                    'Accounts Center',
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
                    _buildHeader(isTablet),
                    _buildConnectedAccounts(isTablet),
                    _buildPersonalDetails(isTablet),
                    _buildPasswordAndSecurity(isTablet),
                    _buildPaymentsAndPurchases(isTablet),
                    _buildAdPreferences(isTablet),
                    _buildPrivacySettings(isTablet),
                    _buildDataAndPermissions(isTablet),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      margin: EdgeInsets.only(bottom: isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
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
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                ),
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: isTablet ? 36 : 28,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Accounts Centre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Manage your connected experiences and account settings across Meta technologies.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTablet ? 16 : 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedAccounts(bool isTablet) {
    return _buildSection(
      'Your accounts and profiles',
      [
        ..._connectedAccounts.map((account) => _buildAccountTile(account, isTablet)).toList(),
        _buildAddAccountTile(isTablet),
      ],
      isTablet,
    );
  }

  Widget _buildAccountTile(ConnectedAccount account, bool isTablet) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        onTap: () => _manageAccount(account),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Container(
                width: isTablet ? 56 : 48,
                height: isTablet ? 56 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: account.isConnected ? AppColors.success : AppColors.border,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: isTablet ? 24 : 20,
                  backgroundImage: NetworkImage(account.profileImage),
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.platform,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      account.username,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              account.isConnected
                  ? Container(
                      padding: EdgeInsets.all(isTablet ? 8 : 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: isTablet ? 24 : 20,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                      ),
                      child: InkWell(
                        onTap: () => _connectAccount(account),
                        child: Text(
                          'Connect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetails(bool isTablet) {
    return _buildSection(
      'Personal details',
      [
        _buildSettingItem(Icons.person, 'Personal information', 'Name, contact info, and more', AppColors.primary, isTablet, () => Navigator.pushNamed(context, '/personal-info')),
        _buildSettingItem(Icons.cake, 'Birthday', 'January 1, 1990', AppColors.secondary, isTablet, _editBirthday),
        _buildSettingItem(Icons.wc, 'Gender', 'Male', AppColors.info, isTablet, _editGender),
      ],
      isTablet,
    );
  }

  Widget _buildPasswordAndSecurity(bool isTablet) {
    return _buildSection(
      'Password and security',
      [
        _buildSettingItem(Icons.lock, 'Password', 'Change your password', AppColors.warning, isTablet, () => Navigator.pushNamed(context, '/change-password')),
        _buildSettingItem(Icons.security, 'Two-factor authentication', 'Add an extra layer of security', AppColors.success, isTablet, () => Navigator.pushNamed(context, '/two-factor-auth')),
        _buildSettingItem(Icons.devices, 'Where you\'re logged in', 'Manage your active sessions', AppColors.info, isTablet, _showActiveSessions),
      ],
      isTablet,
    );
  }

  Widget _buildPaymentsAndPurchases(bool isTablet) {
    return _buildSection(
      'Payments and purchases',
      [
        _buildSettingItem(Icons.payment, 'Payment methods', 'Manage your payment options', AppColors.primary, isTablet, () => Navigator.pushNamed(context, '/payment-methods')),
        _buildSettingItem(Icons.receipt, 'Purchase history', 'View your transaction history', AppColors.secondary, isTablet, () => Navigator.pushNamed(context, '/purchase-history')),
        _buildSettingItem(Icons.subscriptions, 'Subscriptions', 'Manage your active subscriptions', AppColors.info, isTablet, () => Navigator.pushNamed(context, '/subscriptions')),
      ],
      isTablet,
    );
  }

  Widget _buildAdPreferences(bool isTablet) {
    return _buildSection(
      'Ad preferences',
      [
        _buildSettingItem(Icons.ads_click, 'Ad settings', 'Control the ads you see', AppColors.warning, isTablet, () => Navigator.pushNamed(context, '/ad-settings')),
        _buildSettingItem(Icons.interests, 'Ad interests', 'See and manage your interests', AppColors.success, isTablet, () => Navigator.pushNamed(context, '/ad-interests')),
        _buildSettingItem(Icons.block, 'Blocked advertisers', 'Advertisers you\'ve blocked', AppColors.error, isTablet, () => Navigator.pushNamed(context, '/blocked-advertisers')),
      ],
      isTablet,
    );
  }

  Widget _buildPrivacySettings(bool isTablet) {
    return _buildSection(
      'Privacy settings',
      [
        _buildSwitchTile('Cross-app messaging', 'Message across Meta apps', Icons.message, _crossAppMessaging, (value) => setState(() => _crossAppMessaging = value), isTablet),
        _buildSwitchTile('Cross-app sharing', 'Share content across Meta apps', Icons.share, _crossAppSharing, (value) => setState(() => _crossAppSharing = value), isTablet),
        _buildSwitchTile('Unified notifications', 'Get notifications from all connected apps', Icons.notifications, _unifiedNotifications, (value) => setState(() => _unifiedNotifications = value), isTablet),
        _buildSettingItem(Icons.privacy_tip, 'Privacy checkup', 'Review your privacy settings', AppColors.info, isTablet, () => Navigator.pushNamed(context, '/privacy-checkup')),
      ],
      isTablet,
    );
  }

  Widget _buildDataAndPermissions(bool isTablet) {
    return _buildSection(
      'Your information and permissions',
      [
        _buildSwitchTile('Data sharing', 'Share data to improve your experience', Icons.data_usage, _dataSharing, (value) => setState(() => _dataSharing = value), isTablet),
        _buildSettingItem(Icons.download, 'Download your information', 'Get a copy of your data', AppColors.info, isTablet, _downloadData),
        _buildSettingItem(Icons.delete_forever, 'Delete account or data', 'Permanently delete your account', AppColors.error, isTablet, _deleteAccount),
        _buildSettingItem(Icons.help, 'Support', 'Get help with your account', AppColors.success, isTablet, () => Navigator.pushNamed(context, '/support')),
      ],
      isTablet,
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isTablet ? 8 : 4,
            bottom: isTablet ? 16 : 12,
            top: isTablet ? 32 : 24,
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildAddAccountTile(bool isTablet) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        onTap: _addAccount,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Container(
                width: isTablet ? 56 : 48,
                height: isTablet ? 56 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                  color: AppColors.backgroundSecondary,
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.textSecondary,
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add account',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      'Connect another Meta account',
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        color: AppColors.textSecondary,
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

  Widget _buildSettingItem(IconData icon, String title, String subtitle, Color iconColor, bool isTablet, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        onTap: onTap,
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

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Row(
        children: [
          Container(
            width: isTablet ? 52 : 44,
            height: isTablet ? 52 : 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
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
          Transform.scale(
            scale: isTablet ? 1.2 : 1.0,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  void _addAccount() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildPlatformOption(Icons.facebook, 'Facebook', Colors.blue),
            _buildPlatformOption(Icons.camera_alt, 'Instagram', Colors.purple),
            _buildPlatformOption(Icons.message, 'WhatsApp', Colors.green),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformOption(IconData icon, String platform, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  platform,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _connectAccount(ConnectedAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Connect ${account.platform}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Connect your ${account.platform} account to enable cross-app features.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
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
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => account.isConnected = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${account.platform} account connected'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Connect',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _manageAccount(ConnectedAccount account) {
    Navigator.pushNamed(context, '/manage-account', arguments: account);
  }

  void _editBirthday() {
    showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _editGender() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Gender',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('Male', style: TextStyle(color: AppColors.textPrimary)),
              value: 'Male',
              groupValue: 'Male',
              activeColor: AppColors.primary,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: Text('Female', style: TextStyle(color: AppColors.textPrimary)),
              value: 'Female',
              groupValue: 'Male',
              activeColor: AppColors.primary,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: Text('Non-binary', style: TextStyle(color: AppColors.textPrimary)),
              value: 'Non-binary',
              groupValue: 'Male',
              activeColor: AppColors.primary,
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showActiveSessions() {
    Navigator.pushNamed(context, '/active-sessions');
  }

  void _downloadData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Download Your Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'We\'ll create a file with your information from all connected Meta accounts. This may take some time.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
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
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Download request submitted'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Request Download',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
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
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/delete-account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class ConnectedAccount {
  final String platform;
  final String username;
  bool isConnected;
  final String profileImage;

  ConnectedAccount({
    required this.platform,
    required this.username,
    required this.isConnected,
    required this.profileImage,
  });
}