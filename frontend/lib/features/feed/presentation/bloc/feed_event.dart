part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

class LoadFeed extends FeedEvent {}

class RefreshFeed extends FeedEvent {}

class LoadMorePosts extends FeedEvent {}

class LikePost extends FeedEvent {
  final String postId;
  const LikePost(this.postId);
  
  @override
  List<Object> get props => [postId];
}

class UnlikePost extends FeedEvent {
  final String postId;
  const UnlikePost(this.postId);
  
  @override
  List<Object> get props => [postId];
}

class SavePost extends FeedEvent {
  final String postId;
  const SavePost(this.postId);
  
  @override
  List<Object> get props => [postId];
}

class UnsavePost extends FeedEvent {
  final String postId;
  const UnsavePost(this.postId);
  
  @override
  List<Object> get props => [postId];
}

class SharePost extends FeedEvent {
  final String postId;
  const SharePost(this.postId);
  
  @override
  List<Object> get props => [postId];
}

class ReportPost extends FeedEvent {
  final String postId;
  final String reason;
  const ReportPost(this.postId, this.reason);
  
  @override
  List<Object> get props => [postId, reason];
}

class HidePost extends FeedEvent {
  final String postId;
  const HidePost(this.postId);
  
  @override
  List<Object> get props => [postId];
}

class FollowUser extends FeedEvent {
  final String userId;
  const FollowUser(this.userId);
  
  @override
  List<Object> get props => [userId];
}

class UnfollowUser extends FeedEvent {
  final String userId;
  const UnfollowUser(this.userId);
  
  @override
  List<Object> get props => [userId];
}

class MuteUser extends FeedEvent {
  final String userId;
  const MuteUser(this.userId);
  
  @override
  List<Object> get props => [userId];
}

class ToggleLikeCountVisibility extends FeedEvent {
  final String postId;
  const ToggleLikeCountVisibility(this.postId);
  
  @override
  List<Object> get props => [postId];
}

class TranslatePost extends FeedEvent {
  final String postId;
  const TranslatePost(this.postId);
  
  @override
  List<Object> get props => [postId];
}

class LikeComment extends FeedEvent {
  final String postId;
  final String commentId;
  const LikeComment(this.postId, this.commentId);
  
  @override
  List<Object> get props => [postId, commentId];
}

class PinComment extends FeedEvent {
  final String postId;
  final String commentId;
  const PinComment(this.postId, this.commentId);
  
  @override
  List<Object> get props => [postId, commentId];
}

class ShareToDM extends FeedEvent {
  final String postId;
  final List<String> userIds;
  const ShareToDM(this.postId, this.userIds);
  
  @override
  List<Object> get props => [postId, userIds];
}

class ShareToStory extends FeedEvent {
  final String postId;
  const ShareToStory(this.postId);
  
  @override
  List<Object> get props => [postId];
}

class AddToCollection extends FeedEvent {
  final String postId;
  final String collectionId;
  const AddToCollection(this.postId, this.collectionId);
  
  @override
  List<Object> get props => [postId, collectionId];
}