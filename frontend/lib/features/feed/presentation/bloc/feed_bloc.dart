import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<RefreshFeed>(_onRefreshFeed);
    on<LoadMorePosts>(_onLoadMorePosts);
    on<LikePost>(_onLikePost);
    on<SavePost>(_onSavePost);
    on<FollowUser>(_onFollowUser);
    on<MuteUser>(_onMuteUser);
    on<ToggleLikeCountVisibility>(_onToggleLikeCountVisibility);
    on<TranslatePost>(_onTranslatePost);
    on<LikeComment>(_onLikeComment);
    on<PinComment>(_onPinComment);
  }

  void _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    
    await Future.delayed(const Duration(seconds: 1));
    
    final posts = _generateMockPosts();
    emit(FeedLoaded(posts: posts));
  }

  void _onRefreshFeed(RefreshFeed event, Emitter<FeedState> emit) async {
    final posts = _generateMockPosts();
    emit(FeedLoaded(posts: posts));
  }

  void _onLoadMorePosts(LoadMorePosts event, Emitter<FeedState> emit) async {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      emit(FeedLoadingMore(posts: currentState.posts));
      
      await Future.delayed(const Duration(seconds: 1));
      
      final newPosts = _generateMockPosts();
      emit(FeedLoaded(posts: [...currentState.posts, ...newPosts]));
    }
  }

  List<Post> _generateMockPosts() {
    return [
      Post(
        id: '1',
        userId: 'user1',
        username: 'john_doe',
        userAvatar: 'https://example.com/avatar1.jpg',
        content: 'Just finished reading an amazing book on productivity! 📚 #productivity #books @jane_smith',
        mediaUrls: ['https://example.com/book.jpg'],
        imageUrls: ['https://example.com/book.jpg'],
        likes: 42,
        comments: 8,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        qualityScore: 8.5,
        isVerified: true,
        location: 'New York, NY',
        hashtags: ['productivity', 'books'],
        mentions: ['jane_smith'],
        hasTranslation: true,
        translatedContent: 'Acabo de terminar de leer un libro increíble sobre productividad! 📚',
        inlineComments: [
          Comment(
            id: 'c1',
            userId: 'user2',
            username: 'jane_smith',
            userAvatar: 'https://example.com/avatar2.jpg',
            content: 'Great recommendation! 👍',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            likes: 5,
            isPinned: true,
          ),
        ],
      ),
      Post(
        id: 'sponsored_1',
        userId: 'brand1',
        username: 'techbrand',
        userAvatar: 'https://example.com/brand1.jpg',
        content: 'Discover the future of technology with our latest innovation! #tech #innovation',
        mediaUrls: ['https://example.com/tech_video.mp4'],
        videoUrls: ['https://example.com/tech_video.mp4'],
        likes: 156,
        comments: 23,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        qualityScore: 7.2,
        isSponsored: true,
        type: PostType.sponsored,
        hashtags: ['tech', 'innovation'],
      ),
      Post(
        id: '2',
        userId: 'user2',
        username: 'jane_smith',
        userAvatar: 'https://example.com/avatar2.jpg',
        content: 'Learned a new programming concept today. Growth mindset! 💻 #coding #learning',
        likes: 28,
        comments: 5,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        qualityScore: 7.8,
        hashtags: ['coding', 'learning'],
        type: PostType.photo,
      ),
    ];
  }

  void _onLikePost(LikePost event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likes: post.isLiked ? post.likes - 1 : post.likes + 1,
          );
        }
        return post;
      }).toList();
      emit(FeedLoaded(posts: updatedPosts));
    }
  }

  void _onSavePost(SavePost event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(isSaved: !post.isSaved);
        }
        return post;
      }).toList();
      emit(FeedLoaded(posts: updatedPosts));
    }
  }

  void _onFollowUser(FollowUser event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.userId == event.userId) {
          return post.copyWith(isFollowing: !post.isFollowing);
        }
        return post;
      }).toList();
      emit(FeedLoaded(posts: updatedPosts));
    }
  }

  void _onMuteUser(MuteUser event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.userId == event.userId) {
          return post.copyWith(isMuted: true);
        }
        return post;
      }).toList();
      emit(FeedLoaded(posts: updatedPosts));
      emit(UserMuted(event.userId));
    }
  }

  void _onToggleLikeCountVisibility(ToggleLikeCountVisibility event, Emitter<FeedState> emit) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(hideLikeCount: !post.hideLikeCount);
        }
        return post;
      }).toList();
      emit(FeedLoaded(posts: updatedPosts));
    }
  }

  void _onTranslatePost(TranslatePost event, Emitter<FeedState> emit) async {
    // Mock translation - in real app, call translation API
    emit(PostTranslated(postId: event.postId, translatedContent: 'Translated text here'));
  }

  void _onLikeComment(LikeComment event, Emitter<FeedState> emit) async {
    // Handle comment like
  }

  void _onPinComment(PinComment event, Emitter<FeedState> emit) async {
    // Handle pin comment
  }
}

class Post {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String content;
  final List<String> mediaUrls;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final double qualityScore;
  final bool isVerified;
  final String? location;
  final bool isSponsored;
  final bool isLiked;
  final bool isSaved;
  final bool isFollowing;
  final bool hideLikeCount;
  final List<Comment> inlineComments;
  final PostType type;
  final String? musicTitle;
  final String? musicArtist;
  final List<String> hashtags;
  final List<String> mentions;
  final bool hasTranslation;
  final String? translatedContent;
  final bool isMuted;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.content,
    this.mediaUrls = const [],
    this.imageUrls = const [],
    this.videoUrls = const [],
    required this.likes,
    required this.comments,
    required this.timestamp,
    required this.qualityScore,
    this.isVerified = false,
    this.location,
    this.isSponsored = false,
    this.isLiked = false,
    this.isSaved = false,
    this.isFollowing = true,
    this.hideLikeCount = false,
    this.inlineComments = const [],
    this.type = PostType.photo,
    this.musicTitle,
    this.musicArtist,
    this.hashtags = const [],
    this.mentions = const [],
    this.hasTranslation = false,
    this.translatedContent,
    this.isMuted = false,
  });

  Post copyWith({
    bool? isLiked,
    bool? isSaved,
    bool? isFollowing,
    int? likes,
    bool? hideLikeCount,
    List<Comment>? inlineComments,
    bool? isMuted,
  }) {
    return Post(
      id: id,
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      content: content,
      mediaUrls: mediaUrls,
      imageUrls: imageUrls,
      videoUrls: videoUrls,
      likes: likes ?? this.likes,
      comments: comments,
      timestamp: timestamp,
      qualityScore: qualityScore,
      isVerified: isVerified,
      location: location,
      isSponsored: isSponsored,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isFollowing: isFollowing ?? this.isFollowing,
      hideLikeCount: hideLikeCount ?? this.hideLikeCount,
      inlineComments: inlineComments ?? this.inlineComments,
      type: type,
      musicTitle: musicTitle,
      musicArtist: musicArtist,
      hashtags: hashtags,
      mentions: mentions,
      hasTranslation: hasTranslation,
      translatedContent: translatedContent,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

enum PostType { photo, video, carousel, sponsored, suggested }

class Comment {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;
  final bool isPinned;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.isPinned = false,
    this.replies = const [],
  });
}

class SuggestedUser {
  final String id;
  final String username;
  final String avatar;
  final String fullName;
  final bool isVerified;
  final bool isFollowing;
  final String reason;

  SuggestedUser({
    required this.id,
    required this.username,
    required this.avatar,
    required this.fullName,
    this.isVerified = false,
    this.isFollowing = false,
    required this.reason,
  });
}