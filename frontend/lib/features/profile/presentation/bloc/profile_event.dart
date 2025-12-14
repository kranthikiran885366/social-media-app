part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String userId;

  const LoadProfile({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> profileData;

  const UpdateProfile({required this.profileData});

  @override
  List<Object> get props => [profileData];
}

class FollowUser extends ProfileEvent {
  final String userId;

  const FollowUser({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UnfollowUser extends ProfileEvent {
  final String userId;

  const UnfollowUser({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadUserPosts extends ProfileEvent {
  final String userId;
  final int page;

  const LoadUserPosts({required this.userId, this.page = 1});

  @override
  List<Object> get props => [userId, page];
}

class UploadAvatar extends ProfileEvent {
  final String avatarUrl;

  const UploadAvatar({required this.avatarUrl});

  @override
  List<Object> get props => [avatarUrl];
}