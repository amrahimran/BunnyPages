// ignore_for_file: unused_import, unused_local_variable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/components/custombar.dart';
import 'package:provider/provider.dart';
import 'package:project/components/bottombar.dart';
import 'package:project/models/product.dart';
import 'package:project/pages/cart.dart';
import 'package:project/providers/cart_provider.dart';
import 'package:project/providers/wishlist_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:quickalert/quickalert.dart';

class DetailsPage extends StatefulWidget {
  final String productId;

  const DetailsPage({super.key, required this.productId});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Product? selectedProduct;
  bool isLoading = true;
  int quantity = 1; // Quantity selector

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
    fetchProductDetails(widget.productId);
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
          quantity = 1; // Reset quantity on new product
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

  void switchColor(String newColorCode) {
    if (selectedProduct == null || !selectedProduct!.id.contains('C')) return;
    final parts = selectedProduct!.id.split('C');
    if (parts.length == 2) {
      final newId = '${parts[0]}C${newColorCode.toUpperCase()}';
      fetchProductDetails(newId);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color accentColor = const Color(0xFF7dadc4);

    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      appBar: const CustomBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : selectedProduct == null
              ? Center(
                  child: Text(
                    "Product not found",
                    style: TextStyle(color: textColor),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Image.asset(
                          selectedProduct!.image,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 50),
                        ),
                        const SizedBox(height: 20),

                        // Name + Wishlist
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedProduct!.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                wishlistProvider.isInWishlist(selectedProduct!)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: accentColor,
                              ),
                              onPressed: () {
                                wishlistProvider.toggleWishlist(selectedProduct!);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          selectedProduct!.description,
                          style: TextStyle(color: textColor),
                        ),
                        const SizedBox(height: 25),

                        // Size selector
                        if (selectedProduct!.category != 'other') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => switchSize('A5'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.fromLTRB(36, 16, 36, 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'A5',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'MontserratRegular'),
                                ),
                              ),
                              const SizedBox(width: 36.0),
                              ElevatedButton(
                                onPressed: () => switchSize('B5'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.fromLTRB(36, 16, 36, 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'B5',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'MontserratRegular'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 25),

                        // Color selector
                        if (selectedProduct!.id.contains('C')) ...[
                          Row(
                            children: [
                              const Text('Colors:',
                                  style: TextStyle(fontFamily: 'MontserratSemiBold')),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => switchColor('BLACK'),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey, width: 1.5),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => switchColor('PINK'),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFACB7),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey, width: 1.5),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => switchColor('BLUE'),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 25),

                        // Price + Quantity Selector + Add to Cart (Vertical)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price
                            Text(
                              'Rs. ${selectedProduct!.price}',
                              style: TextStyle(
                                  fontFamily: 'MontserratSemiBold',
                                  fontSize: 18,
                                  color: textColor),
                            ),
                            const SizedBox(height: 12),

                            // Quantity selector
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          if (quantity > 1) setState(() => quantity--);
                                        },
                                      ),
                                      Text(
                                        quantity.toString(),
                                        style: TextStyle(fontSize: 18, color: textColor),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => setState(() => quantity++),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Add to Cart button
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
                                  foregroundColor: Colors.white,
                                  backgroundColor: accentColor,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Add To Cart',
                                  style: TextStyle(
                                      fontFamily: 'MontserratSemiBold', fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const Bottombar(),
    );
  }
}
