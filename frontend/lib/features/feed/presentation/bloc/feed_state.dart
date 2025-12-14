part of 'feed_bloc.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Post> posts;
  final bool hasReachedMax;
  final int currentPage;

  const FeedLoaded({
    required this.posts,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  FeedLoaded copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [posts, hasReachedMax, currentPage];
}

class FeedLoadingMore extends FeedState {
  final List<Post> posts;

  const FeedLoadingMore({required this.posts});

  @override
  List<Object> get props => [posts];
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object> get props => [message];
}

class PostLiked extends FeedState {
  final String postId;
  final int likesCount;

  const PostLiked({required this.postId, required this.likesCount});

  @override
  List<Object> get props => [postId, likesCount];
}

class PostSaved extends FeedState {
  final String postId;
  final bool isSaved;

  const PostSaved({required this.postId, required this.isSaved});

  @override
  List<Object> get props => [postId, isSaved];
}

class PostShared extends FeedState {
  final String postId;

  const PostShared(this.postId);

  @override
  List<Object> get props => [postId];
}

class UserFollowed extends FeedState {
  final String userId;
  final bool isFollowing;

  const UserFollowed({required this.userId, required this.isFollowing});

  @override
  List<Object> get props => [userId, isFollowing];
}

class UserMuted extends FeedState {
  final String userId;

  const UserMuted(this.userId);

  @override
  List<Object> get props => [userId];
}

class PostTranslated extends FeedState {
  final String postId;
  final String translatedContent;

  const PostTranslated({required this.postId, required this.translatedContent});

  @override
  List<Object> get props => [postId, translatedContent];
}

class CommentLiked extends FeedState {
  final String postId;
  final String commentId;
  final bool isLiked;

  const CommentLiked({required this.postId, required this.commentId, required this.isLiked});

  @override
  List<Object> get props => [postId, commentId, isLiked];
}