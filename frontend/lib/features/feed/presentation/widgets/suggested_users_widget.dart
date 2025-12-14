import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/feed_bloc.dart';

class SuggestedUsersWidget extends StatelessWidget {
  const SuggestedUsersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestedUsers = _getMockSuggestedUsers();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suggested for you',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: suggestedUsers.length,
              itemBuilder: (context, index) {
                final user = suggestedUsers[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: CachedNetworkImageProvider(user.avatar),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (user.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Colors.blue, size: 14),
                          ],
                        ],
                      ),
                      Text(
                        user.fullName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.reason,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle follow action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Follow', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<SuggestedUser> _getMockSuggestedUsers() {
    return [
      SuggestedUser(
        id: 'user1',
        username: 'alex_dev',
        avatar: 'https://example.com/avatar1.jpg',
        fullName: 'Alex Developer',
        isVerified: true,
        reason: 'Followed by john_doe and 3 others',
      ),
      SuggestedUser(
        id: 'user2',
        username: 'sarah_design',
        avatar: 'https://example.com/avatar2.jpg',
        fullName: 'Sarah Designer',
        reason: 'Popular in your area',
      ),
      SuggestedUser(
        id: 'user3',
        username: 'tech_guru',
        avatar: 'https://example.com/avatar3.jpg',
        fullName: 'Tech Guru',
        isVerified: true,
        reason: 'Similar interests',
      ),
    ];
  }
}