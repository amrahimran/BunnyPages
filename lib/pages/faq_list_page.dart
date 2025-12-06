import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final url = "https://raw.githubusercontent.com/amrahimran/Flutter-JSON-File/refs/heads/main/faq.json";

    final response = await http.get(Uri.parse(url));
    setState(() {
      faqs = json.decode(response.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQs")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final item = faqs[index];
                return Card(
                  child: ListTile(
                    title: Text(item["question"]),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/faqdetail',
                        arguments: item,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
