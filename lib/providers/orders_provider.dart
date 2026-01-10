// ignore_for_file: unused_import, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';

class OrderProvider with ChangeNotifier {
  Future<void> placeOrder({
    required List<CartItem> cartItems,
    required double totalPrice,
    required String phone,
    required String address,
    required String city,
    required String paymentMethod,
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You must be logged in to place an order")),
        );
        return;
      }

      final url = Uri.parse('http://10.0.2.2:8000/api/checkout/place-order');

      final body = {
        "phone": phone,
        "address": address,
        "city": city,
        "payment_method": paymentMethod,
        "total": totalPrice,
        "items": cartItems
            .map((item) => {
                  "product_id": item.product.id,
                  "quantity": item.quantity,
                  "price": item.product.price
                })
            .toList()
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Order Placed!"),
            content: Text("Your order has been successfully placed."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Error"),
            content: Text("Something went wrong.\n${response.body}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print("Order Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing order")),
      );
    }
  }
}
