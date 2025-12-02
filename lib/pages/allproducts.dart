// ignore_for_file: prefer_final_fields, unused_local_variable, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/components/bottombar.dart';
import 'package:project/components/custombar.dart';
import 'package:project/components/productcard.dart';
import 'package:project/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';

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

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      // Fetch products from API
      var url = Uri.parse('http://127.0.0.1:8000/api/products');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> dataList = jsonResponse['data'];

        fullProducts = dataList
            .map<Product>((json) => Product.fromJson(json as Map<String, dynamic>))
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      child: Scaffold(
        appBar: const CustomBar(),
        bottomNavigationBar: const Bottombar(selectedIndex: 1),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: TextField(
                        controller: _searchController,
                        onChanged: filterProducts,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      alignment: Alignment.centerLeft,
                      height: 30,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          alignment: Alignment.center,
                          borderRadius: BorderRadius.circular(25),
                          focusColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down),
                          value: selectedOption,
                          onChanged: (String? newValue) {
                            if (newValue == null) return;
                            sortProducts(newValue);
                          },
                          items: sortOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Center(child: Text(value)),
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
    );
  }
}
