import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product, {int quantity = 50, double? negotiatedPrice}) {
    if (_items.containsKey(product.id)) {
      // Update the quantity
      _items.update(
        product.id,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity + quantity,
        ),
      );
    } else {
      // Add new item
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toString(),
          productId: product.id,
          name: product.name,
          price: negotiatedPrice ?? product.price,
          imageUrl: product.imageUrl,
          quantity: quantity,
          farmerName: product.farmName,
          weight: product.weight,
          unit: product.unit,
          isNegotiated: negotiatedPrice != null,
        ),
      );
    }
    notifyListeners();
  }

  void addSingleItem(Product product, {double? negotiatedPrice}) {
    if (_items.containsKey(product.id)) {
      // Add just 1 to the quantity
      _items.update(
        product.id,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity + 1,
        ),
      );
      notifyListeners();
    } else {
      // For new items, still use the minimum of 50
      addItem(product, negotiatedPrice: negotiatedPrice);
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 50) {
      _items.update(
        productId,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity - 1,
        ),
      );
      notifyListeners();
    }
    // Don't remove or reduce if at minimum quantity (50)
  }

  bool canReduceQuantity(String productId) {
    if (!_items.containsKey(productId)) {
      return false;
    }
    return _items[productId]!.quantity > 50;
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
