import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/message_models.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/search_bar.dart';
import 'chat_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isTablet ? 24 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: isTablet ? 8 : 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textPrimary,
                        size: isTablet ? 24 : 20,
                      ),
                    ],
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
                actions: [
                  Container(
                    margin: EdgeInsets.only(
                      right: isTablet ? 8 : 4,
                      top: isTablet ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.video_call_outlined,
                        color: AppColors.primary,
                        size: isTablet ? 28 : 24,
                      ),
                      onPressed: () => _startVideoCall(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      right: isTablet ? 24 : 16,
                      top: isTablet ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                      onPressed: () => _newMessage(),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(isTablet ? 60 : 48),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: const [
                        Tab(text: 'Primary'),
                        Tab(text: 'General'),
                        Tab(text: 'Requests'),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(isTablet ? 24 : 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: isTablet ? 15 : 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search messages...',
                      hintStyle: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: isTablet ? 18 : 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: isTablet ? 28 : 24,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 20,
                        vertical: isTablet ? 20 : 16,
                      ),
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChatList(_getPrimaryChats(), isTablet),
                    _buildChatList(_getGeneralChats(), isTablet),
                    _buildRequestsList(isTablet),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatList(List<Chat> chats, bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
      ),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return Container(
          margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: isTablet ? 8 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ChatListItem(
            chat: chat,
            onTap: () => _openChat(chat),
            onLongPress: () => _showChatOptions(chat, isTablet),
          ),
        );
      },
    );
  }

  Widget _buildRequestsList(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: isTablet ? 10 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: isTablet ? 32 : 28,
                  backgroundImage: NetworkImage(
                    'https://picsum.photos/100/100?random=${index + 20}',
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'user${index + 1}',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      'Wants to send you a message',
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: isTablet ? 40 : 32,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: isTablet ? 8 : 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'Accept',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 12 : 8),
                        Expanded(
                          child: Container(
                            height: isTablet ? 40 : 32,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(
                                color: AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                            ),
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Chat> _getPrimaryChats() {
    return List.generate(10, (index) => Chat(
      id: 'chat_$index',
      type: ChatType.direct,
      participants: ['user1', 'user2'],
      name: 'User ${index + 1}',
      lastMessage: Message(
        id: 'msg_$index',
        chatId: 'chat_$index',
        senderId: 'user2',
        type: MessageType.text,
        content: 'Last message content...',
        timestamp: DateTime.now().subtract(Duration(hours: index)),
        status: MessageStatus.read,
      ),
      isPinned: index < 2,
    ));
  }

  List<Chat> _getGeneralChats() {
    return List.generate(5, (index) => Chat(
      id: 'general_$index',
      type: ChatType.group,
      participants: ['user1', 'user2', 'user3'],
      name: 'Group ${index + 1}',
      lastMessage: Message(
        id: 'msg_general_$index',
        chatId: 'general_$index',
        senderId: 'user2',
        type: MessageType.text,
        content: 'Group message...',
        timestamp: DateTime.now().subtract(Duration(days: index)),
        status: MessageStatus.delivered,
      ),
    ));
  }

  void _openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(chat: chat),
      ),
    );
  }

  void _showChatOptions(Chat chat, bool isTablet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTablet ? 24 : 16),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDBDBDB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                chat.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                color: Colors.black,
              ),
              title: Text(
                chat.isPinned ? 'Unpin' : 'Pin',
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(
                chat.isMuted ? Icons.volume_up : Icons.volume_off,
                color: Colors.black,
              ),
              title: Text(
                chat.isMuted ? 'Unmute' : 'Mute',
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              title: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _startVideoCall() {}
  void _newMessage() {}
}