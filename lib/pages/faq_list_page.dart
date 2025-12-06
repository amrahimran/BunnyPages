// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/components/bottombar.dart';
import 'faq_detail_page.dart';
import 'package:project/services/connectivity_banner.dart';

class FAQListPage extends StatefulWidget {
  const FAQListPage({super.key});

  @override
  State<FAQListPage> createState() => _FAQListPageState();
}

class _FAQListPageState extends State<FAQListPage> {
  List faqs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFAQs();
  }

  Future<void> loadFAQs() async {
    final url =
        "https://raw.githubusercontent.com/amrahimran/Flutter-JSON-File/refs/heads/main/faqs.json";

    final response = await http.get(Uri.parse(url));
    setState(() {
      faqs = json.decode(response.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs"),
        backgroundColor:
            isDarkMode ? const Color(0xFF2C2C3C) : const Color(0xFF7dadc4),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: isDarkMode
                    ? const Color(0xFF80CBC4)
                    : const Color(0xFF7dadc4),
              ),
            )
          : Column(
              children: [
                // ---------------------------------------------------
                // CONNECTIVITY BANNER ADDED HERE
                // ---------------------------------------------------
                const ConnectivityBanner(),
                // ---------------------------------------------------

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(faqs.length, (index) {
                          final item = faqs[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FAQDetailPage(faq: item),
                                  ),
                                );
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                    minHeight: 100),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 24),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF2C2C3C)
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.black26
                                          : Colors.grey.withOpacity(0.25),
                                      spreadRadius: 3,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item["question"],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily:
                                              'MontserratRegular',
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                      color: isDarkMode
                                          ? const Color(0xFF80CBC4)
                                          : const Color(0xFF7dadc4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const Bottombar(),
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF6F8FA),
    );
  }
}
