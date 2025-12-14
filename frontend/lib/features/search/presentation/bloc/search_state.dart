part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final String query;
  final List<SearchResult> results;
  final List<SearchResult> topResults;

  const SearchLoaded({
    required this.query,
    required this.results,
    required this.topResults,
  });

  @override
  List<Object> get props => [query, results, topResults];
}

class SuggestionsLoading extends SearchState {}

class SuggestionsLoaded extends SearchState {
  final List<SearchSuggestion> suggestions;

  const SuggestionsLoaded({required this.suggestions});

  @override
  List<Object> get props => [suggestions];
}

class RecentSearchesLoaded extends SearchState {
  final List<RecentSearch> recentSearches;

  const RecentSearchesLoaded({required this.recentSearches});

  @override
  List<Object> get props => [recentSearches];
}

class TrendingSearchesLoaded extends SearchState {
  final List<TrendingSearch> trendingSearches;

  const TrendingSearchesLoaded({required this.trendingSearches});

  @override
  List<Object> get props => [trendingSearches];
}

class SearchHistoryCleared extends SearchState {}

class UserFollowedFromSearch extends SearchState {
  final String userId;
  final bool isFollowing;

  const UserFollowedFromSearch({
    required this.userId,
    required this.isFollowing,
  });

  @override
  List<Object> get props => [userId, isFollowing];
}

class AccountSearchLoaded extends SearchState {
  final String query;
  final List<SearchAccount> accounts;

  const AccountSearchLoaded({
    required this.query,
    required this.accounts,
  });

  @override
  List<Object> get props => [query, accounts];
}

class HashtagSearchLoaded extends SearchState {
  final String query;
  final List<SearchHashtag> hashtags;

  const HashtagSearchLoaded({
    required this.query,
    required this.hashtags,
  });

  @override
  List<Object> get props => [query, hashtags];
}

class SoundSearchLoaded extends SearchState {
  final String query;
  final List<SearchSound> sounds;

  const SoundSearchLoaded({
    required this.query,
    required this.sounds,
  });

  @override
  List<Object> get props => [query, sounds];
}

class LocationSearchLoaded extends SearchState {
  final String query;
  final List<SearchLocation> locations;

  const LocationSearchLoaded({
    required this.query,
    required this.locations,
  });

  @override
  List<Object> get props => [query, locations];
}

class PostSearchLoaded extends SearchState {
  final String query;
  final List<SearchPost> posts;

  const PostSearchLoaded({
    required this.query,
    required this.posts,
  });

  @override
  List<Object> get props => [query, posts];
}

class TopResultsLoaded extends SearchState {
  final String query;
  final List<SearchResult> results;

  const TopResultsLoaded({
    required this.query,
    required this.results,
  });

  @override
  List<Object> get props => [query, results];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}