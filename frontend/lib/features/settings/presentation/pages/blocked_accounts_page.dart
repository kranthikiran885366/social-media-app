import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_colors.dart';
import '../../data/models/settings_models.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart;

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
                    'Blocked Accounts',
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
              ),
              SliverToBoxAdapter(
                child: BlocConsumer<SettingsBloc, SettingsState>(
                  listener: (context, state) {
                    if (state is AccountUnblocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Account unblocked'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    } else if (state is SettingsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is SettingsLoading) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                      );
                    }

                    if (state is BlockedAccountsLoaded) {
                      return _buildBlockedAccountsList(state.accounts, isTablet);
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

  Widget _buildBlockedAccountsList(List<BlockedAccount> accounts, bool isTablet) {
    if (accounts.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block,
                  size: isTablet ? 80 : 64,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                'No blocked accounts',
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Accounts you block will appear here',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Container(
          margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
          padding: EdgeInsets.all(isTablet ? 20 : 16),
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
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: isTablet ? 28 : 24,
                  backgroundImage: account.avatar != null
                      ? NetworkImage(account.avatar!)
                      : null,
                  child: account.avatar == null
                      ? Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: isTablet ? 32 : 28,
                        )
                      : null,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName ?? account.username,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 18 : 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      '@${account.username}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Blocked ${timeago.format(account.blockedAt)}',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: isTablet ? 48 : 40,
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    onTap: () => _showUnblockDialog(account),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                      ),
                      child: Center(
                        child: Text(
                          'Unblock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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