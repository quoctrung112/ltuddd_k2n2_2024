import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/components/bill_card_adm.dart';

class CancelledOrdersScreen extends StatefulWidget {
  const CancelledOrdersScreen({Key? key}) : super(key: key);

  @override
  _CancelledOrdersScreenState createState() => _CancelledOrdersScreenState();
}

class _CancelledOrdersScreenState extends State<CancelledOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cancelled Orders", style: TextStyle(color: Colors.black)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('/k2n2/kfkktA9ggoZ652bCM091/cart')
            .where('status', isEqualTo: '4')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          List<QueryDocumentSnapshot> cancelledOrders = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              itemCount: cancelledOrders.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) =>
                  CancelledOrderCard(order: BillItem.fromDocumentSnapshot(cancelledOrders[index])),
            ),
          );
        },
      ),
    );
  }
}

class CancelledOrderCard extends StatelessWidget {
  final BillItem order;

  CancelledOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.description,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Status: ${order.status}',
                        // Customize the style based on your needs
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tổng: \$${order.pricelast}',
                        // Customize the style based on your needs
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Số lượng: ${order.count}',
                        // Customize the style based on your needs
                      ),
                    ],
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
