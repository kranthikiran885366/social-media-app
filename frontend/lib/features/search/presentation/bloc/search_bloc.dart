import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/search_models.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchQuery>(_onSearchQuery);
    on<LoadSuggestions>(_onLoadSuggestions);
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<LoadTrendingSearches>(_onLoadTrendingSearches);
    on<ClearSearchHistory>(_onClearSearchHistory);
    on<RemoveRecentSearch>(_onRemoveRecentSearch);
    on<FollowUserFromSearch>(_onFollowUserFromSearch);
    on<SearchAccounts>(_onSearchAccounts);
    on<SearchHashtags>(_onSearchHashtags);
    on<SearchSounds>(_onSearchSounds);
    on<SearchLocations>(_onSearchLocations);
    on<SearchPosts>(_onSearchPosts);
    on<GetTopResults>(_onGetTopResults);
  }

  void _onSearchQuery(SearchQuery event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final results = _generateSearchResults(event.query);
    _saveRecentSearch(event.query, SearchResultType.account);
    
    emit(SearchLoaded(
      query: event.query,
      results: results,
      topResults: results.take(5).toList(),
    ));
  }

  void _onLoadSuggestions(LoadSuggestions event, Emitter<SearchState> emit) async {
    emit(SuggestionsLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    
    final suggestions = _generateSuggestions(event.query);
    emit(SuggestionsLoaded(suggestions: suggestions));
  }

  void _onLoadRecentSearches(LoadRecentSearches event, Emitter<SearchState> emit) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final recentSearches = _getRecentSearches();
    emit(RecentSearchesLoaded(recentSearches: recentSearches));
  }

  void _onLoadTrendingSearches(LoadTrendingSearches event, Emitter<SearchState> emit) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final trendingSearches = _getTrendingSearches();
    emit(TrendingSearchesLoaded(trendingSearches: trendingSearches));
  }

  void _onClearSearchHistory(ClearSearchHistory event, Emitter<SearchState> emit) async {
    // Clear search history logic
    emit(SearchHistoryCleared());
  }

  void _onRemoveRecentSearch(RemoveRecentSearch event, Emitter<SearchState> emit) async {
    // Remove specific recent search
    final updatedRecentSearches = _getRecentSearches()
        .where((search) => search.id != event.searchId)
        .toList();
    emit(RecentSearchesLoaded(recentSearches: updatedRecentSearches));
  }

  void _onFollowUserFromSearch(FollowUserFromSearch event, Emitter<SearchState> emit) async {
    emit(UserFollowedFromSearch(userId: event.userId, isFollowing: !event.isCurrentlyFollowing));
  }

  void _onSearchAccounts(SearchAccounts event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    
    final accounts = _generateAccountResults(event.query);
    emit(AccountSearchLoaded(query: event.query, accounts: accounts));
  }

  void _onSearchHashtags(SearchHashtags event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    
    final hashtags = _generateHashtagResults(event.query);
    emit(HashtagSearchLoaded(query: event.query, hashtags: hashtags));
  }

  void _onSearchSounds(SearchSounds event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    
    final sounds = _generateSoundResults(event.query);
    emit(SoundSearchLoaded(query: event.query, sounds: sounds));
  }

  void _onSearchLocations(SearchLocations event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    
    final locations = _generateLocationResults(event.query);
    emit(LocationSearchLoaded(query: event.query, locations: locations));
  }

  void _onSearchPosts(SearchPosts event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    
    final posts = _generatePostResults(event.query);
    emit(PostSearchLoaded(query: event.query, posts: posts));
  }

  void _onGetTopResults(GetTopResults event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    
    final topResults = _generateTopResults(event.query);
    emit(TopResultsLoaded(query: event.query, results: topResults));
  }

  List<SearchResult> _generateSearchResults(String query) {
    return [
      SearchResult(
        id: 'user_1',
        type: SearchResultType.account,
        title: 'john_doe',
        subtitle: 'John Doe • 1.2M followers',
        imageUrl: 'https://example.com/avatar1.jpg',
        followersCount: 1200000,
        isVerified: true,
        relevanceScore: 0.95,
      ),
      SearchResult(
        id: 'hashtag_1',
        type: SearchResultType.hashtag,
        title: '#${query.toLowerCase()}',
        subtitle: '2.5M posts',
        imageUrl: 'https://example.com/hashtag1.jpg',
        postsCount: 2500000,
        relevanceScore: 0.88,
      ),
      SearchResult(
        id: 'sound_1',
        type: SearchResultType.sound,
        title: 'Trending Beat',
        subtitle: 'Artist Name • 500K uses',
        imageUrl: 'https://example.com/sound1.jpg',
        relevanceScore: 0.82,
      ),
      SearchResult(
        id: 'location_1',
        type: SearchResultType.location,
        title: 'New York, NY',
        subtitle: '1.8M posts',
        imageUrl: 'https://example.com/location1.jpg',
        postsCount: 1800000,
        relevanceScore: 0.75,
      ),
    ];
  }

  List<SearchSuggestion> _generateSuggestions(String query) {
    return [
      SearchSuggestion(
        id: 'suggestion_1',
        text: '${query}ing',
        type: SearchResultType.account,
        isTrending: true,
      ),
      SearchSuggestion(
        id: 'suggestion_2',
        text: '#$query',
        type: SearchResultType.hashtag,
      ),
      SearchSuggestion(
        id: 'suggestion_3',
        text: '$query music',
        type: SearchResultType.sound,
      ),
    ];
  }

  List<RecentSearch> _getRecentSearches() {
    return [
      RecentSearch(
        id: 'recent_1',
        query: 'productivity',
        type: SearchResultType.hashtag,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      RecentSearch(
        id: 'recent_2',
        query: 'jane_smith',
        type: SearchResultType.account,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RecentSearch(
        id: 'recent_3',
        query: 'trending music',
        type: SearchResultType.sound,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<TrendingSearch> _getTrendingSearches() {
    return [
      TrendingSearch(
        id: 'trending_1',
        query: '#viral',
        type: SearchResultType.hashtag,
        searchCount: 1500000,
        trendingScore: 0.95,
        description: 'Trending worldwide',
      ),
      TrendingSearch(
        id: 'trending_2',
        query: 'tech_guru',
        type: SearchResultType.account,
        searchCount: 800000,
        trendingScore: 0.88,
      ),
      TrendingSearch(
        id: 'trending_3',
        query: 'summer vibes',
        type: SearchResultType.sound,
        searchCount: 600000,
        trendingScore: 0.82,
      ),
    ];
  }

  List<SearchAccount> _generateAccountResults(String query) {
    return [
      SearchAccount(
        id: 'account_1',
        username: 'john_doe',
        fullName: 'John Doe',
        avatar: 'https://example.com/avatar1.jpg',
        isVerified: true,
        followersCount: 1200000,
        postsCount: 450,
        bio: 'Content creator & entrepreneur',
        category: 'Public Figure',
      ),
      SearchAccount(
        id: 'account_2',
        username: 'jane_smith',
        fullName: 'Jane Smith',
        avatar: 'https://example.com/avatar2.jpg',
        followersCount: 850000,
        postsCount: 320,
        bio: 'Designer & artist',
      ),
    ];
  }

  List<SearchHashtag> _generateHashtagResults(String query) {
    return [
      SearchHashtag(
        id: 'hashtag_1',
        name: query.toLowerCase(),
        postsCount: 2500000,
        isTrending: true,
        description: 'Popular hashtag about $query',
        thumbnailUrl: 'https://example.com/hashtag1.jpg',
        relatedHashtags: ['${query}tips', '${query}life', '${query}goals'],
      ),
      SearchHashtag(
        id: 'hashtag_2',
        name: '${query}tips',
        postsCount: 1200000,
        thumbnailUrl: 'https://example.com/hashtag2.jpg',
      ),
    ];
  }

  List<SearchSound> _generateSoundResults(String query) {
    return [
      SearchSound(
        id: 'sound_1',
        title: 'Trending Beat',
        artist: 'Artist Name',
        audioUrl: 'https://example.com/audio1.mp3',
        coverUrl: 'https://example.com/cover1.jpg',
        duration: 30,
        usageCount: 500000,
        isTrending: true,
      ),
      SearchSound(
        id: 'sound_2',
        title: 'Original Audio',
        artist: 'Creator Name',
        audioUrl: 'https://example.com/audio2.mp3',
        coverUrl: 'https://example.com/cover2.jpg',
        duration: 25,
        usageCount: 250000,
        isOriginal: true,
      ),
    ];
  }

  List<SearchLocation> _generateLocationResults(String query) {
    return [
      SearchLocation(
        id: 'location_1',
        name: 'New York, NY',
        address: 'New York, United States',
        latitude: 40.7128,
        longitude: -74.0060,
        postsCount: 1800000,
        category: 'City',
        thumbnailUrl: 'https://example.com/location1.jpg',
      ),
      SearchLocation(
        id: 'location_2',
        name: 'Central Park',
        address: 'New York, NY, United States',
        latitude: 40.7829,
        longitude: -73.9654,
        postsCount: 950000,
        category: 'Park',
        thumbnailUrl: 'https://example.com/location2.jpg',
      ),
    ];
  }

  List<SearchPost> _generatePostResults(String query) {
    return [
      SearchPost(
        id: 'post_1',
        userId: 'user_1',
        username: 'john_doe',
        userAvatar: 'https://example.com/avatar1.jpg',
        thumbnailUrl: 'https://example.com/post1.jpg',
        caption: 'Amazing $query content! 🚀',
        likes: 15000,
        comments: 250,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      SearchPost(
        id: 'post_2',
        userId: 'user_2',
        username: 'jane_smith',
        userAvatar: 'https://example.com/avatar2.jpg',
        thumbnailUrl: 'https://example.com/post2.jpg',
        caption: 'Check out this $query tip!',
        likes: 8500,
        comments: 120,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isVideo: true,
      ),
    ];
  }

  List<SearchResult> _generateTopResults(String query) {
    final allResults = _generateSearchResults(query);
    return allResults
        .where((result) => result.relevanceScore > 0.8)
        .take(3)
        .toList();
  }

  void _saveRecentSearch(String query, SearchResultType type) {
    // Save to local storage or database
  }
}