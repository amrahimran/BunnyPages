import 'package:flutter/material.dart';
import 'package:project/components/bottombar.dart';
import 'package:project/services/connectivity_banner.dart';

class FAQDetailPage extends StatelessWidget {
  final Map faq;
  const FAQDetailPage({super.key, required this.faq});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ Answer"),
        backgroundColor: const Color(0xFF7dadc4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const ConnectivityBanner(),

            const SizedBox(height: 20),

            Text(
              faq["question"] ?? "No question",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'MontserratSemibold',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              faq["answer"] ?? "No answer available",
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'MontserratRegular',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Bottombar(),
    );
  }
}
