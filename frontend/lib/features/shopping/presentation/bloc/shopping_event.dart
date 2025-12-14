import 'package:equatable/equatable.dart';
import '../../data/models/shopping_models.dart';

abstract class ShoppingEvent extends Equatable {
  const ShoppingEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ShoppingEvent {
  final String? category;
  final int page;
  final int limit;

  const LoadProducts({this.category, this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [category, page, limit];
}

class SearchProducts extends ShoppingEvent {
  final String query;
  final String? category;

  const SearchProducts(this.query, {this.category});

  @override
  List<Object?> get props => [query, category];
}

class LoadProductDetails extends ShoppingEvent {
  final String productId;

  const LoadProductDetails(this.productId);

  @override
  List<Object?> get props => [productId];
}

class AddToCart extends ShoppingEvent {
  final Product product;
  final int quantity;
  final Map<String, dynamic>? variants;

  const AddToCart(this.product, {this.quantity = 1, this.variants});

  @override
  List<Object?> get props => [product.id, quantity, variants];
}

class RemoveFromCart extends ShoppingEvent {
  final String cartItemId;

  const RemoveFromCart(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class UpdateCartQuantity extends ShoppingEvent {
  final String cartItemId;
  final int quantity;

  const UpdateCartQuantity(this.cartItemId, this.quantity);

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class LoadCart extends ShoppingEvent {}

class ClearCart extends ShoppingEvent {}

class AddToWishlist extends ShoppingEvent {
  final Product product;

  const AddToWishlist(this.product);

  @override
  List<Object?> get props => [product.id];
}

class RemoveFromWishlist extends ShoppingEvent {
  final String productId;

  const RemoveFromWishlist(this.productId);

  @override
  List<Object?> get props => [productId];
}

class LoadWishlist extends ShoppingEvent {}

class BuyNow extends ShoppingEvent {
  final Product product;
  final int quantity;
  final Map<String, dynamic>? variants;

  const BuyNow(this.product, {this.quantity = 1, this.variants});

  @override
  List<Object?> get props => [product.id, quantity, variants];
}

class Checkout extends ShoppingEvent {
  final ShippingAddress shippingAddress;
  final PaymentMethod paymentMethod;

  const Checkout(this.shippingAddress, this.paymentMethod);

  @override
  List<Object?> get props => [shippingAddress, paymentMethod];
}

class LoadOrders extends ShoppingEvent {}

class LoadOrderDetails extends ShoppingEvent {
  final String orderId;

  const LoadOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class TrackOrder extends ShoppingEvent {
  final String orderId;

  const TrackOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class LoadShopCollections extends ShoppingEvent {
  final String? sellerId;

  const LoadShopCollections({this.sellerId});

  @override
  List<Object?> get props => [sellerId];
}

class LoadSellerProfile extends ShoppingEvent {
  final String sellerId;

  const LoadSellerProfile(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}

class LoadRecommendedProducts extends ShoppingEvent {}

class LoadRecentlyViewedProducts extends ShoppingEvent {}

class AddRecentlyViewed extends ShoppingEvent {
  final Product product;

  const AddRecentlyViewed(this.product);

  @override
  List<Object?> get props => [product.id];
}

class LoadSponsoredProducts extends ShoppingEvent {}

class TagProductInPost extends ShoppingEvent {
  final String postId;
  final List<ProductTag> productTags;

  const TagProductInPost(this.postId, this.productTags);

  @override
  List<Object?> get props => [postId, productTags];
}

class TagProductInReel extends ShoppingEvent {
  final String reelId;
  final List<ProductTag> productTags;

  const TagProductInReel(this.reelId, this.productTags);

  @override
  List<Object?> get props => [reelId, productTags];
}

class TagProductInStory extends ShoppingEvent {
  final String storyId;
  final List<ProductTag> productTags;

  const TagProductInStory(this.storyId, this.productTags);

  @override
  List<Object?> get props => [storyId, productTags];
}