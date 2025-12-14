import 'package:flutter/material.dart';
import '../models/explore_models.dart';
import '../widgets/explore_search_bar.dart';
import '../widgets/category_chips.dart';
import '../widgets/explore_grid_item.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController _scrollController = ScrollController();
  
  ExploreCategory _selectedCategory = ExploreCategory.all;
  List<ExploreContent> _exploreContent = [];
  List<SuggestedAccount> _suggestedAccounts = [];
  List<TrendingHashtag> _trendingHashtags = [];
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadExploreContent();
    _loadTrendingData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreContent();
    }
  }

  Future<void> _loadExploreContent() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newContent = _generateExploreContent(_page);
    
    setState(() {
      if (_page == 1) {
        _exploreContent = newContent;
      } else {
        _exploreContent.addAll(newContent);
      }
      _isLoading = false;
      _hasMore = newContent.isNotEmpty;
    });
  }

  Future<void> _loadTrendingData() async {
    setState(() {
      _suggestedAccounts = _generateSuggestedAccounts();
      _trendingHashtags = _generateTrendingHashtags();
    });
  }

  Future<void> _loadMoreContent() async {
    if (!_hasMore || _isLoading) return;
    
    _page++;
    await _loadExploreContent();
  }

  void _onCategoryChanged(ExploreCategory category) {
    setState(() {
      _selectedCategory = category;
      _page = 1;
    });
    _loadExploreContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: ExploreSearchBar(
              onSearchTap: () {},
              onCameraTap: () {},
            ),
          ),

          SliverToBoxAdapter(
            child: CategoryChips(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          ),

          if (_selectedCategory == ExploreCategory.all) ...[
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _trendingHashtags.length,
                  itemBuilder: (context, index) {
                    final hashtag = _trendingHashtags[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          hashtag.hashtag,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestedAccounts.length,
                  itemBuilder: (context, index) {
                    final account = _suggestedAccounts[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(account.avatar),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            account.username,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          SliverPadding(
            padding: const EdgeInsets.all(2),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _exploreContent.length) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final content = _exploreContent[index];
                  return ExploreGridItem(
                    content: content,
                    onTap: () => _onContentTap(content, index),
                  );
                },
                childCount: _exploreContent.length + (_isLoading ? 6 : 0),
              ),
            ),
          ),

          if (_isLoading && _exploreContent.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  void _onContentTap(ExploreContent content, int index) {
    // Handle content tap
  }

  List<ExploreContent> _generateExploreContent(int page) {
    return List.generate(20, (index) {
      final globalIndex = (page - 1) * 20 + index;
      return ExploreContent(
        id: 'content_$globalIndex',
        type: globalIndex % 4 == 0 ? 'reel' : 'post',
        mediaUrl: 'https://picsum.photos/400/600?random=$globalIndex',
        userId: 'user_${globalIndex % 10}',
        username: 'user${globalIndex % 10}',
        userAvatar: 'https://picsum.photos/100/100?random=${globalIndex % 10}',
        caption: 'Amazing content #trending',
        category: ExploreCategory.values[globalIndex % ExploreCategory.values.length],
        likes: 100 + (globalIndex * 50),
        views: 1000 + (globalIndex * 200),
        aiScore: 6.0 + (globalIndex % 4),
        createdAt: DateTime.now().subtract(Duration(hours: globalIndex)),
      );
    });
  }

  List<SuggestedAccount> _generateSuggestedAccounts() {
    return List.generate(10, (index) => SuggestedAccount(
      userId: 'suggested_$index',
      username: 'user_$index',
      fullName: 'User $index',
      avatar: 'https://picsum.photos/100/100?random=${100 + index}',
      followersCount: 1000 + (index * 500),
      bio: 'Content creator',
      reason: SuggestionReason.values[index % SuggestionReason.values.length],
      relevanceScore: 0.8 + (index * 0.02),
    ));
  }

  List<TrendingHashtag> _generateTrendingHashtags() {
    final hashtags = ['#trending', '#viral', '#explore', '#ai', '#tech'];
    return hashtags.map((tag) => TrendingHashtag(
      hashtag: tag,
      postCount: 10000 + (hashtags.indexOf(tag) * 5000),
      trendingScore: 90 + hashtags.indexOf(tag),
      category: ExploreCategory.values[hashtags.indexOf(tag) % ExploreCategory.values.length],
    )).toList();
  }
}