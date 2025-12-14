import 'package:flutter/material.dart';
import '../models/explore_models.dart';

class ExploreSearchBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onCameraTap;

  const ExploreSearchBar({
    Key? key,
    required this.onSearchTap,
    required this.onCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Search',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onCameraTap,
          icon: const Icon(Icons.camera_alt_outlined),
        ),
      ],
    );
  }
}

class ExploreSearchPage extends StatefulWidget {
  const ExploreSearchPage({Key? key}) : super(key: key);

  @override
  State<ExploreSearchPage> createState() => _ExploreSearchPageState();
}

class _ExploreSearchPageState extends State<ExploreSearchPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  List<SearchResult> _searchResults = [];
  List<String> _recentSearches = [];
  List<TrendingHashtag> _trendingHashtags = [];
  List<SuggestedAccount> _suggestedAccounts = [];
  List<TrendingSound> _trendingSounds = [];
  List<ShoppableProduct> _products = [];
  
  bool _isSearching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    setState(() {
      _recentSearches = ['#trending', 'user123', 'travel', 'food photography'];
      _trendingHashtags = _generateTrendingHashtags();
      _suggestedAccounts = _generateSuggestedAccounts();
      _trendingSounds = _generateTrendingSounds();
      _products = _generateProducts();
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _query = query;
    });

    // Simulate search with AI-powered results
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _searchResults = _generateSearchResults(query);
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
          onSubmitted: (query) {
            if (query.isNotEmpty && !_recentSearches.contains(query)) {
              setState(() {
                _recentSearches.insert(0, query);
                if (_recentSearches.length > 10) {
                  _recentSearches.removeLast();
                }
              });
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      body: _query.isEmpty ? _buildDiscoveryContent() : _buildSearchResults(),
    );
  }

  Widget _buildDiscoveryContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recent',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final search = _recentSearches[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(search),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() => _recentSearches.removeAt(index));
                    },
                    icon: const Icon(Icons.close, size: 16),
                  ),
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                );
              },
            ),
            const Divider(),
          ],

          // Trending Hashtags
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Trending',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _trendingHashtags.length,
              itemBuilder: (context, index) {
                final hashtag = _trendingHashtags[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(hashtag.hashtag),
                    onPressed: () {
                      _searchController.text = hashtag.hashtag;
                      _performSearch(hashtag.hashtag);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Suggested Accounts
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Suggested for you',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestedAccounts.take(5).length,
            itemBuilder: (context, index) {
              final account = _suggestedAccounts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(account.avatar),
                ),
                title: Text(account.username),
                subtitle: Text(account.fullName),
                trailing: account.isVerified
                    ? const Icon(Icons.verified, color: Colors.blue, size: 16)
                    : null,
                onTap: () {
                  _searchController.text = account.username;
                  _performSearch(account.username);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No results found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Accounts'),
            Tab(text: 'Hashtags'),
            Tab(text: 'Places'),
            Tab(text: 'Audio'),
            Tab(text: 'Shop'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllResults(),
              _buildAccountResults(),
              _buildHashtagResults(),
              _buildLocationResults(),
              _buildAudioResults(),
              _buildShopResults(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultItem(result);
      },
    );
  }

  Widget _buildAccountResults() {
    final accounts = _searchResults.where((r) => r.type == SearchResultType.user).toList();
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final result = accounts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(result.imageUrl ?? ''),
          ),
          title: Text(result.title),
          subtitle: Text(result.subtitle ?? ''),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _onResultTap(result),
        );
      },
    );
  }

  Widget _buildHashtagResults() {
    final hashtags = _searchResults.where((r) => r.type == SearchResultType.hashtag).toList();
    return ListView.builder(
      itemCount: hashtags.length,
      itemBuilder: (context, index) {
        final result = hashtags[index];
        return ListTile(
          leading: const Icon(Icons.tag),
          title: Text(result.title),
          subtitle: Text('${result.count} posts'),
          onTap: () => _onResultTap(result),
        );
      },
    );
  }

  Widget _buildLocationResults() {
    final locations = _searchResults.where((r) => r.type == SearchResultType.location).toList();
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final result = locations[index];
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(result.title),
          subtitle: Text(result.subtitle ?? ''),
          onTap: () => _onResultTap(result),
        );
      },
    );
  }

  Widget _buildAudioResults() {
    final sounds = _searchResults.where((r) => r.type == SearchResultType.sound).toList();
    return ListView.builder(
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final result = sounds[index];
        return ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(result.title),
          subtitle: Text(result.subtitle ?? ''),
          trailing: Text('${result.count} uses'),
          onTap: () => _onResultTap(result),
        );
      },
    );
  }

  Widget _buildShopResults() {
    final products = _searchResults.where((r) => r.type == SearchResultType.product).toList();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final result = products[index];
        return GestureDetector(
          onTap: () => _onResultTap(result),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(result.imageUrl ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                result.subtitle ?? '',
                style: const TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResultItem(SearchResult result) {
    switch (result.type) {
      case SearchResultType.user:
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(result.imageUrl ?? ''),
          ),
          title: Text(result.title),
          subtitle: Text(result.subtitle ?? ''),
          onTap: () => _onResultTap(result),
        );
      case SearchResultType.hashtag:
        return ListTile(
          leading: const Icon(Icons.tag),
          title: Text(result.title),
          subtitle: Text('${result.count} posts'),
          onTap: () => _onResultTap(result),
        );
      case SearchResultType.location:
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(result.title),
          subtitle: Text(result.subtitle ?? ''),
          onTap: () => _onResultTap(result),
        );
      case SearchResultType.sound:
        return ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(result.title),
          subtitle: Text(result.subtitle ?? ''),
          trailing: Text('${result.count} uses'),
          onTap: () => _onResultTap(result),
        );
      case SearchResultType.product:
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(result.imageUrl ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(result.title),
          subtitle: Text(result.subtitle ?? ''),
          onTap: () => _onResultTap(result),
        );
    }
  }

  void _onResultTap(SearchResult result) {
    // Handle result tap based on type
  }

  List<SearchResult> _generateSearchResults(String query) {
    final results = <SearchResult>[];
    
    // Generate mock search results
    for (int i = 0; i < 20; i++) {
      final type = SearchResultType.values[i % SearchResultType.values.length];
      results.add(SearchResult(
        id: 'result_$i',
        type: type,
        title: _getResultTitle(type, query, i),
        subtitle: _getResultSubtitle(type, i),
        imageUrl: type == SearchResultType.user || type == SearchResultType.product
            ? 'https://picsum.photos/100/100?random=$i'
            : null,
        count: type == SearchResultType.hashtag || type == SearchResultType.sound
            ? 1000 + (i * 100)
            : null,
      ));
    }
    
    return results;
  }

  String _getResultTitle(SearchResultType type, String query, int index) {
    switch (type) {
      case SearchResultType.user:
        return '${query}_user_$index';
      case SearchResultType.hashtag:
        return '#$query$index';
      case SearchResultType.location:
        return '$query Location $index';
      case SearchResultType.sound:
        return '$query Sound $index';
      case SearchResultType.product:
        return '$query Product $index';
    }
  }

  String _getResultSubtitle(SearchResultType type, int index) {
    switch (type) {
      case SearchResultType.user:
        return 'Full Name $index';
      case SearchResultType.hashtag:
        return '';
      case SearchResultType.location:
        return 'City, Country';
      case SearchResultType.sound:
        return 'Artist $index';
      case SearchResultType.product:
        return '\$${(index + 1) * 10}.99';
    }
  }

  List<TrendingHashtag> _generateTrendingHashtags() {
    final hashtags = ['#trending', '#viral', '#explore', '#ai', '#tech'];
    return hashtags.map((tag) => TrendingHashtag(
      hashtag: tag,
      postCount: 10000,
      trendingScore: 95,
      category: ExploreCategory.all,
    )).toList();
  }

  List<SuggestedAccount> _generateSuggestedAccounts() {
    return List.generate(10, (index) => SuggestedAccount(
      userId: 'user_$index',
      username: 'suggested_$index',
      fullName: 'Suggested User $index',
      avatar: 'https://picsum.photos/100/100?random=$index',
      bio: 'Content creator',
      reason: SuggestionReason.similarInterests,
      relevanceScore: 0.8,
    ));
  }

  List<TrendingSound> _generateTrendingSounds() {
    return List.generate(5, (index) => TrendingSound(
      id: 'sound_$index',
      title: 'Trending Sound $index',
      artist: 'Artist $index',
      audioUrl: 'audio_url',
      category: ExploreCategory.music,
      duration: 30,
    ));
  }

  List<ShoppableProduct> _generateProducts() {
    return List.generate(10, (index) => ShoppableProduct(
      id: 'product_$index',
      name: 'Product $index',
      brand: 'Brand $index',
      price: 29.99,
      currency: 'USD',
      imageUrl: 'https://picsum.photos/200/200?random=$index',
      productUrl: 'product_url',
      category: ExploreCategory.fashion,
    ));
  }
}