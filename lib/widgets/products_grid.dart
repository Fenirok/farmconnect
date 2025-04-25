import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final String? selectedCategory;

  const ProductsGrid({
    Key? key,
    this.selectedCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products = selectedCategory == null
        ? productsData.items
        : productsData.getProductsByCategory(selectedCategory!);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ProductItem(
        product: products[i],
      ),
    );
  }
}
