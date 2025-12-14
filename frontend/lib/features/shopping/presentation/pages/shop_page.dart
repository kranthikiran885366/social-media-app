import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              _buildAppBar(isTablet),
              SliverToBoxAdapter(child: _buildSearchBar(isTablet)),
              SliverToBoxAdapter(child: _buildTabBar(isTablet)),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFeaturedTab(isTablet),
                    _buildCategoriesTab(isTablet),
                    _buildBrandsTab(isTablet),
                    _buildDealsTab(isTablet),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      floating: true,
      snap: true,
      expandedHeight: isTablet ? 120 : 100,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient.scale(0.1),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Shop',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        centerTitle: false,
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(
            right: isTablet ? 24 : 16,
            top: isTablet ? 12 : 8,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: isTablet ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: isTablet ? 15 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: isTablet ? 18 : 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: isTablet ? 28 : 24,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 20,
            vertical: isTablet ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(text: 'Featured'),
          Tab(text: 'Categories'),
          Tab(text: 'Brands'),
          Tab(text: 'Deals'),
        ],
      ),
    );
  }

  Widget _buildFeaturedTab(bool isTablet) {
    return ListView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      children: [
        _buildFeaturedBanner(isTablet),
        SizedBox(height: isTablet ? 32 : 24),
        _buildSectionTitle('Trending Products', isTablet),
        SizedBox(height: isTablet ? 20 : 16),
        _buildProductGrid(isTablet),
      ],
    );
  }

  Widget _buildFeaturedBanner(bool isTablet) {
    return Container(
      height: isTablet ? 220 : 180,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: isTablet ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '50% OFF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summer Collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Discover amazing deals',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 8 : 6,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
          child: Text(
            'See All',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 14 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: isTablet ? 20 : 16,
        mainAxisSpacing: isTablet ? 20 : 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildProductCard(index, isTablet),
    );
  }

  Widget _buildProductCard(int index, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: isTablet ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product ${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(index + 1) * 25}.99',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(bool isTablet) {
    return GridView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: isTablet ? 20 : 16,
        mainAxisSpacing: isTablet ? 20 : 16,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => _buildCategoryCard(index, isTablet),
    );
  }

  Widget _buildCategoryCard(int index, bool isTablet) {
    final categories = ['Fashion', 'Electronics', 'Home', 'Beauty', 'Sports', 'Books', 'Toys', 'Food'];
    final colors = [AppColors.primary, AppColors.secondary, AppColors.info, AppColors.success];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors[index % colors.length], colors[index % colors.length].withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Center(
            child: Text(
              categories[index],
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandsTab(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: 10,
      itemBuilder: (context, index) => _buildBrandCard(index, isTablet),
    );
  }

  Widget _buildBrandCard(int index, bool isTablet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.store, color: AppColors.textTertiary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brand ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${(index + 1) * 50} products',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildDealsTab(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildDealCard(index, isTablet),
    );
  }

  Widget _buildDealCard(int index, bool isTablet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(index + 1) * 10}% OFF',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flash Deal ${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Limited time offer',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}