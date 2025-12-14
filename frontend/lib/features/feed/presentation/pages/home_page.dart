import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/feed_bloc.dart';
// import '../widgets/post_card.dart';
import '../widgets/enhanced_post_card.dart';
import '../widgets/suggested_users_widget.dart';
import '../widgets/sponsored_post_card.dart';
// import '../widgets/time_limit_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    context.read<FeedBloc>().add(LoadFeed());
  }

  void _initializeAnimations() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      _onScroll();
      if (_scrollController.offset > 200 && !_showFab) {
        setState(() => _showFab = true);
        _fabController.forward();
      } else if (_scrollController.offset <= 200 && _showFab) {
        setState(() => _showFab = false);
        _fabController.reverse();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<FeedBloc>().add(LoadMorePosts());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStoriesSection(),
          Expanded(
            child: BlocBuilder<FeedBloc, FeedState>(
              builder: (context, state) {
                if (state is FeedLoading) {
                  return _buildLoadingState();
                } else if (state is FeedLoaded || state is FeedLoadingMore) {
                  final posts = state is FeedLoaded 
                      ? state.posts 
                      : (state as FeedLoadingMore).posts;
                  
                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.background,
                    onRefresh: () async {
                      context.read<FeedBloc>().add(RefreshFeed());
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: posts.length + (state is FeedLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= posts.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }
                        final post = posts[index];
                        
                        if (index > 0 && index % 5 == 0) {
                          return Column(
                            children: [
                              const SuggestedUsersWidget(),
                              _buildPostCard(post),
                            ],
                          );
                        }
                        
                        return _buildPostCard(post);
                      },
                    ),
                  );
                }
                return _buildErrorState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildScrollToTopFab(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: LayoutBuilder(
        builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          toolbarHeight: isTablet ? 80 : 56,
          title: ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: Text(
              'Smart Social',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 32 : 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: isTablet ? 12 : 8),
              child: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  child: Icon(
                    Icons.favorite_outline,
                    color: AppColors.primary,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                onPressed: () {},
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: isTablet ? 24 : 16),
              child: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  child: Icon(
                    Icons.send_outlined,
                    color: AppColors.secondary,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStoriesSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return Container(
          height: isTablet ? 120 : 100,
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: 0.5,
              ),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16, 
              vertical: isTablet ? 12 : 8,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: isTablet ? 16 : 12),
                child: Column(
                  children: [
                    Container(
                      width: isTablet ? 80 : 60,
                      height: isTablet ? 80 : 60,
                      decoration: BoxDecoration(
                        gradient: index == 0 ? null : AppColors.storyGradient,
                        shape: BoxShape.circle,
                        border: index == 0 ? Border.all(
                          color: AppColors.border,
                          width: 2,
                        ) : null,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                        ),
                        child: index == 0
                            ? Icon(
                                Icons.add,
                                color: AppColors.primary,
                                size: isTablet ? 32 : 24,
                              )
                            : ClipOval(
                                child: Image.network(
                                  'https://picsum.photos/100/100?random=$index',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                      Icon(
                                        Icons.person, 
                                        color: AppColors.textTertiary,
                                        size: isTablet ? 32 : 24,
                                      ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      index == 0 ? 'Your story' : 'User $index',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your feed...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<FeedBloc>().add(LoadFeed());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToTopFab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = MediaQuery.of(context).size.width > 600;
        return AnimatedBuilder(
          animation: _fabAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabAnimation.value,
              child: Opacity(
                opacity: _fabAnimation.value,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: _scrollToTop,
                  mini: !isTablet,
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: isTablet ? 32 : 24,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _scrollToTop() {
    HapticFeedback.mediumImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPostCard(dynamic post) {
    if (post.isSponsored ?? false) {
      return SponsoredPostCard(post: post);
    }
    return EnhancedPostCard(post: post);
  }
}