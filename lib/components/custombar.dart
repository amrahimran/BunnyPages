// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:project/pages/cart.dart';
import 'package:project/pages/wishlist.dart';

class CustomBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomBar({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App Title
              Text(
                'Bunny Pages',
                style: TextStyle(
                  fontFamily: 'Chewy',
                  fontSize: 27,
                  color: isDarkMode ? Colors.grey : const Color(0xFF7dadc4),
                ),
              ),

              // Buttons (Wishlist & Cart)
              Row(
                children: [
                  // Wishlist Button
                  IconButton(
                    icon: Icon(
                      Icons.favorite, // heart icon
                      size: 28,
                      color: isDarkMode ? Colors.grey : const Color(0xFF7dadc4),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WishlistPage()),
                      );
                    },
                  ),

                  // Cart Button
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart_rounded,
                      size: 28,
                      color: isDarkMode ? Colors.grey : const Color(0xFF7dadc4),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
