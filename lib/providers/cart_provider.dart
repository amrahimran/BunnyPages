import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  /// ⭐ TOTAL AMOUNT (required by checkout.dart)

  double get totalAmount {
    double total = 0.0;
    _items.forEach((_, item) {
      total += item.product.price * item.quantity;
    });
    return total;
  }
  
  void addToCart(Product product, int quantity) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] =
          CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  /// ⭐ UPDATE QUANTITY (optional)
  void updateQuantity(String productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity = newQuantity;
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
