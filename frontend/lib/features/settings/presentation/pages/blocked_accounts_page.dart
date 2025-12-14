import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/settings_models.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class BlockedAccountsPage extends StatefulWidget {
  const BlockedAccountsPage({super.key});

  @override
  State<BlockedAccountsPage> createState() => _BlockedAccountsPageState();
}

class _BlockedAccountsPageState extends State<BlockedAccountsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadBlockedAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Accounts'),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is AccountUnblocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account unblocked')),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BlockedAccountsLoaded) {
            return _buildBlockedAccountsList(state.accounts);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBlockedAccountsList(List<BlockedAccount> accounts) {
    if (accounts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No blocked accounts',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Accounts you block will appear here',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: account.avatar != null
                  ? NetworkImage(account.avatar!)
                  : null,
              child: account.avatar == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              account.displayName ?? account.username,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${account.username}'),
                const SizedBox(height: 4),
                Text(
                  'Blocked ${timeago.format(account.blockedAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: OutlinedButton(
              onPressed: () => _showUnblockDialog(account),
              child: const Text('Unblock'),
            ),
          ),
        );
      },
    );
  }

  void _showUnblockDialog(BlockedAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock Account'),
        content: Text(
          'Are you sure you want to unblock @${account.username}? They will be able to follow you and see your posts again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SettingsBloc>().add(UnblockAccount(account.userId));
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }
}