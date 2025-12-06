// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../components/bottombar.dart';
import '../pages/checkout.dart';
import 'package:project/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ValueNotifier<bool> _isOnline = ValueNotifier<bool>(true);

  Future<bool> _checkActualInternet() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);

    // Listen to connectivity changes
    connectivityService.connectivityStream.listen((result) async {
      bool online =
          result != ConnectivityResult.none ? await _checkActualInternet() : false;
      _isOnline.value = online;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    Color accentColor = const Color(0xFF7dadc4);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'My Cart',
          style: TextStyle(
            color: accentColor,
            fontFamily: 'Chewy',
            fontSize: 25,
          ),
        ),
      ),
      body: Column(
        children: [
          // Network connectivity banner
          ValueListenableBuilder<bool>(
            valueListenable: _isOnline,
            builder: (context, isOnline, _) {
              return isOnline
                  ? const SizedBox.shrink()
                  : Container(
                      color: Colors.red,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'No Internet Connection',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
            },
          ),

          // Page content
          Expanded(
            child: cartProvider.items.isEmpty
                ? Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(color: textColor, fontSize: 18),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: cartProvider.items.length,
                          itemBuilder: (context, index) {
                            final cartItem =
                                cartProvider.items.values.elementAt(index);

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    cartItem.product.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, _) =>
                                        const Icon(Icons.error, size: 50),
                                  ),
                                ),
                                title: Text(
                                  cartItem.product.name,
                                  style: TextStyle(
                                    fontFamily: 'MontserratSemiBold',
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  'Rs. ${cartItem.product.price} x ${cartItem.quantity} = '
                                  'Rs. ${cartItem.product.price * cartItem.quantity}',
                                  style: TextStyle(
                                    fontFamily: 'MontserratRegular',
                                    color: textColor,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: accentColor),
                                  onPressed: () {
                                    cartProvider.removeFromCart(cartItem.product.id);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ---- CHECKOUT BUTTON ----
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  cartItems: cartProvider.items.values.toList(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_checkout,
                              size: 24, color: Colors.white),
                          label: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontFamily: 'MontserratSemiBold',
                              fontSize: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const Bottombar(),
    );
  }
}
