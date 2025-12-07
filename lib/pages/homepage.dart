// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/components/bottombar.dart';
import 'package:project/components/custombar.dart';
import 'package:project/components/productcard.dart';
import 'package:project/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:project/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  bool isLoading = true;
  List<Product> allProducts = [];

  final List<String> heroslides = [
    "assets/heroslides/slide1.png",
    "assets/heroslides/slide2.png",
    "assets/heroslides/slide3.png",
    "assets/heroslides/slide4.png",
  ];

  // Track actual internet status
  final ValueNotifier<bool> _isOnline = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    fetchProducts();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      if (currentPage < heroslides.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> fetchProducts() async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/products'); // adjust for your API
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final dataList = jsonResponse['data'] as List<dynamic>;

        setState(() {
          allProducts = dataList.map<Product>((json) {
            final p = Product.fromJson(json);
            print("${p.name} - ${p.category} - ${p.image}"); // debug output
            return Product(
              id: p.id,
              name: p.name,
              category: p.category.toLowerCase(),
              color: p.color,
              description: p.description,
              price: p.price,
              quantity: p.quantity,
              image: p.image.isNotEmpty
                  ? p.image
                  : 'assets/products/placeholder.webp', // fallback image
              isBestSeller: p.isBestSeller,
            );
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("API returned status ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Fetch products error: $e");
    }
  }

  // Helper to check if internet is actually reachable
  Future<bool> _checkActualInternet() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final connectivityService = Provider.of<ConnectivityService>(context);

    // Listen to connectivity changes and verify actual internet
    connectivityService.connectivityStream.listen((result) async {
      bool online = result != ConnectivityResult.none ? await _checkActualInternet() : false;
      _isOnline.value = online;
    });

    // Build lists for each category
    Map<String, List<Product>> categorizedProducts = {
      'Vintage Collection': allProducts
          .where((p) => p.category == 'vintage' && p.id.startsWith('L'))
          .toList(),
      'Cute Notebooks': allProducts
          .where((p) => p.category == 'cute' && p.id.startsWith('L'))
          .toList(),
      'Journals': allProducts
          .where((p) => p.category == 'journal' && p.id.startsWith('L'))
          .toList(),
      'Eastern Beauty': allProducts
          .where((p) => p.category == 'eastern' && p.id.startsWith('L'))
          .toList(),
      'Other': allProducts
          .where((p) => p.category == 'other' && p.id.startsWith('L'))
          .toList(),
    };

    return SafeArea(
      child: Scaffold(
        appBar: const CustomBar(),
        bottomNavigationBar: const Bottombar(),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero slider
                          SizedBox(
                            height: isLandscape ? 250 : 195,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: heroslides.length,
                              onPageChanged: (index) => currentPage = index,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.fromLTRB(10, 1, 10, 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(
                                    heroslides[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Build all category sections
                          for (var entry in categorizedProducts.entries)
                            _buildCategorySection(
                              entry.key,
                              entry.value,
                              isLandscape,
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

  Widget _buildCategorySection(
      String title, List<Product> products, bool isLandscape) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7dadc4),
              fontSize: 21,
              fontFamily: 'MontserratMedium',
            ),
          ),
        ),
        SizedBox(
          height: isLandscape ? 300 : 280,
          child: products.isEmpty
              ? const Center(child: Text("No products available"))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      ProductCard(product: products[index]),
                ),
        ),
      ],
    );
  }
}
