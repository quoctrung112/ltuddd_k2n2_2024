import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    required this.image,
    required this.title,
    required this.price,
    required this.press,
    required this.bgColor,required this.description,
    required this.id,
  }) : super(key: key);
  final String image, title, id,description;
  final VoidCallback press;
  final int price;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    Future<void> _addCart(int quantity, BuildContext context) async {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser!;

      // Reference to the Firestore collection for carts
      final cartRef = FirebaseFirestore.instance.collection('/k2n2/kfkktA9ggoZ652bCM091/cart');

      try {
        // Check if the product is already in the user's cart
        final existingCart = await cartRef
            .where('user', isEqualTo: user?.email)
            .where('id', isEqualTo: id)
            .get();

        if (existingCart.docs.isEmpty || existingCart.docs.first['status'] != '1') {
          // If the product is not in the cart, add it
          await cartRef.add({
            'user': user?.email,
            'urlImage': image,
            'description': description,
            'id': id,
            'price': price,
            'title': title,
            'count': quantity,
            'status': '1',
          });

          // Show a SnackBar notification when the product is added to the cart
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm sản phẩm vào giỏ hàng'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // If the product is already in the cart, update the quantity
          final cartDocId = existingCart.docs.first.id;
          final existingCount = existingCart.docs.first['count'] ?? 0;
          await cartRef.doc(cartDocId).update({'count': existingCount + quantity});

          // Show a SnackBar notification when the quantity is updated in the cart
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm sản phẩm vào giỏ hàng'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('Error adding image to Firestore: $e');

        // Show an error SnackBar notification if there's an issue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product to cart'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return GestureDetector(
      onTap: press,
      child: Container(
        width: 154,
        padding: const EdgeInsets.all(defaultPadding / 2),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadius)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.all(
                    Radius.circular(defaultBorderRadius)),
              ),
              child: Hero(
                tag: "product_${title}", // Unique tag for each product
                child: Image.network(
                  image,
                  fit: BoxFit.fill,
                  height: 155,
                ),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$$price",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 6),
                      blurRadius: 10,
                      color: const Color(0xFFB0B0B0).withOpacity(0.2),
                    ),
                  ]),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () {_addCart(1,context);},
                    child: Icon(Icons.add_shopping_cart),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
