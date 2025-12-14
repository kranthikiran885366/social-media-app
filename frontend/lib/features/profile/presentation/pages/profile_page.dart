import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isCurrentUser = true;
  bool _isFollowing = false;
  bool _isPrivate = false;
  
  final UserProfile _userProfile = UserProfile(
    id: 'user_123',
    username: 'john_doe',
    displayName: 'John Doe',
    bio: 'Passionate learner and creator 🚀\nBuilding the future, one post at a time\n📍 San Francisco, CA',
    profileImage: 'https://example.com/profile.jpg',
    isVerified: true,
    isPrivate: false,
    postsCount: 127,
    followersCount: 15600,
    followingCount: 892,
    website: 'https://johndoe.com',
    category: 'Creator',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _isCurrentUser = widget.userId == 'current_user';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              title: Text(
                _userProfile.username,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              actions: [
                if (_isCurrentUser) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      onPressed: _createPost,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: _handleMenuAction,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_rounded),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'settings', child: Text('Settings')),
                      const PopupMenuItem(value: 'archive', child: Text('Archive')),
                      const PopupMenuItem(value: 'activity', child: Text('Your Activity')),
                      const PopupMenuItem(value: 'qr', child: Text('QR Code')),
                    ],
                  ),
                ] else ...[
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: _showUserOptions,
                    ),
                  ),
                ],
              ],
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildProfileStats(),
                  _buildProfileBio(),
                  _buildActionButtons(),
                  _buildHighlights(),
                  _buildTabBar(),
                ],
              ),
            ),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: CachedNetworkImageProvider(_userProfile.profileImage),
                  ),
                ),
              ),
              if (_isCurrentUser)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.secondaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 20),
          
          // Stats
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Posts', _userProfile.postsCount),
                _buildStatColumn('Followers', _userProfile.followersCount),
                _buildStatColumn('Following', _userProfile.followingCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return GestureDetector(
      onTap: () => _showStatDetails(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              _formatCount(count),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBio() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _userProfile.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (_userProfile.isVerified) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (_userProfile.category != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _userProfile.category!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _userProfile.bio,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (_userProfile.website != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _openWebsite(_userProfile.website!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _userProfile.website!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Container(); // Placeholder for additional stats
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_isCurrentUser) ...[
            Expanded(
              child: _buildButton(
                text: 'Edit Profile',
                onPressed: _editProfile,
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildButton(
                text: 'Share Profile',
                onPressed: _shareProfile,
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                icon: const Icon(Icons.person_add, size: 16),
                onPressed: _suggestToFriends,
                padding: EdgeInsets.zero,
              ),
            ),
          ] else ...[
            Expanded(
              flex: 3,
              child: _buildButton(
                text: _isFollowing ? 'Following' : 'Follow',
                onPressed: _toggleFollow,
                isPrimary: !_isFollowing,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildButton(
                text: 'Message',
                onPressed: _sendMessage,
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                onPressed: _showMoreOptions,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 44,
      decoration: isPrimary
          ? BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            )
          : BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _isCurrentUser ? 6 : 5, // +1 for "New" button
        itemBuilder: (context, index) {
          if (_isCurrentUser && index == 0) {
            return _buildNewHighlightButton();
          }
          
          return _buildHighlightItem(
            title: 'Highlight ${index + 1}',
            imageUrl: 'https://example.com/highlight$index.jpg',
          );
        },
      ),
    );
  }

  Widget _buildNewHighlightButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: _createHighlight,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: const Icon(Icons.add, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'New',
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightItem({
    required String title,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _viewHighlight(title),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: CachedNetworkImageProvider(imageUrl),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                title,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.grid_on_rounded, size: 24)),
          Tab(icon: Icon(Icons.video_library_rounded, size: 24)),
          Tab(icon: Icon(Icons.person_pin_rounded, size: 24)),
          Tab(icon: Icon(Icons.bookmark_rounded, size: 24)),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsGrid(),
          _buildReelsGrid(),
          _buildTaggedGrid(),
          _buildSavedGrid(),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    return MasonryGridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      itemCount: 30,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _viewPost(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            child: AspectRatio(
              aspectRatio: index % 3 == 0 ? 1.0 : 0.8,
              child: CachedNetworkImage(
                imageUrl: 'https://example.com/post$index.jpg',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReelsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.6,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _viewReel(index),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                ),
                child: CachedNetworkImage(
                  imageUrl: 'https://example.com/reel$index.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned(
                bottom: 8,
                left: 8,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Text(
                  '${(index + 1) * 1000}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaggedGrid() {
    if (!_isCurrentUser && _isPrivate) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'This Account is Private',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Follow to see their photos and videos.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _viewTaggedPost(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            child: CachedNetworkImage(
              imageUrl: 'https://example.com/tagged$index.jpg',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedGrid() {
    if (!_isCurrentUser) {
      return const Center(
        child: Text('Only you can see what you\'ve saved'),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _viewSavedPost(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            child: CachedNetworkImage(
              imageUrl: 'https://example.com/saved$index.jpg',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  // Action methods
  void _createPost() {}
  void _handleMenuAction(String action) {}
  void _showUserOptions() {}
  void _showStatDetails(String label) {}
  void _openWebsite(String url) {}
  void _editProfile() {}
  void _shareProfile() {}
  void _suggestToFriends() {}
  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }
  void _sendMessage() {}
  void _showMoreOptions() {}
  void _createHighlight() {}
  void _viewHighlight(String title) {}
  void _viewPost(int index) {}
  void _viewReel(int index) {}
  void _viewTaggedPost(int index) {}
  void _viewSavedPost(int index) {}
}

class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String profileImage;
  final bool isVerified;
  final bool isPrivate;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final String? website;
  final String? category;

  UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.profileImage,
    required this.isVerified,
    required this.isPrivate,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    this.website,
    this.category,
  });
}