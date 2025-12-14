import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/settings_models.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadPrivacySettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PrivacySettingsLoaded) {
            return _buildPrivacySettings(state.settings);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPrivacySettings(PrivacySettings settings) {
    return ListView(
      children: [
        _buildSectionHeader('Account Privacy'),
        SwitchListTile(
          secondary: const Icon(Icons.lock),
          title: const Text('Private Account'),
          subtitle: const Text('Only approved followers can see your posts'),
          value: settings.isPrivateAccount,
          onChanged: (value) {
            context.read<SettingsBloc>().add(TogglePrivateAccount(value));
          },
        ),

        _buildSectionHeader('Interactions'),
        ListTile(
          leading: const Icon(Icons.comment),
          title: const Text('Comments'),
          subtitle: Text(settings.allowCommentsFromEveryone ? 'Everyone' : 'People you follow'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCommentControlsDialog(settings),
        ),
        ListTile(
          leading: const Icon(Icons.local_offer),
          title: const Text('Tags'),
          subtitle: Text(settings.allowTagsFromEveryone ? 'Everyone' : 'People you follow'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showTagControlsDialog(settings),
        ),
        ListTile(
          leading: const Icon(Icons.alternate_email),
          title: const Text('Mentions'),
          subtitle: Text(settings.allowMentionsFromEveryone ? 'Everyone' : 'People you follow'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showMentionControlsDialog(settings),
        ),

        _buildSectionHeader('Story Controls'),
        ListTile(
          leading: const Icon(Icons.auto_stories),
          title: const Text('Story Settings'),
          subtitle: const Text('Control story replies and sharing'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showStoryControlsDialog(settings),
        ),

        _buildSectionHeader('Activity'),
        SwitchListTile(
          secondary: const Icon(Icons.visibility),
          title: const Text('Activity Status'),
          subtitle: const Text('Show when you were last active'),
          value: settings.showActivityStatus,
          onChanged: (value) {
            context.read<SettingsBloc>().add(ToggleActivityStatus(value));
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.favorite),
          title: const Text('Likes Count'),
          subtitle: const Text('Show number of likes on posts'),
          value: settings.showLikesCount,
          onChanged: (value) {
            context.read<SettingsBloc>().add(ToggleShowLikes(value));
          },
        ),

        _buildSectionHeader('Blocked Accounts'),
        ListTile(
          leading: const Icon(Icons.block),
          title: const Text('Blocked Accounts'),
          subtitle: const Text('Manage blocked users'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/settings/blocked'),
        ),
        ListTile(
          leading: const Icon(Icons.volume_off),
          title: const Text('Muted Accounts'),
          subtitle: const Text('Manage muted users'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/settings/muted'),
        ),
        ListTile(
          leading: const Icon(Icons.visibility_off),
          title: const Text('Restricted Accounts'),
          subtitle: const Text('Manage restricted users'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/settings/restricted'),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _showCommentControlsDialog(PrivacySettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comment Controls'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('Everyone'),
              value: true,
              groupValue: settings.allowCommentsFromEveryone,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateCommentControls(
                    value,
                    settings.commentFilterLevel,
                    settings.hideOffensiveComments,
                  ));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<bool>(
              title: const Text('People you follow'),
              value: false,
              groupValue: settings.allowCommentsFromEveryone,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateCommentControls(
                    !value,
                    settings.commentFilterLevel,
                    settings.hideOffensiveComments,
                  ));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTagControlsDialog(PrivacySettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tag Controls'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('Everyone'),
              value: true,
              groupValue: settings.allowTagsFromEveryone,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateTagControls(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<bool>(
              title: const Text('People you follow'),
              value: false,
              groupValue: settings.allowTagsFromEveryone,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateTagControls(!value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMentionControlsDialog(PrivacySettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mention Controls'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('Everyone'),
              value: true,
              groupValue: settings.allowMentionsFromEveryone,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateMentionControls(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<bool>(
              title: const Text('People you follow'),
              value: false,
              groupValue: settings.allowMentionsFromEveryone,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateMentionControls(!value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStoryControlsDialog(PrivacySettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Story Controls'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Allow Story Replies'),
              value: settings.allowStoryReplies,
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateStoryControls(
                  value,
                  settings.allowStorySharing,
                ));
              },
            ),
            SwitchListTile(
              title: const Text('Allow Story Sharing'),
              value: settings.allowStorySharing,
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateStoryControls(
                  settings.allowStoryReplies,
                  value,
                ));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}