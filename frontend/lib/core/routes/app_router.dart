import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/landing/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/main/presentation/pages/main_navigation_page.dart' hide ChatListPage, ExplorePage;
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/create_post/presentation/pages/create_post_page.dart';
import '../../features/stories/presentation/pages/stories_viewer_page.dart';
import '../../features/stories/models/story_models.dart' hide Story;
import '../../features/direct_messages/presentation/pages/chat_list_page.dart' as dm;
import '../../features/direct_messages/presentation/pages/chat_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart' as explore;
import '../../features/activity/presentation/pages/activity_page.dart' as activity;
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Landing Page
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingPage(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainNavigationPage(),
      ),
      
      // Profile Routes
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfilePage(userId: userId);
        },
      ),
      
      // Create Post
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreatePostPage(),
      ),
      
      // Stories
      GoRoute(
        path: '/stories/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return const StoriesViewerPage();
        },
      ),
      
      // Direct Messages
      GoRoute(
        path: '/messages',
        builder: (context, state) => const dm.ChatListPage(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatPage(chatId: chatId);
        },
      ),
      
      // Explore
      GoRoute(
        path: '/explore',
        builder: (context, state) => const explore.ExplorePage(),
      ),
      
      // Activity
      GoRoute(
        path: '/activity',
        builder: (context, state) => const activity.ActivityPage(),
      ),
      
      // Settings
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      
      // Search Results
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchResultsPage(query: query);
        },
      ),
      
      // Hashtag Feed
      GoRoute(
        path: '/hashtag/:tag',
        builder: (context, state) {
          final tag = state.pathParameters['tag']!;
          return HashtagFeedPage(hashtag: tag);
        },
      ),
      
      // Location Feed
      GoRoute(
        path: '/location/:locationId',
        builder: (context, state) {
          final locationId = state.pathParameters['locationId']!;
          return LocationFeedPage(locationId: locationId);
        },
      ),
      
      // Post Details
      GoRoute(
        path: '/post/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailsPage(postId: postId);
        },
      ),
      
      // Live Streaming
      GoRoute(
        path: '/live/:streamId',
        builder: (context, state) {
          final streamId = state.pathParameters['streamId']!;
          return LiveStreamPage(streamId: streamId);
        },
      ),
      
      // Shopping
      GoRoute(
        path: '/shop',
        builder: (context, state) => const ShopPage(),
      ),
      GoRoute(
        path: '/product/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailsPage(productId: productId);
        },
      ),
    ],
  );
}

// Placeholder pages - implement these in their respective feature folders
class SearchResultsPage extends StatelessWidget {
  final String query;
  const SearchResultsPage({super.key, required this.query});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search: $query')),
      body: const Center(child: Text('Search Results')),
    );
  }
}

class HashtagFeedPage extends StatelessWidget {
  final String hashtag;
  const HashtagFeedPage({super.key, required this.hashtag});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#$hashtag')),
      body: const Center(child: Text('Hashtag Feed')),
    );
  }
}

class LocationFeedPage extends StatelessWidget {
  final String locationId;
  const LocationFeedPage({super.key, required this.locationId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: const Center(child: Text('Location Feed')),
    );
  }
}

class PostDetailsPage extends StatelessWidget {
  final String postId;
  const PostDetailsPage({super.key, required this.postId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: const Center(child: Text('Post Details')),
    );
  }
}

class LiveStreamPage extends StatelessWidget {
  final String streamId;
  const LiveStreamPage({super.key, required this.streamId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live')),
      body: const Center(child: Text('Live Stream')),
    );
  }
}

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: const Center(child: Text('Shopping')),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: const Center(child: Text('Product Details')),
    );
  }
}