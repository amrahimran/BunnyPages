// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
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
  bool isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    loadPhone();
    fetchLocation(); // Auto fetch location on page load
  }

  loadPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneController.text = prefs.getString("phone") ?? "";
  }

  savePhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("phone", phoneController.text.trim());
  }

  // Reverse geocoding for Web using Nominatim or proxy
  Future<String> getAddressFromCoordinatesWeb(double lat, double lng) async {
    try {
      final url = kIsWeb
          ? 'http://localhost:3000/reverse?lat=$lat&lon=$lng' // Use your Node.js proxy here
          : 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng';

      final response = await http.get(
        Uri.parse(url),
        headers: {"User-Agent": "FlutterApp/1.0 (your_email@example.com)"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) return data['display_name'];
        if (data['address'] != null) return data['address'].toString();
      }
    } catch (e) {
      print("Nominatim error: $e");
    }
    return "$lat, $lng"; // fallback
  }

  Future<void> fetchLocation() async {
    setState(() => isFetchingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location service is disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Location permission denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String address = "";

      if (!kIsWeb) {
        // Mobile: use placemarkFromCoordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark p = placemarks.first;
          address = [p.street, p.subLocality, p.locality]
              .where((s) => s != null && s.isNotEmpty)
              .join(", ");
          cityController.text = p.locality ?? "";
        }
      } else {
        // Web: use proxy or Nominatim
        address =
            await getAddressFromCoordinatesWeb(position.latitude, position.longitude);
      }

      if (address.isEmpty) address = "${position.latitude}, ${position.longitude}";

      setState(() {
        addressController.text = address;
      });
    } catch (e) {
      print("Location error: $e");
      setState(() {
        addressController.text = "Unable to fetch address, enter manually";
      });
    } finally {
      setState(() => isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cartItems.fold(
      0,
      (prev, item) => prev + item.product.price * item.quantity,
    );

    final blueTheme = Color(0xFF7dadc4);

    return Scaffold(
      appBar: CustomBar(),
      bottomNavigationBar: Bottombar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Summary",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: blueTheme)),
            SizedBox(height: 15),
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
                Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Rs ${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: blueTheme)),
              ],
            ),
            SizedBox(height: 25),
            Text("Phone Number", style: TextStyle(fontSize: 16)),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter phone number",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (_) => savePhone(),
            ),
            SizedBox(height: 20),
            Text("Address", style: TextStyle(fontSize: 16)),
            Stack(
              children: [
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: "Enter address",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (isFetchingLocation)
                  Positioned(
                    right: 10,
                    top: 12,
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Text("City", style: TextStyle(fontSize: 16)),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: "Enter city",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 25),
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
                  items: ["Cash on Delivery", "Card Payment", "Bank Transfer"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => paymentMethod = value!),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Place Order", style: TextStyle(fontSize: 18, color: Colors.white)),
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
