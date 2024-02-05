import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../bill/bill_screen.dart';

class CheckoutCard extends StatefulWidget {
  CheckoutCard({
    Key? key,
    required this.totalCost,
  }) : super(key: key);

  num totalCost;

  @override
  _CheckoutCardState createState() => _CheckoutCardState();
}

class _CheckoutCardState extends State<CheckoutCard> {
  bool get isCartEmpty => widget.totalCost == 0;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -15),
            blurRadius: 20,
            color: const Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (isCartEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Bạn chưa có sản phẩm nào trong giỏ hàng."),
              ),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: "Tổng:\n",
                      children: [
                        TextSpan(
                          text: "\$${widget.totalCost}",
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCartEmpty ? null : _checkout,
                    child: const Text("Thanh toán"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _checkout() {
    _updateStatusInFirebase();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BillScreen(),
      ),
    );
  }

  void _updateStatusInFirebase() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final collectionReference = FirebaseFirestore.instance.collection('/k2n2/kfkktA9ggoZ652bCM091/cart');

      await collectionReference
          .where('user', isEqualTo: user.email)
          .where('status', isEqualTo: '1')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          final int count = doc['count'];
          final int price = doc['price'];

          collectionReference.doc(doc.id).update({
            'status': '2',
            'pricelast': count * price,
          });
        });
      });
    }
  }
}