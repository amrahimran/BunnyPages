import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  Set<Product> _items = {};

  Set<Product> get items => _items;

  WishlistProvider() {
    loadWishlist();
  }

  bool isInWishlist(Product product) => _items.contains(product);

  void toggleWishlist(Product product) {
    if (_items.contains(product)) {
      _items.remove(product);
    } else {
      _items.add(product);
    }
    saveWishlist();
    notifyListeners();
  }

  Future<void> saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedProducts = _items.map((p) {
      return json.encode({
        'id': p.id,
        'name': p.name,
        'category': p.category,
        'color': p.color,
        'description': p.description,
        'price': p.price,
        'quantity': p.quantity,
        'image': p.image,
        'isBestSeller': p.isBestSeller,
      });
    }).toList();
    await prefs.setStringList('wishlist', encodedProducts);
  }

  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedList = prefs.getStringList('wishlist');
    if (savedList != null) {
      _items = savedList
          .map((p) => Product.fromJson(json.decode(p)))
          .toSet();
      notifyListeners();
    }
  }
}
