part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchQuery extends SearchEvent {
  final String query;
  const SearchQuery(this.query);
  
  @override
  List<Object> get props => [query];
}

class LoadSuggestions extends SearchEvent {
  final String query;
  const LoadSuggestions(this.query);
  
  @override
  List<Object> get props => [query];
}

class LoadRecentSearches extends SearchEvent {}

class LoadTrendingSearches extends SearchEvent {}

class ClearSearchHistory extends SearchEvent {}

class RemoveRecentSearch extends SearchEvent {
  final String searchId;
  const RemoveRecentSearch(this.searchId);
  
  @override
  List<Object> get props => [searchId];
}

class FollowUserFromSearch extends SearchEvent {
  final String userId;
  final bool isCurrentlyFollowing;
  
  const FollowUserFromSearch({
    required this.userId,
    required this.isCurrentlyFollowing,
  });
  
  @override
  List<Object> get props => [userId, isCurrentlyFollowing];
}

class SearchAccounts extends SearchEvent {
  final String query;
  const SearchAccounts(this.query);
  
  @override
  List<Object> get props => [query];
}

class SearchHashtags extends SearchEvent {
  final String query;
  const SearchHashtags(this.query);
  
  @override
  List<Object> get props => [query];
}

class SearchSounds extends SearchEvent {
  final String query;
  const SearchSounds(this.query);
  
  @override
  List<Object> get props => [query];
}

class SearchLocations extends SearchEvent {
  final String query;
  const SearchLocations(this.query);
  
  @override
  List<Object> get props => [query];
}

class SearchPosts extends SearchEvent {
  final String query;
  const SearchPosts(this.query);
  
  @override
  List<Object> get props => [query];
}

class GetTopResults extends SearchEvent {
  final String query;
  const GetTopResults(this.query);
  
  @override
  List<Object> get props => [query];
}