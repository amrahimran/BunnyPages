import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  CartProvider() {
    _loadCart();
  }

  void addToCart(Product product, int quantity) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
    _saveCart();
  }

  /// ⭐ UPDATE QUANTITY (optional)
  void updateQuantity(String productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity = newQuantity;
      notifyListeners();
      _saveCart();
    }
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    notifyListeners();
    _saveCart();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }

  // ----------------- PERSIST CART -----------------
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = _items.values.map((item) => json.encode({
      'productId': item.product.id,
      'name': item.product.name,
      'price': item.product.price,
      'image': item.product.image,
      'category': item.product.category,
      'color': item.product.color,
      'quantity': item.quantity,
      'description': item.product.description,
      'isBestSeller': item.product.isBestSeller,
    })).toList();

    await prefs.setStringList('cartItems', cartList);
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cartList = prefs.getStringList('cartItems');

    if (cartList != null) {
      for (String item in cartList) {
        final Map<String, dynamic> data = json.decode(item);
        _items[data['productId']] = CartItem(
          product: Product(
            id: data['productId'],
            name: data['name'],
            price: data['price'],
            image: data['image'],
            category: data['category'],
            color: data['color'],
            description: data['description'],
            quantity: data['quantity'],
            isBestSeller: data['isBestSeller'] ?? false, // required param
          ),
          quantity: data['quantity'],
        );
      }
      notifyListeners();
    }
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
