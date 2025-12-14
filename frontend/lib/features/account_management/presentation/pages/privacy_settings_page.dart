import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Privacy'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Account Privacy',
            [
              SwitchListTile(
                title: const Text('Private Account'),
                subtitle: const Text('Only followers you approve can see your posts'),
                value: _isPrivateAccount,
                onChanged: (value) => setState(() => _isPrivateAccount = value),
              ),
            ],
          ),
          _buildSection(
            'Activity Status',
            [
              SwitchListTile(
                title: const Text('Show Activity Status'),
                subtitle: const Text('Let others see when you were last active'),
                value: _showActivityStatus,
                onChanged: (value) => setState(() => _showActivityStatus = value),
              ),
              SwitchListTile(
                title: const Text('Show Online Status'),
                subtitle: const Text('Show when you\'re online'),
                value: _showOnlineStatus,
                onChanged: (value) => setState(() => _showOnlineStatus = value),
              ),
            ],
          ),
          _buildSection(
            'Messages',
            [
              SwitchListTile(
                title: const Text('Allow Message Requests'),
                subtitle: const Text('Let people who don\'t follow you send message requests'),
                value: _allowMessageRequests,
                onChanged: (value) => setState(() => _allowMessageRequests = value),
              ),
            ],
          ),
          _buildSection(
            'Tags and Mentions',
            [
              SwitchListTile(
                title: const Text('Allow Tagging'),
                subtitle: const Text('Let others tag you in their posts'),
                value: _allowTagging,
                onChanged: (value) => setState(() => _allowTagging = value),
              ),
              SwitchListTile(
                title: const Text('Allow Mentions'),
                subtitle: const Text('Let others mention you in their posts and stories'),
                value: _allowMentions,
                onChanged: (value) => setState(() => _allowMentions = value),
              ),
            ],
          ),
          _buildSection(
            'Story Settings',
            [
              SwitchListTile(
                title: const Text('Allow Story Sharing'),
                subtitle: const Text('Let others share your story posts to their story'),
                value: _allowStorySharing,
                onChanged: (value) => setState(() => _allowStorySharing = value),
              ),
              SwitchListTile(
                title: const Text('Allow Story Replies'),
                subtitle: const Text('Let others reply to your stories'),
                value: _allowStoryReplies,
                onChanged: (value) => setState(() => _allowStoryReplies = value),
              ),
              ListTile(
                title: const Text('Close Friends'),
                subtitle: Text('${_closeFriends.length} people'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCloseFriendsList(),
              ),
              ListTile(
                title: const Text('Hide Story From'),
                subtitle: Text('${_hiddenFromStory.length} people'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showHiddenFromStoryList(),
              ),
            ],
          ),
          _buildSection(
            'Discoverability',
            [
              SwitchListTile(
                title: const Text('Show in Suggestions'),
                subtitle: const Text('Let others discover your account in suggestions'),
                value: _showInSuggestions,
                onChanged: (value) => setState(() => _showInSuggestions = value),
              ),
            ],
          ),
          _buildSection(
            'Blocked Accounts',
            [
              ListTile(
                title: const Text('Blocked Users'),
                subtitle: Text('${_blockedUsers.length} accounts blocked'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showBlockedUsersList(),
              ),
              ListTile(
                title: const Text('Restricted Users'),
                subtitle: Text('${_restrictedUsers.length} accounts restricted'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showRestrictedUsersList(),
              ),
            ],
          ),
          _buildSection(
            'Data and History',
            [
              SwitchListTile(
                title: const Text('Allow Data Download'),
                subtitle: const Text('Let others download data about your interactions'),
                value: _allowDataDownload,
                onChanged: (value) => setState(() => _allowDataDownload = value),
              ),
              ListTile(
                title: const Text('Download Your Data'),
                subtitle: const Text('Get a copy of what you\'ve shared'),
                trailing: const Icon(Icons.download),
                onTap: () => _downloadData(),
              ),
              ListTile(
                title: const Text('Clear Search History'),
                subtitle: const Text('Clear your search history'),
                trailing: const Icon(Icons.clear),
                onTap: () => _clearSearchHistory(),
              ),
            ],
          ),
          _buildSection(
            'Two-Factor Authentication',
            [
              ListTile(
                title: const Text('Two-Factor Authentication'),
                subtitle: const Text('Add an extra layer of security'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _setup2FA(),
              ),
              ListTile(
                title: const Text('Login Alerts'),
                subtitle: const Text('Get notified when someone logs into your account'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _setupLoginAlerts(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
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
        const Divider(height: 32),
      ],
    );
  }

  void _showCloseFriendsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
      builder: (context) => _buildUserListSheet(
        'Restricted Users',
        _restrictedUsers,
        'Restricted users can\'t see when you\'re online or if you\'ve read their messages.',
        showUnrestrictOption: true,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (!showUnblockOption && !showUnrestrictOption)
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search people...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage('https://example.com/$user.jpg'),
                  ),
                  title: Text(user),
                  subtitle: const Text('@username'),
                  trailing: showUnblockOption
                      ? TextButton(
                          onPressed: () => _unblockUser(user),
                          child: const Text('Unblock'),
                        )
                      : showUnrestrictOption
                          ? TextButton(
                              onPressed: () => _unrestrictUser(user),
                              child: const Text('Unrestrict'),
                            )
                          : IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () => _removeFromList(users, user),
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
      SnackBar(content: Text('$user has been unblocked')),
    );
  }

  void _unrestrictUser(String user) {
    setState(() => _restrictedUsers.remove(user));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$user has been unrestricted')),
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
        title: const Text('Download Your Data'),
        content: const Text(
          'We\'ll prepare a file with your Smart Social data. This may take a few minutes to a few hours depending on how much data you have.',
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
                const SnackBar(content: Text('Data download request submitted')),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _clearSearchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text('This will clear all your search history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search history cleared')),
              );
            },
            child: const Text('Clear'),
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