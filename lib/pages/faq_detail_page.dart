import 'package:flutter/material.dart';

class FAQDetailPage extends StatelessWidget {
  const FAQDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faq = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(title: Text(faq["question"])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          faq["answer"],
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
