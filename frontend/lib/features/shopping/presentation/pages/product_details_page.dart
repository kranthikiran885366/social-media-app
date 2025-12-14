import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/shopping_models.dart';
import '../bloc/shopping_bloc.dart';
import '../bloc/shopping_event.dart';
import '../bloc/shopping_state.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_actions.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShoppingBloc>().add(LoadProductDetails(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return BlocConsumer<ShoppingBloc, ShoppingState>(
            listener: (context, state) {
              if (state is ProductAddedToCart) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.product.name} added to cart'),
                    backgroundColor: AppColors.success,
                    action: SnackBarAction(
                      label: 'View Cart',
                      textColor: Colors.white,
                      onPressed: () => Navigator.pushNamed(context, '/shop/cart'),
                    ),
                  ),
                );
              } else if (state is CheckoutInitiated) {
                Navigator.pushNamed(context, '/shop/checkout');
              }
            },
            builder: (context, state) {
              if (state is ShoppingLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                );
              }

              if (state is ProductDetailsLoaded) {
                return _buildProductDetails(context, state.product, state.relatedProducts, isTablet);
              }

              if (state is ShoppingError) {
                return _buildErrorState(state.message, isTablet);
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? 100 : 80,
              height: isTablet ? 100 : 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: isTablet ? 50 : 40,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Container(
              height: isTablet ? 56 : 48,
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
              child: ElevatedButton(
                onPressed: () {
                  context.read<ShoppingBloc>().add(LoadProductDetails(widget.productId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, Product product, List<Product> relatedProducts, bool isTablet) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          expandedHeight: isTablet ? 500 : 400,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: ProductImageCarousel(images: product.images),
          ),
          leading: Container(
            margin: EdgeInsets.only(
              left: isTablet ? 24 : 16,
              top: isTablet ? 12 : 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: isTablet ? 28 : 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(
                right: isTablet ? 12 : 8,
                top: isTablet ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: AppColors.error,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: () {
                  context.read<ShoppingBloc>().add(AddToWishlist(product));
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: isTablet ? 24 : 16,
                top: isTablet ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.share,
                  color: AppColors.textPrimary,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.all(isTablet ? 24 : 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: isTablet ? 20 : 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 12,
                          vertical: isTablet ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.successGradient,
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                        ),
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        SizedBox(width: isTablet ? 12 : 8),
                        Text(
                          '\$${product.originalPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: isTablet ? 24 : 20,
                        ),
                        SizedBox(width: isTablet ? 8 : 4),
                        Text(
                          '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/shop/seller',
                        arguments: product.sellerId,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isTablet ? 56 : 48,
                            height: isTablet ? 56 : 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: isTablet ? 24 : 20,
                              backgroundImage: product.sellerAvatar != null
                                  ? NetworkImage(product.sellerAvatar!)
                                  : null,
                              child: product.sellerAvatar == null
                                  ? Icon(
                                      Icons.store,
                                      color: AppColors.primary,
                                      size: isTablet ? 28 : 24,
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.sellerName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isTablet ? 18 : 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: isTablet ? 4 : 2),
                                Text(
                                  'View Store',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: isTablet ? 15 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(isTablet ? 8 : 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: AppColors.primary,
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      product.description,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        height: 1.6,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  if (product.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Wrap(
                      spacing: isTablet ? 12 : 8,
                      runSpacing: isTablet ? 12 : 8,
                      children: product.tags.map((tag) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 12,
                          vertical: isTablet ? 10 : 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient.scale(0.3),
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      )).toList(),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                  ],
                  if (relatedProducts.isNotEmpty) ...[
                    Text(
                      'Related Products',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    SizedBox(
                      height: isTablet ? 280 : 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) {
                          final relatedProduct = relatedProducts[index];
                          return Container(
                            width: isTablet ? 200 : 160,
                            margin: EdgeInsets.only(right: isTablet ? 20 : 16),
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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsPage(
                                      productId: relatedProduct.id,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(isTablet ? 20 : 16),
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(relatedProduct.images.first),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            relatedProduct.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: isTablet ? 14 : 12,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: isTablet ? 8 : 4),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isTablet ? 8 : 6,
                                              vertical: isTablet ? 4 : 2,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: AppColors.successGradient,
                                              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                                            ),
                                            child: Text(
                                              '\$${relatedProduct.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                fontSize: isTablet ? 14 : 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: isTablet ? 120 : 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductImageCarousel extends StatefulWidget {
  final List<String> images;

  const ProductImageCarousel({super.key, required this.images});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.backgroundSecondary,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentIndex == entry.key ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}