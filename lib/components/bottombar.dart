// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:project/pages/homepage.dart';
import 'package:project/pages/allproducts.dart';
import 'package:project/pages/orders.dart';
import 'package:project/pages/profilepage.dart';

class Bottombar extends StatelessWidget {
  final int selectedIndex;

  const Bottombar({super.key, this.selectedIndex = 0});

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return; // Prevent unnecessary rebuilds

    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AllProducts()));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const OrdersPage()));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
     }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 8,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home, 0, "Home", context, isDark),
            _navItem(Icons.search, 1, "Browse", context, isDark),
            _navItem(Icons.receipt_long, 2, "Orders", context, isDark),
            _navItem(Icons.account_circle, 3, "Profile", context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label, BuildContext context, bool isDark) {
    bool isActive = index == selectedIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () => _navigate(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? const Color(0xFF7dadc4).withOpacity(0.15)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive
              ? const Color(0xFF7dadc4)
              : isDark
                  ? Colors.white70
                  : Colors.grey,
        ),
      ),
    );
  }
}
