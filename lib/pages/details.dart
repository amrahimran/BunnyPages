// ignore_for_file: unused_import, unused_local_variable, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/components/custombar.dart';
import 'package:provider/provider.dart';
import 'package:project/components/bottombar.dart';
import 'package:project/models/product.dart';
import 'package:project/providers/cart_provider.dart';
import 'package:project/providers/wishlist_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:quickalert/quickalert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DetailsPage extends StatefulWidget {
  final String productId;

  const DetailsPage({super.key, required this.productId});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Product? selectedProduct;
  bool isLoading = true;
  int quantity = 1;

  // Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference reviewsCollection;

  // Review input
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;

  // User info (from API / SharedPreferences)
  Map<String, dynamic>? userData;
  String phoneNumber = '';

  String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
      if (Platform.isIOS) return 'http://localhost:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // fetch logged-in user details
    reviewsCollection = _firestore
        .collection('product_reviews')
        .doc(widget.productId)
        .collection('reviews');
    fetchProductDetails(widget.productId);
  }

  // Fetch user details like ProfilePage
  Future<void> fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      phoneNumber = prefs.getString('phone') ?? '';

      if (token.isEmpty) return;

      final url = Uri.parse('$baseUrl/api/user');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Map<String, dynamic>? user;
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('user') && jsonData['user'] is Map) {
            user = Map<String, dynamic>.from(jsonData['user']);
          } else if (jsonData.containsKey('data') && jsonData['data'] is Map) {
            user = Map<String, dynamic>.from(jsonData['data']);
          } else {
            user = Map<String, dynamic>.from(jsonData);
          }
        }
        setState(() => userData = user);
      }
    } catch (_) {}
  }

  Future<void> fetchProductDetails(String productId) async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('$baseUrl/api/products/$productId');
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] ?? json.decode(response.body);

        setState(() {
          selectedProduct = Product(
            id: data['id'] ?? '',
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            price: data['price'] ?? 0,
            image: data['image'] != null && data['image'].isNotEmpty
                ? 'assets/${data['image']}'
                : 'assets/images/default.png',
            category: data['category'] ?? 'other',
            color: data['color'] ?? '',
            quantity: data['quantity'] ?? 1,
            isBestSeller: (data['isBestSeller'] ?? 0) == 1,
          );
          quantity = 1;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Failed to load product details',
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Error fetching product: $e',
      );
    }
  }

  void switchSize(String newSize) {
    if (selectedProduct == null) return;
    String updatedId = selectedProduct!.id;

    if (newSize == 'B5' && updatedId.startsWith('L')) {
      updatedId = 'M${updatedId.substring(1)}';
    } else if (newSize == 'A5' && updatedId.startsWith('M')) {
      updatedId = 'L${updatedId.substring(1)}';
    }

    fetchProductDetails(updatedId);
  }

  void switchColor(String newColor) {
    if (selectedProduct == null || !selectedProduct!.id.contains('C')) return;

    final parts = selectedProduct!.id.split('C');
    if (parts.isEmpty) return;

    final newId = '${parts[0]}C$newColor'.toUpperCase();
    fetchProductDetails(newId);
  }

  Color _colorFromString(String color) {
    switch (color.toUpperCase()) {
      case 'BLACK':
        return Colors.black;
      case 'PINK':
        return const Color(0xFFFFACB7);
      case 'BLUE':
        return const Color(0xFF7dadc4);
      case 'GREEN':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Submit review using API user details (no FirebaseAuth)
  Future<void> submitReview() async {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Please provide a rating and review',
      );
      return;
    }

    final userName = userData?['name'] ?? userData?['email'] ?? 'Anonymous';
    final userId = userData?['id']?.toString() ?? '';

    await reviewsCollection.add({
      'rating': _rating,
      'review': _reviewController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
      'userName': userName,
    });

    _reviewController.clear();
    setState(() => _rating = 0);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Review submitted successfully!',
    );
  }

  Widget buildReviewsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: reviewsCollection.orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final reviews = snapshot.data!.docs;
        if (reviews.isEmpty) return const Text('No reviews yet.');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reviews.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final rating = data['rating'] ?? 0;
            final review = data['review'] ?? '';
            final userName = data['userName'] ?? 'Anonymous';
            final userId = data['userId'] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.amber),
                title: Text('$rating / 5'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review),
                    const SizedBox(height: 4),
                    Text('by $userName', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                trailing: userData != null && userData!['id']?.toString() == userId
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await reviewsCollection.doc(doc.id).delete();
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                            text: 'Review deleted successfully!',
                          );
                        },
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildRatingInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rate this product:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return IconButton(
              onPressed: () => setState(() => _rating = starIndex),
              icon: Icon(_rating >= starIndex ? Icons.star : Icons.star_border, color: Colors.amber),
            );
          }),
        ),
        TextField(
          controller: _reviewController,
          decoration: const InputDecoration(
            hintText: 'Write your review...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          minLines: 1,
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submitReview,
            child: const Text('Submit Review'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color accentColor = const Color(0xFF7dadc4);

    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final possibleColors = ['BLACK', 'PINK', 'BLUE', 'GREEN'];

    return Scaffold(
      appBar: const CustomBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : selectedProduct == null
              ? Center(child: Text("Product not found", style: TextStyle(color: textColor)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PRODUCT IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          selectedProduct!.image,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 25),
                      // NAME + WISHLIST
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              selectedProduct!.name,
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              wishlistProvider.isInWishlist(selectedProduct!) ? Icons.favorite : Icons.favorite_border,
                              color: accentColor,
                              size: 30,
                            ),
                            onPressed: () => wishlistProvider.toggleWishlist(selectedProduct!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // PRICE
                      Text('Rs. ${selectedProduct!.price}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: accentColor)),
                      const SizedBox(height: 25),
                      // DESCRIPTION
                      Text(selectedProduct!.description, style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.85))),
                      const SizedBox(height: 40),
                      // SIZE SELECTOR
                      if (selectedProduct!.category != 'other')
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _sizeButton('A5', accentColor),
                              const SizedBox(width: 28),
                              _sizeButton('B5', accentColor),
                            ],
                          ),
                        ),
                      if (selectedProduct!.category != 'other') const SizedBox(height: 45),
                      // COLOR SELECTOR
                      if (selectedProduct!.id.contains('C'))
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Colors:', style: TextStyle(fontFamily: 'MontserratSemiBold', fontSize: 16)),
                              const SizedBox(width: 14),
                              Row(
                                children: possibleColors.map((c) {
                                  final isSelected = selectedProduct!.color.toUpperCase() == c;
                                  return GestureDetector(
                                    onTap: () => switchColor(c),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: _colorFromString(c),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isSelected ? accentColor : Colors.grey, width: 2),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      if (selectedProduct!.id.contains('C')) const SizedBox(height: 35),
                      // QUANTITY + ADD TO CART
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(25)),
                              child: Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() { if (quantity > 1) quantity--; })),
                                  Text(quantity.toString(), style: TextStyle(fontSize: 18, color: textColor)),
                                  IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => quantity++)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      // ADD TO CART BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            cartProvider.addToCart(selectedProduct!, quantity);
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              text: '$quantity item(s) added to cart!',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text('Add To Cart', style: TextStyle(fontFamily: 'MontserratSemiBold', fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 35),
                      // REVIEW & RATINGS
                      buildRatingInput(),
                      buildReviewsSection(),
                    ],
                  ),
                ),
      bottomNavigationBar: const Bottombar(),
    );
  }

  Widget _sizeButton(String label, Color accentColor) {
    return ElevatedButton(
      onPressed: () => switchSize(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.fromLTRB(32, 14, 32, 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18, fontFamily: 'MontserratRegular')),
    );
  }
}
