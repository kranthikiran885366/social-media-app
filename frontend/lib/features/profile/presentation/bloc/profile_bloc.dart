import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);
    on<LoadUserPosts>(_onLoadUserPosts);
    on<UploadAvatar>(_onUploadAvatar);
  }

  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final result = await ApiService.getUserProfile(event.userId);
      if (result['success']) {
        final profileData = result['data']['user'];
        final profile = UserProfile.fromJson(profileData);
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError(result['error']));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    try {
      final result = await ApiService.updateProfile(event.profileData);
      if (result['success']) {
        add(LoadProfile(userId: event.profileData['userId']));
      } else {
        emit(ProfileError(result['error']));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onFollowUser(FollowUser event, Emitter<ProfileState> emit) async {
    try {
      final result = await ApiService.followUser(event.userId);
      if (result['success']) {
        if (state is ProfileLoaded) {
          final currentState = state as ProfileLoaded;
          final updatedProfile = currentState.profile.copyWith(
            isFollowing: true,
            followersCount: currentState.profile.followersCount + 1,
          );
          emit(ProfileLoaded(updatedProfile));
        }
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onUnfollowUser(UnfollowUser event, Emitter<ProfileState> emit) async {
    try {
      // Call unfollow API
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        final updatedProfile = currentState.profile.copyWith(
          isFollowing: false,
          followersCount: currentState.profile.followersCount - 1,
        );
        emit(ProfileLoaded(updatedProfile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onLoadUserPosts(LoadUserPosts event, Emitter<ProfileState> emit) async {
    try {
      final result = await ApiService.getPosts(page: event.page);
      if (result['success']) {
        final postsData = result['data']['posts'] as List? ?? [];
        // Handle posts loading
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onUploadAvatar(UploadAvatar event, Emitter<ProfileState> emit) async {
    try {
      // Handle avatar upload
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        final updatedProfile = currentState.profile.copyWith(
          avatar: event.avatarUrl,
        );
        emit(ProfileLoaded(updatedProfile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}

class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String avatar;
  final String coverImage;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isVerified;
  final bool isFollowing;
  final bool isPrivate;

  UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatar,
    required this.coverImage,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.isVerified,
    required this.isFollowing,
    required this.isPrivate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      bio: json['bio'] ?? '',
      avatar: json['avatar'] ?? '',
      coverImage: json['coverImage'] ?? '',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? bio,
    String? avatar,
    String? coverImage,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isFollowing,
  }) {
    return UserProfile(
      id: id,
      username: username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      coverImage: coverImage ?? this.coverImage,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isVerified: isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
      isPrivate: isPrivate,
    );
  }
}