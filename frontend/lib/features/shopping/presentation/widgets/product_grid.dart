import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/shopping_models.dart';
import '../bloc/shopping_bloc.dart';
import '../bloc/shopping_event.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool hasReachedMax;

  const ProductGrid({
    super.key,
    required this.products,
    this.hasReachedMax = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= products.length) {
              return hasReachedMax
                  ? const SizedBox.shrink()
                  : const Center(child: CircularProgressIndicator());
            }

            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => Navigator.pushNamed(
                context,
                '/shop/product',
                arguments: product.id,
              ),
              onAddToCart: () {
                context.read<ShoppingBloc>().add(AddToCart(product));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart'),
                    action: SnackBarAction(
                      label: 'View Cart',
                      onPressed: () => Navigator.pushNamed(context, '/shop/cart'),
                    ),
                  ),
                );
              },
              onAddToWishlist: () {
                context.read<ShoppingBloc>().add(AddToWishlist(product));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} added to wishlist')),
                );
              },
            );
          },
          childCount: hasReachedMax ? products.length : products.length + 1,
        ),
      ),
    );
  }
}