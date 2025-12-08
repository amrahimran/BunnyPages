// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../components/custombar.dart';
import '../components/bottombar.dart';
import 'details.dart';
import 'package:project/services/connectivity_banner.dart'; // <-- added

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color accentColor = const Color(0xFF7dadc4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'My Wishlist',
          style: TextStyle(
            color: accentColor,
            fontFamily: 'Chewy',
            fontSize: 25,
          ),
        ),
      ),

      // 🔥 Added here — right below the AppBar, safe & consistent with your other pages
      body: Column(
        children: [
          const ConnectivityBanner(), // <-- added exactly as you wanted

          Expanded(
            child: wishlistProvider.items.isEmpty
                ? Center(
                    child: Text(
                      'Your wishlist is empty',
                      style: TextStyle(color: textColor, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: wishlistProvider.items.length,
                    itemBuilder: (context, index) {
                      final product = wishlistProvider.items.elementAt(index);

                      return Card(
                        color:
                            isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/${product.image}',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Rs. ${product.price}',
                            style: TextStyle(color: textColor),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.shopping_cart,
                                    color: accentColor),
                                onPressed: () {
                                  cartProvider.addToCart(product, 1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Added to cart!')),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  wishlistProvider.toggleWishlist(product);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailsPage(productId: product.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: const Bottombar(),
      backgroundColor: backgroundColor,
    );
  }
}
