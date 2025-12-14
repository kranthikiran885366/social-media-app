import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

part 'stories_event.dart';
part 'stories_state.dart';

class StoriesBloc extends Bloc<StoriesEvent, StoriesState> {
  StoriesBloc() : super(StoriesInitial()) {
    on<LoadStories>(_onLoadStories);
    on<CreateStory>(_onCreateStory);
    on<ViewStory>(_onViewStory);
  }

  void _onLoadStories(LoadStories event, Emitter<StoriesState> emit) async {
    emit(StoriesLoading());
    try {
      final result = await ApiService.getPosts(page: 1, limit: 50);
      if (result['success']) {
        final storiesData = result['data']['stories'] as List? ?? [];
        final stories = storiesData.map((data) => Story.fromJson(data)).toList();
        emit(StoriesLoaded(stories));
      } else {
        emit(StoriesError(result['error']));
      }
    } catch (e) {
      emit(StoriesError(e.toString()));
    }
  }

  void _onCreateStory(CreateStory event, Emitter<StoriesState> emit) async {
    try {
      final result = await ApiService.createPost({
        'type': 'story',
        'mediaUrl': event.mediaUrl,
        'mediaType': event.type.toString(),
      });
      
      if (result['success']) {
        add(LoadStories());
      }
    } catch (e) {
      emit(StoriesError(e.toString()));
    }
  }

  void _onViewStory(ViewStory event, Emitter<StoriesState> emit) async {
    // Mark story as viewed
  }
}

class Story {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String mediaUrl;
  final StoryType type;
  final DateTime timestamp;
  final bool isViewed;

  Story({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.mediaUrl,
    required this.type,
    required this.timestamp,
    required this.isViewed,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      type: StoryType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => StoryType.image,
      ),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isViewed: json['isViewed'] ?? false,
    );
  }
}

enum StoryType { image, video }