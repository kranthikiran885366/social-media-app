import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/search_bloc.dart';
import '../../data/models/search_models.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  
  bool _isSearchActive = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _searchFocusNode.addListener(_onFocusChange);
    context.read<SearchBloc>().add(LoadRecentSearches());
    context.read<SearchBloc>().add(LoadTrendingSearches());
  }

  void _onFocusChange() {
    setState(() {
      _isSearchActive = _searchFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildSearchAppBar(),
      body: BlocListener<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is UserFollowedFromSearch) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isFollowing ? 'Following user' : 'Unfollowed user',
                ),
                backgroundColor: Colors.black87,
              ),
            );
          }
        },
        child: _isSearchActive ? _buildSearchInterface() : _buildExploreInterface(),
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: isTablet ? 72 : 56,
          title: Container(
            height: isTablet ? 48 : 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: isTablet ? 15 : 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: const Color(0xFF8E8E8E),
                  fontSize: isTablet ? 18 : 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF8E8E8E),
                  size: isTablet ? 24 : 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16, 
                  vertical: isTablet ? 12 : 8,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _currentQuery = query;
                });
                if (query.isNotEmpty) {
                  context.read<SearchBloc>().add(LoadSuggestions(query));
                }
              },
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.read<SearchBloc>().add(SearchQuery(query));
                }
              },
            ),
          ),
          actions: [
            if (_isSearchActive)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                  setState(() {
                    _currentQuery = '';
                    _isSearchActive = false;
                  });
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchInterface() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (_currentQuery.isEmpty) {
          return _buildSearchHome();
        } else if (state is SuggestionsLoaded) {
          return _buildSuggestions(state.suggestions);
        } else if (state is SearchLoaded) {
          return _buildSearchResults(state);
        } else if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildSearchHome();
      },
    );
  }

  Widget _buildSearchHome() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecentSearches(),
              const SizedBox(height: 24),
              _buildTrendingSearches(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is RecentSearchesLoaded && state.recentSearches.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<SearchBloc>().add(ClearSearchHistory());
                    },
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        color: Color(0xFF0095F6),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...state.recentSearches.map((search) => _buildRecentSearchItem(search)),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecentSearchItem(RecentSearch search) {
    return ListTile(
      leading: Icon(_getSearchTypeIcon(search.type)),
      title: Text(search.query),
      subtitle: Text(_formatTimestamp(search.timestamp)),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 20),
        onPressed: () {
          context.read<SearchBloc>().add(RemoveRecentSearch(search.id));
        },
      ),
      onTap: () {
        _searchController.text = search.query;
        context.read<SearchBloc>().add(SearchQuery(search.query));
      },
    );
  }

  Widget _buildTrendingSearches() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is TrendingSearchesLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Discover People',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              ...state.trendingSearches.map((trending) => _buildTrendingSearchItem(trending)),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTrendingSearchItem(TrendingSearch trending) {
    return ListTile(
      leading: Stack(
        children: [
          Icon(_getSearchTypeIcon(trending.type)),
          if (trending.trendingScore > 0.9)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(trending.query),
      subtitle: Text('${_formatCount(trending.searchCount)} searches'),
      trailing: const Icon(Icons.trending_up, color: Colors.red),
      onTap: () {
        _searchController.text = trending.query;
        context.read<SearchBloc>().add(SearchQuery(trending.query));
      },
    );
  }

  Widget _buildSuggestions(List<SearchSuggestion> suggestions) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Icon(_getSearchTypeIcon(suggestion.type)),
          title: Text(suggestion.text),
          trailing: suggestion.isTrending
              ? const Icon(Icons.trending_up, color: Colors.red, size: 16)
              : null,
          onTap: () {
            _searchController.text = suggestion.text;
            context.read<SearchBloc>().add(SearchQuery(suggestion.text));
          },
        );
      },
    );
  }

  Widget _buildSearchResults(SearchLoaded state) {
    return Column(
      children: [
        _buildSearchTabs(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTopResults(state.topResults),
              _buildAccountResults(),
              _buildHashtagResults(),
              _buildSoundResults(),
              _buildLocationResults(),
              _buildPostResults(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFDBDBDB),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.black,
        indicatorWeight: 1,
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFF8E8E8E),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        onTap: (index) {
          switch (index) {
            case 1:
              context.read<SearchBloc>().add(SearchAccounts(_currentQuery));
              break;
            case 2:
              context.read<SearchBloc>().add(SearchHashtags(_currentQuery));
              break;
            case 3:
              context.read<SearchBloc>().add(SearchSounds(_currentQuery));
              break;
            case 4:
              context.read<SearchBloc>().add(SearchLocations(_currentQuery));
              break;
            case 5:
              context.read<SearchBloc>().add(SearchPosts(_currentQuery));
              break;
          }
        },
        tabs: const [
          Tab(text: 'Top'),
          Tab(text: 'Accounts'),
          Tab(text: 'Tags'),
          Tab(text: 'Audio'),
          Tab(text: 'Places'),
          Tab(text: 'Posts'),
        ],
      ),
    );
  }

  Widget _buildTopResults(List<SearchResult> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildSearchResultItem(result);
      },
    );
  }

  Widget _buildAccountResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is AccountSearchLoaded) {
          return ListView.builder(
            itemCount: state.accounts.length,
            itemBuilder: (context, index) {
              final account = state.accounts[index];
              return _buildAccountItem(account);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildHashtagResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is HashtagSearchLoaded) {
          return ListView.builder(
            itemCount: state.hashtags.length,
            itemBuilder: (context, index) {
              final hashtag = state.hashtags[index];
              return _buildHashtagItem(hashtag);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSoundResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SoundSearchLoaded) {
          return ListView.builder(
            itemCount: state.sounds.length,
            itemBuilder: (context, index) {
              final sound = state.sounds[index];
              return _buildSoundItem(sound);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLocationResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is LocationSearchLoaded) {
          return ListView.builder(
            itemCount: state.locations.length,
            itemBuilder: (context, index) {
              final location = state.locations[index];
              return _buildLocationItem(location);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPostResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is PostSearchLoaded) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return _buildPostGridItem(post);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSearchResultItem(SearchResult result) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(result.imageUrl),
      ),
      title: Text(result.title),
      subtitle: Text(result.subtitle),
      trailing: result.isVerified
          ? const Icon(Icons.verified, color: Colors.blue, size: 16)
          : null,
      onTap: () => _handleResultTap(result),
    );
  }

  Widget _buildAccountItem(SearchAccount account) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(account.avatar),
      ),
      title: Row(
        children: [
          Text(account.username, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (account.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(account.fullName),
          Text('${_formatCount(account.followersCount)} followers'),
          if (account.bio != null) Text(account.bio!, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          context.read<SearchBloc>().add(FollowUserFromSearch(
            userId: account.id,
            isCurrentlyFollowing: account.isFollowing,
          ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: account.isFollowing ? const Color(0xFFEFEFEF) : const Color(0xFF0095F6),
          foregroundColor: account.isFollowing ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          minimumSize: const Size(80, 32),
        ),
        child: Text(account.isFollowing ? 'Following' : 'Follow'),
      ),
    );
  }

  Widget _buildHashtagItem(SearchHashtag hashtag) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: hashtag.thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: hashtag.thumbnailUrl!,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.tag, size: 24),
      ),
      title: Row(
        children: [
          Text('#${hashtag.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
          if (hashtag.isTrending) ...[
            const SizedBox(width: 8),
            const Icon(Icons.trending_up, color: Colors.red, size: 16),
          ],
        ],
      ),
      subtitle: Text('${_formatCount(hashtag.postsCount)} posts'),
      onTap: () => _navigateToHashtagPage(hashtag),
    );
  }

  Widget _buildSoundItem(SearchSound sound) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: CachedNetworkImageProvider(sound.coverUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(child: Text(sound.title, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (sound.isTrending) const Icon(Icons.trending_up, color: Colors.red, size: 16),
          if (sound.isOriginal) const Icon(Icons.mic, color: Colors.green, size: 16),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sound.artist),
          Text('${_formatCount(sound.usageCount)} uses • ${sound.duration}s'),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: () => _playSound(sound),
      ),
      onTap: () => _navigateToSoundPage(sound),
    );
  }

  Widget _buildLocationItem(SearchLocation location) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: location.thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: location.thumbnailUrl!,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.location_on, size: 24),
      ),
      title: Text(location.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location.address),
          Text('${_formatCount(location.postsCount)} posts'),
        ],
      ),
      onTap: () => _navigateToLocationPage(location),
    );
  }

  Widget _buildPostGridItem(SearchPost post) {
    return GestureDetector(
      onTap: () => _navigateToPost(post),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: post.thumbnailUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (post.isVideo)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 12),
                const SizedBox(width: 2),
                Text(
                  _formatCount(post.likes),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreInterface() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildExploreGrid(),
        ],
      ),
    );
  }

  Widget _buildExploreGrid() {
    final List<String> mockImages = [
      'https://picsum.photos/400/400?random=1',
      'https://picsum.photos/400/600?random=2',
      'https://picsum.photos/400/400?random=3',
      'https://picsum.photos/400/500?random=4',
      'https://picsum.photos/400/400?random=5',
      'https://picsum.photos/400/700?random=6',
      'https://picsum.photos/400/400?random=7',
      'https://picsum.photos/400/400?random=8',
      'https://picsum.photos/400/600?random=9',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final crossAxisCount = isTablet ? 4 : 3;
        final spacing = isTablet ? 4.0 : 2.0;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          itemCount: mockImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: isTablet ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  child: CachedNetworkImage(
                    imageUrl: mockImages[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFF5F5F5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF8E8E8E),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFF5F5F5),
                      child: const Icon(
                        Icons.error_outline,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleResultTap(SearchResult result) {
    switch (result.type) {
      case SearchResultType.account:
        _navigateToProfile(result.id);
        break;
      case SearchResultType.hashtag:
        _navigateToHashtagPage(SearchHashtag(
          id: result.id,
          name: result.title.replaceFirst('#', ''),
          postsCount: result.postsCount ?? 0,
        ));
        break;
      case SearchResultType.sound:
        _navigateToSoundPage(SearchSound(
          id: result.id,
          title: result.title,
          artist: result.subtitle,
          audioUrl: '',
          coverUrl: result.imageUrl,
          duration: 30,
          usageCount: 0,
        ));
        break;
      case SearchResultType.location:
        _navigateToLocationPage(SearchLocation(
          id: result.id,
          name: result.title,
          address: result.subtitle,
          latitude: 0,
          longitude: 0,
          postsCount: result.postsCount ?? 0,
        ));
        break;
      case SearchResultType.post:
      case SearchResultType.reel:
        break;
    }
  }

  void _navigateToProfile(String userId) {}
  void _navigateToHashtagPage(SearchHashtag hashtag) {}
  void _navigateToSoundPage(SearchSound sound) {}
  void _navigateToLocationPage(SearchLocation location) {}
  void _navigateToPost(SearchPost post) {}
  void _playSound(SearchSound sound) {}

  IconData _getSearchTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.account:
        return Icons.person;
      case SearchResultType.hashtag:
        return Icons.tag;
      case SearchResultType.sound:
        return Icons.music_note;
      case SearchResultType.location:
        return Icons.location_on;
      case SearchResultType.post:
        return Icons.image;
      case SearchResultType.reel:
        return Icons.video_library;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}