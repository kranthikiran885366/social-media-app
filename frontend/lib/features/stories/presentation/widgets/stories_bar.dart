import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../pages/stories_viewer_page.dart';

class StoriesBar extends StatelessWidget {
  final List<StoryUser> storyUsers;
  final VoidCallback onAddStory;

  const StoriesBar({
    super.key,
    required this.storyUsers,
    required this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: storyUsers.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryButton();
          }
          
          final storyUser = storyUsers[index - 1];
          return _buildStoryItem(context, storyUser, index - 1);
        },
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onAddStory,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Your Story',
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, StoryUser storyUser, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => _openStoryViewer(context, index),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: storyUser.hasUnseenStories
                    ? const LinearGradient(
                        colors: [Colors.purple, Colors.pink, Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: !storyUser.hasUnseenStories
                    ? Border.all(color: Colors.grey[300]!, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: CachedNetworkImageProvider(storyUser.profileImage),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                storyUser.username,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: storyUser.hasUnseenStories
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
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

  void _openStoryViewer(BuildContext context, int initialIndex) {
    // Convert StoryUser to Story list for viewer
    final stories = storyUsers.map((user) => Story(
      id: user.stories.first.id,
      userId: user.id,
      username: user.username,
      userAvatar: user.profileImage,
      mediaUrl: user.stories.first.mediaUrl,
      mediaType: user.stories.first.mediaType,
      text: user.stories.first.text,
      createdAt: user.stories.first.createdAt,
      viewers: user.stories.first.viewers,
      viewCount: user.stories.first.viewCount,
    )).toList();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StoriesViewerPage(
          stories: stories,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

class StoryUser {
  final String id;
  final String username;
  final String profileImage;
  final List<StoryItem> stories;
  final bool hasUnseenStories;

  StoryUser({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.stories,
    required this.hasUnseenStories,
  });
}

class StoryItem {
  final String id;
  final String mediaUrl;
  final String mediaType;
  final String? text;
  final DateTime createdAt;
  final List<String> viewers;
  final int viewCount;

  StoryItem({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    this.text,
    required this.createdAt,
    required this.viewers,
    required this.viewCount,
  });
}