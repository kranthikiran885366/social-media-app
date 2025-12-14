import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/shopping_models.dart';
import 'shopping_event.dart';
import 'shopping_state.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  List<Product> _allProducts = [];
  List<CartItem> _cartItems = [];
  List<Product> _wishlistProducts = [];
  List<Product> _recentlyViewed = [];
  List<Order> _orders = [];

  ShoppingBloc() : super(ShoppingInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<LoadCart>(_onLoadCart);
    on<ClearCart>(_onClearCart);
    on<AddToWishlist>(_onAddToWishlist);
    on<RemoveFromWishlist>(_onRemoveFromWishlist);
    on<LoadWishlist>(_onLoadWishlist);
    on<BuyNow>(_onBuyNow);
    on<Checkout>(_onCheckout);
    on<LoadOrders>(_onLoadOrders);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<TrackOrder>(_onTrackOrder);
    on<LoadShopCollections>(_onLoadShopCollections);
    on<LoadSellerProfile>(_onLoadSellerProfile);
    on<LoadRecommendedProducts>(_onLoadRecommendedProducts);
    on<LoadRecentlyViewedProducts>(_onLoadRecentlyViewedProducts);
    on<AddRecentlyViewed>(_onAddRecentlyViewed);
    on<LoadSponsoredProducts>(_onLoadSponsoredProducts);
    on<TagProductInPost>(_onTagProductInPost);
    on<TagProductInReel>(_onTagProductInReel);
    on<TagProductInStory>(_onTagProductInStory);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ShoppingState> emit) async {
    try {
      if (event.page == 1) emit(ShoppingLoading());

      await Future.delayed(const Duration(milliseconds: 500));
      
      final products = _generateMockProducts(event.page, event.limit, event.category);
      
      if (event.page == 1) {
        _allProducts = products;
      } else {
        _allProducts.addAll(products);
      }

      emit(ProductsLoaded(
        products: List.from(_allProducts),
        hasReachedMax: products.length < event.limit,
        category: event.category,
      ));
    } catch (e) {
      emit(ShoppingError('Failed to load products: ${e.toString()}'));
    }
  }

  Future<void> _onSearchProducts(SearchProducts event, Emitter<ShoppingState> emit) async {
    try {
      emit(ShoppingLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      final filteredProducts = _allProducts.where((product) =>
        product.name.toLowerCase().contains(event.query.toLowerCase()) ||
        product.description.toLowerCase().contains(event.query.toLowerCase()) ||
        product.tags.any((tag) => tag.toLowerCase().contains(event.query.toLowerCase()))
      ).toList();

      emit(ProductsLoaded(products: filteredProducts));
    } catch (e) {
      emit(ShoppingError('Failed to search products'));
    }
  }

  Future<void> _onLoadProductDetails(LoadProductDetails event, Emitter<ShoppingState> emit) async {
    try {
      emit(ShoppingLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      final product = _allProducts.firstWhere((p) => p.id == event.productId);
      final relatedProducts = _allProducts.where((p) => 
        p.category == product.category && p.id != product.id
      ).take(5).toList();

      add(AddRecentlyViewed(product));
      
      emit(ProductDetailsLoaded(product, relatedProducts: relatedProducts));
    } catch (e) {
      emit(ShoppingError('Product not found'));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<ShoppingState> emit) async {
    try {
      final existingIndex = _cartItems.indexWhere((item) => 
        item.product.id == event.product.id &&
        _variantsMatch(item.selectedVariants, event.variants)
      );

      if (existingIndex != -1) {
        _cartItems[existingIndex] = CartItem(
          id: _cartItems[existingIndex].id,
          product: _cartItems[existingIndex].product,
          quantity: _cartItems[existingIndex].quantity + event.quantity,
          selectedVariants: _cartItems[existingIndex].selectedVariants,
          addedAt: _cartItems[existingIndex].addedAt,
        );
      } else {
        _cartItems.add(CartItem(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          product: event.product,
          quantity: event.quantity,
          selectedVariants: event.variants,
          addedAt: DateTime.now(),
        ));
      }

      emit(ProductAddedToCart(event.product, _cartItems.length));
    } catch (e) {
      emit(ShoppingError('Failed to add product to cart'));
    }
  }

  Future<void> _onRemoveFromCart(RemoveFromCart event, Emitter<ShoppingState> emit) async {
    try {
      final removedItem = _cartItems.firstWhere((item) => item.id == event.cartItemId);
      _cartItems.removeWhere((item) => item.id == event.cartItemId);
      
      emit(ProductRemovedFromCart(removedItem.product.id, _cartItems.length));
    } catch (e) {
      emit(ShoppingError('Failed to remove product from cart'));
    }
  }

  Future<void> _onUpdateCartQuantity(UpdateCartQuantity event, Emitter<ShoppingState> emit) async {
    try {
      final index = _cartItems.indexWhere((item) => item.id == event.cartItemId);
      if (index != -1) {
        if (event.quantity <= 0) {
          add(RemoveFromCart(event.cartItemId));
          return;
        }
        
        _cartItems[index] = CartItem(
          id: _cartItems[index].id,
          product: _cartItems[index].product,
          quantity: event.quantity,
          selectedVariants: _cartItems[index].selectedVariants,
          addedAt: _cartItems[index].addedAt,
        );
        
        add(LoadCart());
      }
    } catch (e) {
      emit(ShoppingError('Failed to update cart quantity'));
    }
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<ShoppingState> emit) async {
    try {
      final subtotal = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      final tax = subtotal * 0.08;
      final shipping = subtotal > 50 ? 0.0 : 9.99;
      final total = subtotal + tax + shipping;

      emit(CartLoaded(
        items: List.from(_cartItems),
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: total,
      ));
    } catch (e) {
      emit(ShoppingError('Failed to load cart'));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<ShoppingState> emit) async {
    _cartItems.clear();
    add(LoadCart());
  }

  Future<void> _onAddToWishlist(AddToWishlist event, Emitter<ShoppingState> emit) async {
    try {
      if (!_wishlistProducts.any((p) => p.id == event.product.id)) {
        _wishlistProducts.add(event.product);
        emit(ProductAddedToWishlist(event.product));
      }
    } catch (e) {
      emit(ShoppingError('Failed to add to wishlist'));
    }
  }

  Future<void> _onRemoveFromWishlist(RemoveFromWishlist event, Emitter<ShoppingState> emit) async {
    try {
      _wishlistProducts.removeWhere((p) => p.id == event.productId);
      emit(ProductRemovedFromWishlist(event.productId));
    } catch (e) {
      emit(ShoppingError('Failed to remove from wishlist'));
    }
  }

  Future<void> _onLoadWishlist(LoadWishlist event, Emitter<ShoppingState> emit) async {
    emit(WishlistLoaded(List.from(_wishlistProducts)));
  }

  Future<void> _onBuyNow(BuyNow event, Emitter<ShoppingState> emit) async {
    try {
      final cartItem = CartItem(
        id: 'buynow_${DateTime.now().millisecondsSinceEpoch}',
        product: event.product,
        quantity: event.quantity,
        selectedVariants: event.variants,
        addedAt: DateTime.now(),
      );

      final subtotal = cartItem.totalPrice;
      final tax = subtotal * 0.08;
      final shipping = subtotal > 50 ? 0.0 : 9.99;
      final total = subtotal + tax + shipping;

      emit(CheckoutInitiated([cartItem], total));
    } catch (e) {
      emit(ShoppingError('Failed to initiate buy now'));
    }
  }

  Future<void> _onCheckout(Checkout event, Emitter<ShoppingState> emit) async {
    try {
      emit(ShoppingLoading());
      await Future.delayed(const Duration(seconds: 2));

      final order = Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user_id',
        items: List.from(_cartItems),
        subtotal: _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice),
        tax: _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice) * 0.08,
        shipping: _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice) > 50 ? 0.0 : 9.99,
        total: _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice) * 1.08 + 
               (_cartItems.fold(0.0, (sum, item) => sum + item.totalPrice) > 50 ? 0.0 : 9.99),
        status: OrderStatus.pending,
        shippingAddress: event.shippingAddress,
        paymentMethod: event.paymentMethod,
        createdAt: DateTime.now(),
        trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch}',
      );

      _orders.add(order);
      _cartItems.clear();

      emit(OrderPlaced(order));
    } catch (e) {
      emit(ShoppingError('Failed to place order'));
    }
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<ShoppingState> emit) async {
    try {
      emit(ShoppingLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(OrdersLoaded(List.from(_orders)));
    } catch (e) {
      emit(ShoppingError('Failed to load orders'));
    }
  }

  Future<void> _onLoadOrderDetails(LoadOrderDetails event, Emitter<ShoppingState> emit) async {
    try {
      emit(ShoppingLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      final order = _orders.firstWhere((o) => o.id == event.orderId);
      emit(OrderDetailsLoaded(order));
    } catch (e) {
      emit(ShoppingError('Order not found'));
    }
  }

  Future<void> _onTrackOrder(TrackOrder event, Emitter<ShoppingState> emit) async {
    try {
      emit(ShoppingLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      
      final order = _orders.firstWhere((o) => o.id == event.orderId);
      final trackingInfo = _generateTrackingInfo();
      
      emit(OrderDetailsLoaded(order, trackingInfo: trackingInfo));
    } catch (e) {
      emit(ShoppingError('Failed to track order'));
    }
  }

  Future<void> _onLoadShopCollections(LoadShopCollections event, Emitter<ShoppingState> emit) async {
    try {
      emit(ShoppingLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      final collections = _generateMockCollections(event.sellerId);
      emit(ShopCollectionsLoaded(collections));
    } catch (e) {
      emit(ShoppingError('Failed to load collections'));
    }
  }

  Future<void> _onLoadSellerProfile(LoadSellerProfile event, Emitter<ShoppingState> emit) async {
    try {
      emit(ShoppingLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      
      final seller = _generateMockSeller(event.sellerId);
      final products = _allProducts.where((p) => p.sellerId == event.sellerId).toList();
      final collections = _generateMockCollections(event.sellerId);
      
      emit(SellerProfileLoaded(
        seller: seller,
        products: products,
        collections: collections,
      ));
    } catch (e) {
      emit(ShoppingError('Failed to load seller profile'));
    }
  }

  Future<void> _onLoadRecommendedProducts(LoadRecommendedProducts event, Emitter<ShoppingState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final recommended = _allProducts.take(10).toList();
      emit(RecommendedProductsLoaded(recommended));
    } catch (e) {
      emit(ShoppingError('Failed to load recommended products'));
    }
  }

  Future<void> _onLoadRecentlyViewedProducts(LoadRecentlyViewedProducts event, Emitter<ShoppingState> emit) async {
    emit(RecentlyViewedLoaded(List.from(_recentlyViewed)));
  }

  Future<void> _onAddRecentlyViewed(AddRecentlyViewed event, Emitter<ShoppingState> emit) async {
    _recentlyViewed.removeWhere((p) => p.id == event.product.id);
    _recentlyViewed.insert(0, event.product);
    if (_recentlyViewed.length > 20) {
      _recentlyViewed = _recentlyViewed.take(20).toList();
    }
  }

  Future<void> _onLoadSponsoredProducts(LoadSponsoredProducts event, Emitter<ShoppingState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final sponsored = _allProducts.where((p) => p.id.contains('sponsored')).toList();
      emit(SponsoredProductsLoaded(sponsored));
    } catch (e) {
      emit(ShoppingError('Failed to load sponsored products'));
    }
  }

  Future<void> _onTagProductInPost(TagProductInPost event, Emitter<ShoppingState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(ProductTagged(event.postId, 'post', event.productTags));
    } catch (e) {
      emit(ShoppingError('Failed to tag products in post'));
    }
  }

  Future<void> _onTagProductInReel(TagProductInReel event, Emitter<ShoppingState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(ProductTagged(event.reelId, 'reel', event.productTags));
    } catch (e) {
      emit(ShoppingError('Failed to tag products in reel'));
    }
  }

  Future<void> _onTagProductInStory(TagProductInStory event, Emitter<ShoppingState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(ProductTagged(event.storyId, 'story', event.productTags));
    } catch (e) {
      emit(ShoppingError('Failed to tag products in story'));
    }
  }

  bool _variantsMatch(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.toString() == b.toString();
  }

  List<Product> _generateMockProducts(int page, int limit, String? category) {
    final products = <Product>[];
    final categories = ['Fashion', 'Electronics', 'Home', 'Beauty', 'Sports'];
    
    for (int i = 0; i < limit; i++) {
      final index = (page - 1) * limit + i;
      final productCategory = category ?? categories[index % categories.length];
      
      products.add(Product(
        id: 'product_$index',
        name: 'Product $index',
        description: 'High-quality $productCategory product with amazing features',
        price: 29.99 + (index * 10),
        originalPrice: index % 3 == 0 ? 39.99 + (index * 10) : null,
        currency: 'USD',
        images: [
          'https://picsum.photos/400/400?random=$index',
          'https://picsum.photos/400/400?random=${index + 100}',
        ],
        sellerId: 'seller_${index % 5}',
        sellerName: 'Seller ${index % 5}',
        sellerAvatar: 'https://picsum.photos/100/100?random=${index % 5}',
        category: productCategory,
        tags: ['tag1', 'tag2', productCategory.toLowerCase()],
        stockQuantity: 50 + index,
        rating: 4.0 + (index % 10) / 10,
        reviewCount: 10 + index,
        createdAt: DateTime.now().subtract(Duration(days: index)),
      ));
    }
    
    return products;
  }

  List<ShopCollection> _generateMockCollections(String? sellerId) {
    return [
      ShopCollection(
        id: 'collection_1',
        name: 'Summer Collection',
        description: 'Hot summer trends',
        coverImage: 'https://picsum.photos/300/200?random=1',
        products: _allProducts.take(5).toList(),
        sellerId: sellerId ?? 'seller_1',
        createdAt: DateTime.now(),
      ),
      ShopCollection(
        id: 'collection_2',
        name: 'Best Sellers',
        description: 'Our most popular items',
        coverImage: 'https://picsum.photos/300/200?random=2',
        products: _allProducts.skip(5).take(5).toList(),
        sellerId: sellerId ?? 'seller_1',
        createdAt: DateTime.now(),
      ),
    ];
  }

  Seller _generateMockSeller(String sellerId) {
    return Seller(
      id: sellerId,
      name: 'Amazing Store',
      avatar: 'https://picsum.photos/100/100?random=seller',
      bio: 'We sell the best products with excellent customer service',
      rating: 4.8,
      reviewCount: 1250,
      productCount: 150,
      isVerified: true,
      joinedAt: DateTime.now().subtract(const Duration(days: 365)),
    );
  }

  List<Map<String, dynamic>> _generateTrackingInfo() {
    return [
      {
        'status': 'Order Placed',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'description': 'Your order has been placed successfully',
      },
      {
        'status': 'Processing',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'description': 'Your order is being prepared',
      },
      {
        'status': 'Shipped',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'description': 'Your order has been shipped',
      },
    ];
  }
}