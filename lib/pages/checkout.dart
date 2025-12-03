// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../components/custombar.dart';
import '../components/bottombar.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;

  CheckoutPage({required this.cartItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String paymentMethod = "Cash on Delivery";

  @override
  void initState() {
    super.initState();
    loadPhone();
  }

  loadPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneController.text = prefs.getString("phone") ?? "";
  }

  savePhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("phone", phoneController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cartItems.fold(
        0,
        (previousValue, element) =>
            previousValue + element.product.price * element.quantity);

    final blueTheme = Color(0xFF7dadc4);

    return Scaffold(
      appBar: CustomBar(),
      bottomNavigationBar: Bottombar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ORDER SUMMARY
              Text("Order Summary",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: blueTheme)),
              SizedBox(height: 15),

              // Styled summary container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  children: widget.cartItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: AssetImage(item.product.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.product.name,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text("x${item.quantity}"),
                          SizedBox(width: 10),
                          Text(
                            "Rs ${(item.product.price * item.quantity).toStringAsFixed(2)}",
                            style:
                                TextStyle(fontWeight: FontWeight.bold, color: blueTheme),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            Divider(height: 30, thickness: 1.2),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total:",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Rs ${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: blueTheme)),
              ],
            ),
            SizedBox(height: 25),

            // PHONE
            Text("Phone Number", style: TextStyle(fontSize: 16)),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter phone number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => savePhone(),
            ),
            SizedBox(height: 20),

            // ADDRESS
            Text("Address", style: TextStyle(fontSize: 16)),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                hintText: "Enter address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),

            // CITY
            Text("City", style: TextStyle(fontSize: 16)),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: "Enter city",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 25),

            // PAYMENT METHOD
            Text("Payment Method", style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: blueTheme),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: paymentMethod,
                  isExpanded: true,
                  items: [
                    "Cash on Delivery",
                    "Card Payment",
                    "Bank Transfer"
                  ]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => paymentMethod = value!);
                  },
                ),
              ),
            ),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueTheme,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Place Order",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: () {
                  Provider.of<OrderProvider>(context, listen: false).placeOrder(
                    cartItems: widget.cartItems,
                    totalPrice: totalPrice,
                    phone: phoneController.text.trim(),
                    address: addressController.text.trim(),
                    city: cityController.text.trim(),
                    paymentMethod: paymentMethod,
                    context: context,
                  );
                  // Clear the cart after order is placed
                  Provider.of<CartProvider>(context, listen: false).clearCart();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
