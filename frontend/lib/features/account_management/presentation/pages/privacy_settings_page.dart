import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _isPrivateAccount = false;
  bool _showActivityStatus = true;
  bool _allowMessageRequests = true;
  bool _showOnlineStatus = true;
  bool _allowTagging = true;
  bool _allowMentions = true;
  bool _allowStorySharing = true;
  bool _allowStoryReplies = true;
  bool _showInSuggestions = true;
  bool _allowDataDownload = true;

  final List<String> _blockedUsers = ['user1', 'user2', 'user3'];
  final List<String> _restrictedUsers = ['user4', 'user5'];
  final List<String> _closeFriends = ['friend1', 'friend2', 'friend3', 'friend4'];
  final List<String> _hiddenFromStory = ['user6', 'user7'];

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
                    'Privacy Settings',
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
                    _buildSection(
                      'Account Privacy',
                      [
                        _buildSwitchTile('Private Account', 'Only followers you approve can see your posts', Icons.lock, _isPrivateAccount, (value) => setState(() => _isPrivateAccount = value), isTablet),
                      ],
                      isTablet,
                    ),
                    _buildSection(
                      'Activity Status',
                      [
                        _buildSwitchTile('Show Activity Status', 'Let others see when you were last active', Icons.access_time, _showActivityStatus, (value) => setState(() => _showActivityStatus = value), isTablet),
                        _buildSwitchTile('Show Online Status', 'Show when you\'re online', Icons.circle, _showOnlineStatus, (value) => setState(() => _showOnlineStatus = value), isTablet),
                      ],
                      isTablet,
                    ),
                    _buildSection(
                      'Messages',
                      [
                        _buildSwitchTile('Allow Message Requests', 'Let people who don\'t follow you send message requests', Icons.message, _allowMessageRequests, (value) => setState(() => _allowMessageRequests = value), isTablet),
                      ],
                      isTablet,
                    ),
                    _buildSection(
                      'Tags and Mentions',
                      [
                        _buildSwitchTile('Allow Tagging', 'Let others tag you in their posts', Icons.local_offer, _allowTagging, (value) => setState(() => _allowTagging = value), isTablet),
                        _buildSwitchTile('Allow Mentions', 'Let others mention you in their posts and stories', Icons.alternate_email, _allowMentions, (value) => setState(() => _allowMentions = value), isTablet),
                      ],
                      isTablet,
                    ),
                    _buildSection(
                      'Story Settings',
                      [
                        _buildSwitchTile('Allow Story Sharing', 'Let others share your story posts to their story', Icons.share, _allowStorySharing, (value) => setState(() => _allowStorySharing = value), isTablet),
                        _buildSwitchTile('Allow Story Replies', 'Let others reply to your stories', Icons.reply, _allowStoryReplies, (value) => setState(() => _allowStoryReplies = value), isTablet),
                        _buildSettingItem(Icons.group, 'Close Friends', '${_closeFriends.length} people', AppColors.success, isTablet, _showCloseFriendsList),
                        _buildSettingItem(Icons.visibility_off, 'Hide Story From', '${_hiddenFromStory.length} people', AppColors.warning, isTablet, _showHiddenFromStoryList),
                      ],
                      isTablet,
                    ),
                    _buildSection(
                      'Discoverability',
                      [
                        _buildSwitchTile('Show in Suggestions', 'Let others discover your account in suggestions', Icons.explore, _showInSuggestions, (value) => setState(() => _showInSuggestions = value), isTablet),
                      ],
                      isTablet,
                    ),
                    _buildSection(
                      'Blocked Accounts',
                      [
                        _buildSettingItem(Icons.block, 'Blocked Users', '${_blockedUsers.length} accounts blocked', AppColors.error, isTablet, _showBlockedUsersList),
                        _buildSettingItem(Icons.do_not_disturb, 'Restricted Users', '${_restrictedUsers.length} accounts restricted', AppColors.warning, isTablet, _showRestrictedUsersList),
                      ],
                      isTablet,
                    ),
                    _buildSection(
                      'Data and History',
                      [
                        _buildSwitchTile('Allow Data Download', 'Let others download data about your interactions', Icons.data_usage, _allowDataDownload, (value) => setState(() => _allowDataDownload = value), isTablet),
                        _buildSettingItem(Icons.download, 'Download Your Data', 'Get a copy of what you\'ve shared', AppColors.info, isTablet, _downloadData),
                        _buildSettingItem(Icons.clear, 'Clear Search History', 'Clear your search history', AppColors.warning, isTablet, _clearSearchHistory),
                      ],
                      isTablet,
                    ),
                    _buildSection(
                      'Two-Factor Authentication',
                      [
                        _buildSettingItem(Icons.security, 'Two-Factor Authentication', 'Add an extra layer of security', AppColors.success, isTablet, _setup2FA),
                        _buildSettingItem(Icons.notifications_active, 'Login Alerts', 'Get notified when someone logs into your account', AppColors.info, isTablet, _setupLoginAlerts),
                      ],
                      isTablet,
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
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

  void _showCloseFriendsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUserListSheet(
        'Close Friends',
        _closeFriends,
        'Add people to your close friends list to share stories with them exclusively.',
      ),
    );
  }

  void _showHiddenFromStoryList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUserListSheet(
        'Hide Story From',
        _hiddenFromStory,
        'These people won\'t see your stories.',
      ),
    );
  }

  void _showBlockedUsersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUserListSheet(
        'Blocked Users',
        _blockedUsers,
        'Blocked users can\'t find your profile, posts, or story.',
        showUnblockOption: true,
      ),
    );
  }

  void _showRestrictedUsersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildUserListSheet(
        'Restricted Users',
        _restrictedUsers,
        'Restricted users can\'t see when you\'re online or if you\'ve read their messages.',
        showUnrestrictOption: true,
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

  Widget _buildUserListSheet(
    String title,
    List<String> users,
    String description, {
    bool showUnblockOption = false,
    bool showUnrestrictOption = false,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          if (!showUnblockOption && !showUnrestrictOption)
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage('https://example.com/$user.jpg'),
                    ),
                    title: Text(
                      user,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '@username',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: showUnblockOption
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: () => _unblockUser(user),
                              child: const Text(
                                'Unblock',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          )
                        : showUnrestrictOption
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: InkWell(
                                  onTap: () => _unrestrictUser(user),
                                  child: const Text(
                                    'Unrestrict',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: Icon(Icons.remove_circle, color: AppColors.error),
                                onPressed: () => _removeFromList(users, user),
                              ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _unblockUser(String user) {
    setState(() => _blockedUsers.remove(user));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$user has been unblocked'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _unrestrictUser(String user) {
    setState(() => _restrictedUsers.remove(user));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$user has been unrestricted'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _removeFromList(List<String> list, String user) {
    setState(() => list.remove(user));
    Navigator.pop(context);
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
          'Download Your Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'We\'ll prepare a file with your Smart Social data. This may take a few minutes to a few hours depending on how much data you have.',
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
                    content: const Text('Data download request submitted'),
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

  void _clearSearchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear Search History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will clear all your search history. This action cannot be undone.',
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Search history cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _setup2FA() {
    Navigator.pushNamed(context, '/two-factor-auth');
  }

  void _setupLoginAlerts() {
    Navigator.pushNamed(context, '/login-alerts');
  }
}