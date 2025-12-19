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
import 'package:project/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quickalert/quickalert.dart';
import 'package:permission_handler/permission_handler.dart';



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

  final ValueNotifier<bool> _isOnline = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    loadPhone();
    fetchLocation(); // Auto fetch location on page load

    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);

    connectivityService.connectivityStream.listen((result) async {
      bool online = result != ConnectivityResult.none
          ? await _checkActualInternet()
          : false;
      _isOnline.value = online;
    });
  }

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

  loadPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneController.text = prefs.getString("phone") ?? "";
  }

  savePhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("phone", phoneController.text.trim());
  }

  Future<bool> _checkLocationPermission() async {
    if (await Permission.location.isGranted) {
      return true;
    } else {
      var status = await Permission.location.request();
      if (status.isGranted) {
        return true;
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Location permission is required to auto-fill your address.',
        );
        return false;
      }
    }
  }


  Future<String> getAddressFromCoordinatesWeb(double lat, double lng) async {
    try {
      final url = kIsWeb
          ? 'http://localhost:3000/reverse?lat=$lat&lon=$lng'
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
    return "$lat, $lng";
  }

  bool _validateOrder() {
    // Check phone number
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text.trim())) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Phone number must be 10 digits.",
      );
      return false;
    }

    // Check address
    if (addressController.text.trim().isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Address cannot be empty.",
      );
      return false;
    }

    // Check city
    if (cityController.text.trim().isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "City cannot be empty.",
      );
      return false;
    }

    // Check internet
    if (!_isOnline.value) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Cannot place order without internet connection.",
      );
      return false;
    }

    return true;
  }


  Future<void> fetchLocation() async {
    setState(() => isFetchingLocation = true);

    try {
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          text: "Location service is disabled. Please enable it manually.",
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String address = "";

      if (!kIsWeb) {
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
        address = await getAddressFromCoordinatesWeb(position.latitude, position.longitude);
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

    final Color blueTheme = const Color(0xFF7dadc4);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF6F8FA);
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color hintColor = isDarkMode ? Colors.white54 : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomBar(),
      bottomNavigationBar: Bottombar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connectivity banner
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
            SizedBox(height: 10),

            Text("Order Summary",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: blueTheme)),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black26 : Colors.black.withOpacity(0.05),
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
                            style: TextStyle(
                                fontWeight: FontWeight.w500, color: textColor),
                          ),
                        ),
                        Text("x${item.quantity}", style: TextStyle(color: textColor)),
                        SizedBox(width: 10),
                        Text(
                          "Rs ${(item.product.price * item.quantity).toStringAsFixed(2)}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: blueTheme),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(height: 30, thickness: 1.2, color: isDarkMode ? Colors.white24 : Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                Text("Rs ${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: blueTheme)),
              ],
            ),
            SizedBox(height: 25),
            Text("Phone Number", style: TextStyle(fontSize: 16, color: textColor)),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Enter phone number",
                hintStyle: TextStyle(color: hintColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
              ),
              onChanged: (value) {
                savePhone();

                // Validate phone number
                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  // Show error or handle invalid input
                  print("Invalid phone number");
                }
              },
            ),

            SizedBox(height: 20),
            Text("Address", style: TextStyle(fontSize: 16, color: textColor)),
            Stack(
              children: [
                TextField(
                  controller: addressController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Enter address",
                    hintStyle: TextStyle(color: hintColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
                  ),
                ),
                if (isFetchingLocation)
                  Positioned(
                    right: 10,
                    top: 12,
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: blueTheme,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Text("City", style: TextStyle(fontSize: 16, color: textColor)),
            TextField(
              controller: cityController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Enter city",
                hintStyle: TextStyle(color: hintColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
              ),
            ),
            SizedBox(height: 25),
            Text("Payment Method", style: TextStyle(fontSize: 16, color: textColor)),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: blueTheme),
                borderRadius: BorderRadius.circular(8),
                color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: paymentMethod,
                  dropdownColor: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
                  style: TextStyle(color: textColor),
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
                  if (_validateOrder()) {
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
                  }
                },

              ),
            ),
          ],
        ),
      ),
    );
  }
}
