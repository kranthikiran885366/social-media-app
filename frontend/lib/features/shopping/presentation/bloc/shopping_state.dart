import 'package:equatable/equatable.dart';
import '../../data/models/shopping_models.dart';

abstract class ShoppingState extends Equatable {
  const ShoppingState();

  @override
  List<Object?> get props => [];
}

class ShoppingInitial extends ShoppingState {}

class ShoppingLoading extends ShoppingState {}

class ProductsLoaded extends ShoppingState {
  final List<Product> products;
  final bool hasReachedMax;
  final String? category;

  const ProductsLoaded({
    required this.products,
    this.hasReachedMax = false,
    this.category,
  });

  @override
  List<Object?> get props => [products, hasReachedMax, category];
}

class ProductDetailsLoaded extends ShoppingState {
  final Product product;
  final List<Product> relatedProducts;

  const ProductDetailsLoaded(this.product, {this.relatedProducts = const []});

  @override
  List<Object?> get props => [product, relatedProducts];
}

class CartLoaded extends ShoppingState {
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;

  const CartLoaded({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
  });

  @override
  List<Object?> get props => [items, subtotal, tax, shipping, total];
}

class WishlistLoaded extends ShoppingState {
  final List<Product> products;

  const WishlistLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class OrdersLoaded extends ShoppingState {
  final List<Order> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailsLoaded extends ShoppingState {
  final Order order;
  final List<Map<String, dynamic>>? trackingInfo;

  const OrderDetailsLoaded(this.order, {this.trackingInfo});

  @override
  List<Object?> get props => [order, trackingInfo];
}

class ShopCollectionsLoaded extends ShoppingState {
  final List<ShopCollection> collections;

  const ShopCollectionsLoaded(this.collections);

  @override
  List<Object?> get props => [collections];
}

class SellerProfileLoaded extends ShoppingState {
  final Seller seller;
  final List<Product> products;
  final List<ShopCollection> collections;

  const SellerProfileLoaded({
    required this.seller,
    required this.products,
    required this.collections,
  });

  @override
  List<Object?> get props => [seller, products, collections];
}

class RecommendedProductsLoaded extends ShoppingState {
  final List<Product> products;

  const RecommendedProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class RecentlyViewedLoaded extends ShoppingState {
  final List<Product> products;

  const RecentlyViewedLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class SponsoredProductsLoaded extends ShoppingState {
  final List<Product> products;

  const SponsoredProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductAddedToCart extends ShoppingState {
  final Product product;
  final int cartItemCount;

  const ProductAddedToCart(this.product, this.cartItemCount);

  @override
  List<Object?> get props => [product.id, cartItemCount];
}

class ProductRemovedFromCart extends ShoppingState {
  final String productId;
  final int cartItemCount;

  const ProductRemovedFromCart(this.productId, this.cartItemCount);

  @override
  List<Object?> get props => [productId, cartItemCount];
}

class ProductAddedToWishlist extends ShoppingState {
  final Product product;

  const ProductAddedToWishlist(this.product);

  @override
  List<Object?> get props => [product.id];
}

class ProductRemovedFromWishlist extends ShoppingState {
  final String productId;

  const ProductRemovedFromWishlist(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CheckoutInitiated extends ShoppingState {
  final List<CartItem> items;
  final double total;

  const CheckoutInitiated(this.items, this.total);

  @override
  List<Object?> get props => [items, total];
}

class OrderPlaced extends ShoppingState {
  final Order order;

  const OrderPlaced(this.order);

  @override
  List<Object?> get props => [order.id];
}

class ProductTagged extends ShoppingState {
  final String contentId;
  final String contentType;
  final List<ProductTag> tags;

  const ProductTagged(this.contentId, this.contentType, this.tags);

  @override
  List<Object?> get props => [contentId, contentType, tags];
}

class ShoppingError extends ShoppingState {
  final String message;

  const ShoppingError(this.message);

  @override
  List<Object?> get props => [message];
}