import 'package:flutter/material.dart';
import 'package:project/pages/details.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsPage(productId: product.id)
        ),
      );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 6, 12),
        width: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center, // Center everything horizontally
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                product.image,
                height: 190,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, size: 50),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center, // Center text
              style: const TextStyle(
                fontFamily: 'MontserratRegular',
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Rs. ${product.price}",
              textAlign: TextAlign.center, // Center text
              style: const TextStyle(
                fontFamily: 'MontserratRegular',
                fontSize: 13.5,
                color: Color.fromARGB(255, 158, 152, 152),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
