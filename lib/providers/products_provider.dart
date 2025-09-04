import 'dart:io';

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  organic,
  newest,
}

class ProductsProvider with ChangeNotifier {
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

  List<Product> getProductsByFarmer(int farmerId) {
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

      print('Fetching products from backend...');
      // Fetch products from Spring Boot backend
      _items = await ProductService.fetchProducts();
      print('Fetched ${_items.length} products from backend');

      _isLoading = false;
      notifyListeners();
      print('Fetch completed and listeners notified');
    } catch (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      print('Error fetching products: $error');
    }
  }

  Future<Map<String, dynamic>> addProduct(
      Product product, File imageFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Starting to add product: ${product.name}');

      String imageUrl = await ProductService.uploadImage(imageFile);
      print('Image uploaded successfully: $imageUrl');

      final result = await ProductService.addProduct(product, imageUrl);
      print('Product service response: $result');

      if (result['success']) {
        // Product added successfully
        await fetchProducts(); // Refresh the products list
        print('Products refreshed. Total products: ${_items.length}');

        _isLoading = false;
        notifyListeners();
        print('Provider notified listeners');

        return result;
      } else {
        // AI validation failed
        _isLoading = false;
        notifyListeners();
        print('AI validation failed: ${result['message']}');

        return result;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error in addProduct: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await ProductService.updateProduct(id, updatedProduct);

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

      await ProductService.deleteProduct(id);
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
