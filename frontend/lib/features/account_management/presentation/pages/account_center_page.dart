import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Accounts Center'),
        subtitle: const Text('Meta'),
      ),
      body: ListView(
        children: [
          _buildHeader(),
          _buildConnectedAccounts(),
          _buildPersonalDetails(),
          _buildPasswordAndSecurity(),
          _buildPaymentsAndPurchases(),
          _buildAdPreferences(),
          _buildPrivacySettings(),
          _buildDataAndPermissions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1877F2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Accounts Centre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Manage your connected experiences and account settings across Meta technologies.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedAccounts() {
    return _buildSection(
      'Your accounts and profiles',
      [
        ..._connectedAccounts.map((account) => _buildAccountTile(account)).toList(),
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Icon(Icons.add, color: Colors.grey),
          ),
          title: const Text('Add account'),
          subtitle: const Text('Connect another Meta account'),
          onTap: _addAccount,
        ),
      ],
    );
  }

  Widget _buildAccountTile(ConnectedAccount account) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(account.profileImage),
      ),
      title: Text(account.platform),
      subtitle: Text(account.username),
      trailing: account.isConnected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : TextButton(
              onPressed: () => _connectAccount(account),
              child: const Text('Connect'),
            ),
      onTap: () => _manageAccount(account),
    );
  }

  Widget _buildPersonalDetails() {
    return _buildSection(
      'Personal details',
      [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Personal information'),
          subtitle: const Text('Name, contact info, and more'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/personal-info'),
        ),
        ListTile(
          leading: const Icon(Icons.cake),
          title: const Text('Birthday'),
          subtitle: const Text('January 1, 1990'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _editBirthday(),
        ),
        ListTile(
          leading: const Icon(Icons.wc),
          title: const Text('Gender'),
          subtitle: const Text('Male'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _editGender(),
        ),
      ],
    );
  }

  Widget _buildPasswordAndSecurity() {
    return _buildSection(
      'Password and security',
      [
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Password'),
          subtitle: const Text('Change your password'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/change-password'),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Two-factor authentication'),
          subtitle: const Text('Add an extra layer of security'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/two-factor-auth'),
        ),
        ListTile(
          leading: const Icon(Icons.devices),
          title: const Text('Where you\'re logged in'),
          subtitle: const Text('Manage your active sessions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showActiveSessions(),
        ),
      ],
    );
  }

  Widget _buildPaymentsAndPurchases() {
    return _buildSection(
      'Payments and purchases',
      [
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Payment methods'),
          subtitle: const Text('Manage your payment options'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/payment-methods'),
        ),
        ListTile(
          leading: const Icon(Icons.receipt),
          title: const Text('Purchase history'),
          subtitle: const Text('View your transaction history'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/purchase-history'),
        ),
        ListTile(
          leading: const Icon(Icons.subscriptions),
          title: const Text('Subscriptions'),
          subtitle: const Text('Manage your active subscriptions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/subscriptions'),
        ),
      ],
    );
  }

  Widget _buildAdPreferences() {
    return _buildSection(
      'Ad preferences',
      [
        ListTile(
          leading: const Icon(Icons.ads_click),
          title: const Text('Ad settings'),
          subtitle: const Text('Control the ads you see'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/ad-settings'),
        ),
        ListTile(
          leading: const Icon(Icons.interests),
          title: const Text('Ad interests'),
          subtitle: const Text('See and manage your interests'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/ad-interests'),
        ),
        ListTile(
          leading: const Icon(Icons.block),
          title: const Text('Blocked advertisers'),
          subtitle: const Text('Advertisers you\'ve blocked'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/blocked-advertisers'),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSection(
      'Privacy settings',
      [
        SwitchListTile(
          secondary: const Icon(Icons.message),
          title: const Text('Cross-app messaging'),
          subtitle: const Text('Message across Meta apps'),
          value: _crossAppMessaging,
          onChanged: (value) => setState(() => _crossAppMessaging = value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.share),
          title: const Text('Cross-app sharing'),
          subtitle: const Text('Share content across Meta apps'),
          value: _crossAppSharing,
          onChanged: (value) => setState(() => _crossAppSharing = value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Unified notifications'),
          subtitle: const Text('Get notifications from all connected apps'),
          value: _unifiedNotifications,
          onChanged: (value) => setState(() => _unifiedNotifications = value),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy checkup'),
          subtitle: const Text('Review your privacy settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/privacy-checkup'),
        ),
      ],
    );
  }

  Widget _buildDataAndPermissions() {
    return _buildSection(
      'Your information and permissions',
      [
        SwitchListTile(
          secondary: const Icon(Icons.data_usage),
          title: const Text('Data sharing'),
          subtitle: const Text('Share data to improve your experience'),
          value: _dataSharing,
          onChanged: (value) => setState(() => _dataSharing = value),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Download your information'),
          subtitle: const Text('Get a copy of your data'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _downloadData(),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever),
          title: const Text('Delete account or data'),
          subtitle: const Text('Permanently delete your account'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _deleteAccount(),
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Support'),
          subtitle: const Text('Get help with your account'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/support'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  void _addAccount() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.facebook, color: Colors.blue),
              title: const Text('Facebook'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: const Text('Instagram'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('WhatsApp'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _connectAccount(ConnectedAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect ${account.platform}'),
        content: Text('Connect your ${account.platform} account to enable cross-app features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => account.isConnected = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${account.platform} account connected')),
              );
            },
            child: const Text('Connect'),
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
    );
  }

  void _editGender() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Male'),
              value: 'Male',
              groupValue: 'Male',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Female'),
              value: 'Female',
              groupValue: 'Male',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Non-binary'),
              value: 'Non-binary',
              groupValue: 'Male',
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
        title: const Text('Download Your Information'),
        content: const Text(
          'We\'ll create a file with your information from all connected Meta accounts. This may take some time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download request submitted')),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/delete-account'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
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