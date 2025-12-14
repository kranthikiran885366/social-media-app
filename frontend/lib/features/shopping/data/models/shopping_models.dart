import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String currency;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final String category;
  final List<String> tags;
  final bool isAvailable;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? variants;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.currency,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatar,
    required this.category,
    this.tags = const [],
    this.isAvailable = true,
    this.stockQuantity = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.variants,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      images: List<String>.from(json['images'] ?? []),
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      sellerAvatar: json['sellerAvatar'],
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      variants: json['variants'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [id, name, price, sellerId, createdAt];
}

class ProductTag extends Equatable {
  final String productId;
  final double x;
  final double y;
  final Product product;

  const ProductTag({
    required this.productId,
    required this.x,
    required this.y,
    required this.product,
  });

  @override
  List<Object?> get props => [productId, x, y];
}

class CartItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;
  final Map<String, dynamic>? selectedVariants;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedVariants,
    required this.addedAt,
  });

  double get totalPrice => product.price * quantity;

  @override
  List<Object?> get props => [id, product.id, quantity, selectedVariants];
}

class Order extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final OrderStatus status;
  final ShippingAddress shippingAddress;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? trackingNumber;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.deliveredAt,
    this.trackingNumber,
  });

  @override
  List<Object?> get props => [id, userId, total, status, createdAt];
}

enum OrderStatus { pending, confirmed, processing, shipped, delivered, cancelled, refunded }

class ShippingAddress extends Equatable {
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String? phoneNumber;

  const ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, addressLine1, city, state, zipCode, country];
}

class PaymentMethod extends Equatable {
  final String id;
  final PaymentType type;
  final String? cardLast4;
  final String? cardBrand;
  final String? paypalEmail;

  const PaymentMethod({
    required this.id,
    required this.type,
    this.cardLast4,
    this.cardBrand,
    this.paypalEmail,
  });

  @override
  List<Object?> get props => [id, type, cardLast4, paypalEmail];
}

enum PaymentType { creditCard, debitCard, paypal, applePay, googlePay }

class ShopCollection extends Equatable {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final List<Product> products;
  final String sellerId;
  final DateTime createdAt;

  const ShopCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.products,
    required this.sellerId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, sellerId, createdAt];
}

class Seller extends Equatable {
  final String id;
  final String name;
  final String? avatar;
  final String? bio;
  final double rating;
  final int reviewCount;
  final int productCount;
  final bool isVerified;
  final DateTime joinedAt;

  const Seller({
    required this.id,
    required this.name,
    this.avatar,
    this.bio,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.productCount = 0,
    this.isVerified = false,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [id, name, rating, productCount, joinedAt];
}