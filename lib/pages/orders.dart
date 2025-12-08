// ignore_for_file: deprecated_member_use, unused_import, library_private_types_in_public_api, avoid_print, unnecessary_to_list_in_spreads

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../components/custombar.dart';
import '../components/bottombar.dart';
import '../services/connectivity_banner.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse("http://10.0.2.2:8000/api/orders");
    //final url = Uri.parse("http://127.0.0.1:8000/api/orders");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildOrderCard(dynamic order, bool isDarkMode) {
    List<dynamic> items = order['items'] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
      shadowColor: isDarkMode ? Colors.black26 : Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Text(
              "Order #${order['id']}",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFF80CBC4) : const Color(0xFF7dadc4)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: Rs ${order['total']}",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[300] : Colors.black)),
                Text("Status: ${order['status'] ?? 'Pending'}",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? const Color(0xFF80CBC4) : const Color(0xFF7dadc4))),
              ],
            ),
            const SizedBox(height: 5),
            Text("Payment: ${order['payment_method']}",
                style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black)),
            Text("City: ${order['city']}",
                style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black)),
            const SizedBox(height: 12),
            Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
            // Order items with product image
            ...items.map((item) {
              final product = item['product'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    product != null
                        ? Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: DecorationImage(
                                image: AssetImage('assets/${product['image']}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Icon(Icons.book,
                            color: isDarkMode ? const Color(0xFF80CBC4) : const Color(0xFF7dadc4),
                            size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        product != null ? product['name'] : item['product_id'],
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.grey[300] : Colors.black),
                      ),
                    ),
                    Text(
                      "x${item['quantity']}",
                      style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Rs ${item['price']}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[300] : Colors.black),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF6F8FA),
      appBar: const CustomBar(),
      bottomNavigationBar: const Bottombar(),
      body: Column(
        children: [
          const ConnectivityBanner(),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: isDarkMode ? const Color(0xFF80CBC4) : const Color(0xFF7dadc4)),
                    )
                  : orders.isEmpty
                      ? Center(
                          child: Text(
                            "You have no orders yet.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            return buildOrderCard(orders[index], isDarkMode);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
