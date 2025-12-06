// ignore_for_file: prefer_final_fields, unused_local_variable, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/components/bottombar.dart';
import 'package:project/components/custombar.dart';
import 'package:project/components/productcard.dart';
import 'package:project/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:provider/provider.dart';
import 'package:project/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllproductsState();
}

class _AllproductsState extends State<AllProducts> {
  List<Product> fullProducts = [];
  List<Product> filteredProducts = [];
  List<String> sortOptions = ['Price', 'Low->High', 'High->Low'];
  String selectedOption = 'Price';
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  final ValueNotifier<bool> _isOnline = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    fetchProducts();

    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);

    // Listen to connectivity changes and verify actual internet
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

  Future<void> fetchProducts() async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/api/products');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> dataList = jsonResponse['data'];

        fullProducts = dataList
            .map<Product>((json) =>
                Product.fromJson(json as Map<String, dynamic>))
            .toList();

        filteredProducts = List.from(fullProducts);
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Failed to fetch products',
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Error: $e',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterProducts(String query) {
    setState(() {
      filteredProducts = fullProducts.where((product) {
        final q = query.toLowerCase();
        return product.name.toLowerCase().contains(q) ||
            product.color.toLowerCase().contains(q) ||
            product.category.toLowerCase().contains(q);
      }).toList();
    });
  }

  void sortProducts(String option) {
    setState(() {
      selectedOption = option;
      if (option == 'Low->High') {
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (option == 'High->Low') {
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF6F8FA);
    final cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintColor = isDarkMode ? Colors.white54 : Colors.grey[600];

    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: const CustomBar(),
        bottomNavigationBar: const Bottombar(selectedIndex: 1),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            child: TextField(
                              controller: _searchController,
                              onChanged: filterProducts,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                hintStyle: TextStyle(color: hintColor),
                                prefixIcon: Icon(Icons.search, color: textColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                filled: true,
                                fillColor: cardColor,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            alignment: Alignment.centerLeft,
                            height: 30,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                dropdownColor: cardColor,
                                alignment: Alignment.center,
                                borderRadius: BorderRadius.circular(25),
                                focusColor: cardColor,
                                icon: Icon(Icons.arrow_drop_down, color: textColor),
                                value: selectedOption,
                                onChanged: (String? newValue) {
                                  if (newValue == null) return;
                                  sortProducts(newValue);
                                },
                                items: sortOptions
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                        child: Text(
                                      value,
                                      style: TextStyle(color: textColor),
                                    )),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isLandscape ? 2 : 1,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                mainAxisExtent: 270,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                return ProductCard(
                                  product: filteredProducts[index],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
