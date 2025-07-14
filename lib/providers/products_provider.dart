import 'package:flutter/material.dart';
import '../models/product.dart';
// TODO: Replace with Spring Boot + PostgreSQL backend service

enum SortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  organic,
  newest,
}

class ProductsProvider with ChangeNotifier {
  // TODO: Replace with Spring Boot + PostgreSQL backend service
  // final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _error;

  List<Product> _items = [];

  SortOption _currentSortOption = SortOption.nameAsc;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get items {
    return [..._sortedItems()];
  }

  List<Product> get organicProducts {
    return _items.where((product) => product.isOrganic).toList();
  }

  SortOption get currentSortOption {
    return _currentSortOption;
  }

  void setSortOption(SortOption option) {
    _currentSortOption = option;
    notifyListeners();
  }

  List<Product> _sortedItems() {
    List<Product> sortedList = [..._items];

    switch (_currentSortOption) {
      case SortOption.nameAsc:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        sortedList.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.priceAsc:
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sortedList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.organic:
        sortedList.sort((a, b) => a.isOrganic == b.isOrganic
            ? 0
            : a.isOrganic
                ? -1
                : 1);
        break;
      case SortOption.newest:
        sortedList.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    return sortedList;
  }

  List<Product> getProductsByCategory(String category) {
    return _items.where((product) => product.category == category).toList();
  }

  List<Product> getProductsByFarmer(String farmerId) {
    return _items.where((product) => product.farmerId == farmerId).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Replace with Spring Boot + PostgreSQL backend products service
      // final products = await _supabaseService.getProducts();
      final products = <Map<String, dynamic>>[]; // Placeholder for now
      _items = products
          .map((product) => Product(
                id: product['id'].toString(),
                name: product['product_name'] ?? '',
                description: product['description'] ?? '',
                price: (product['price'] as num).toDouble(),
                imageUrl: product['image_url'] ?? '',
                category: product['type'] ?? '',
                farmerId: product['farmer_id']?.toString() ?? '',
                farmerName: product['farm_name'] ?? '',
                weight: (product['weight'] as num?)?.toDouble() ?? 1.0,
                unit: product['unit'] ?? 'kg',
                isOrganic: product['is_organic'] ?? false,
                location: product['location'] ?? '',
              ))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Replace with Spring Boot + PostgreSQL backend product creation
      // await _supabaseService.addProduct({
      //   'product_name': product.name,
      //   'description': product.description,
      //   'price': product.price,
      //   'image_url': product.imageUrl,
      //   'type': product.category,
      //   'farm_name': product.farmerName,
      //   'location': product.location,
      //   'weight': product.weight,
      //   'unit': product.unit,
      //   'is_organic': product.isOrganic,
      // });

      await fetchProducts(); // Refresh the products list

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Replace with Spring Boot + PostgreSQL backend product update
      // await _supabaseService.updateProduct(id, {
      //   'product_name': updatedProduct.name,
      //   'description': updatedProduct.description,
      //   'price': updatedProduct.price,
      //   'image_url': updatedProduct.imageUrl,
      //   'type': updatedProduct.category,
      //   'farm_name': updatedProduct.farmerName,
      //   'location': updatedProduct.location,
      //   'weight': updatedProduct.weight,
      //   'unit': updatedProduct.unit,
      //   'is_organic': updatedProduct.isOrganic,
      // });

      await fetchProducts(); // Refresh the products list

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Replace with Spring Boot + PostgreSQL backend product deletion
      // await _supabaseService.deleteProduct(id);
      _items.removeWhere((product) => product.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
