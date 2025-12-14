import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

part 'shopping_event.dart';
part 'shopping_state.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  ShoppingBloc() : super(ShoppingInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<LoadCart>(_onLoadCart);
    on<Checkout>(_onCheckout);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ShoppingState> emit) async {
    emit(ShoppingLoading());
    try {
      // Mock products - integrate with backend
      final products = [
        Product(
          id: '1',
          name: 'Trendy T-Shirt',
          price: 29.99,
          imageUrl: 'https://example.com/product1.jpg',
          description: 'Comfortable cotton t-shirt',
          category: 'Clothing',
          rating: 4.5,
          reviews: 120,
        ),
      ];
      emit(ShoppingLoaded(products));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<ShoppingState> emit) async {
    emit(ShoppingLoading());
    try {
      // Call search API
      final result = await ApiService.searchContent(event.query);
      if (result['success']) {
        // Parse products from result
        emit(ShoppingLoaded([]));
      }
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  void _onAddToCart(AddToCart event, Emitter<ShoppingState> emit) async {
    // Add to cart logic
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<ShoppingState> emit) async {
    // Remove from cart logic
  }

  void _onLoadCart(LoadCart event, Emitter<ShoppingState> emit) async {
    // Load cart items
  }

  void _onCheckout(Checkout event, Emitter<ShoppingState> emit) async {
    try {
      final result = await ApiService.createPayment({
        'items': event.items,
        'total': event.total,
      });
      
      if (result['success']) {
        emit(CheckoutSuccess());
      } else {
        emit(ShoppingError(result['error']));
      }
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String category;
  final double rating;
  final int reviews;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.rating,
    required this.reviews,
  });
}