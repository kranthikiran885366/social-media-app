part of 'stories_bloc.dart';

abstract class StoriesEvent extends Equatable {
  const StoriesEvent();

  @override
  List<Object> get props => [];
}

class LoadStories extends StoriesEvent {}

class CreateStory extends StoriesEvent {
  final String mediaUrl;
  final StoryType type;

  const CreateStory({required this.mediaUrl, required this.type});

  @override
  List<Object> get props => [mediaUrl, type];
}

class ViewStory extends StoriesEvent {
  final String storyId;

  const ViewStory({required this.storyId});

  @override
  List<Object> get props => [storyId];
}