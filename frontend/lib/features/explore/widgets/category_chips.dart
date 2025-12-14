import 'package:flutter/material.dart';
import '../models/explore_models.dart';

class CategoryChips extends StatelessWidget {
  final ExploreCategory selectedCategory;
  final Function(ExploreCategory) onCategoryChanged;

  const CategoryChips({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ExploreCategory.values.length,
        itemBuilder: (context, index) {
          final category = ExploreCategory.values[index];
          final isSelected = category == selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getCategoryName(category)),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category),
              selectedColor: Colors.black,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCategoryName(ExploreCategory category) {
    switch (category) {
      case ExploreCategory.all:
        return 'All';
      case ExploreCategory.travel:
        return 'Travel';
      case ExploreCategory.food:
        return 'Food';
      case ExploreCategory.art:
        return 'Art';
      case ExploreCategory.fashion:
        return 'Fashion';
      case ExploreCategory.fitness:
        return 'Fitness';
      case ExploreCategory.technology:
        return 'Tech';
      case ExploreCategory.music:
        return 'Music';
      case ExploreCategory.nature:
        return 'Nature';
      case ExploreCategory.photography:
        return 'Photo';
      case ExploreCategory.lifestyle:
        return 'Lifestyle';
      case ExploreCategory.business:
        return 'Business';
      case ExploreCategory.education:
        return 'Education';
      case ExploreCategory.entertainment:
        return 'Entertainment';
      case ExploreCategory.sports:
        return 'Sports';
      case ExploreCategory.beauty:
        return 'Beauty';
      case ExploreCategory.diy:
        return 'DIY';
      case ExploreCategory.pets:
        return 'Pets';
      case ExploreCategory.gaming:
        return 'Gaming';
      case ExploreCategory.science:
        return 'Science';
    }
  }
}

class ExploreGridItem extends StatelessWidget {
  final ExploreContent content;
  final VoidCallback onTap;

  const ExploreGridItem({
    Key? key,
    required this.content,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              content.mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),

          // Overlay for reels
          if (content.type == 'reel')
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

          // Sponsored indicator
          if (content.isSponsored)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Sponsored',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Engagement overlay
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (content.likes > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.white, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          _formatCount(content.likes),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (content.views > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility, color: Colors.white, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          _formatCount(content.views),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
}

class TrendingSection extends StatelessWidget {
  final List<TrendingHashtag> hashtags;
  final List<SuggestedAccount> accounts;
  final List<TrendingSound> sounds;
  final Function(TrendingHashtag) onHashtagTap;
  final Function(SuggestedAccount) onAccountTap;
  final Function(TrendingSound) onSoundTap;

  const TrendingSection({
    Key? key,
    required this.hashtags,
    required this.accounts,
    required this.sounds,
    required this.onHashtagTap,
    required this.onAccountTap,
    required this.onSoundTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trending Hashtags
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Trending',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: hashtags.length,
            itemBuilder: (context, index) {
              final hashtag = hashtags[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(hashtag.hashtag),
                      if (hashtag.isRising) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.trending_up, size: 16, color: Colors.green),
                      ],
                    ],
                  ),
                  onPressed: () => onHashtagTap(hashtag),
                  backgroundColor: Colors.grey[100],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Trending Sounds
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Trending Audio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sounds.length,
            itemBuilder: (context, index) {
              final sound = sounds[index];
              return GestureDetector(
                onTap: () => onSoundTap(sound),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.music_note, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sound.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              sound.artist,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${sound.usageCount} uses',
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class SuggestedAccountsSection extends StatelessWidget {
  final List<SuggestedAccount> accounts;
  final Function(SuggestedAccount) onAccountTap;
  final Function(SuggestedAccount) onFollowTap;

  const SuggestedAccountsSection({
    Key? key,
    required this.accounts,
    required this.onAccountTap,
    required this.onFollowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Suggested for you',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return GestureDetector(
                onTap: () => onAccountTap(account),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(account.avatar),
                          ),
                          if (account.isVerified)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        account.username,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => onFollowTap(account),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: account.isFollowing ? Colors.grey[300] : Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            account.isFollowing ? 'Following' : 'Follow',
                            style: TextStyle(
                              color: account.isFollowing ? Colors.black : Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}