import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:Trendique_TLU/constants.dart';

class BillScreenadm extends StatefulWidget {
  const BillScreenadm({Key? key}) : super(key: key);

  @override
  State<BillScreenadm> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreenadm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xử lý đơn hàng", style: TextStyle(color: Colors.black)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('/k2n2/kfkktA9ggoZ652bCM091/cart')
            .where('status', isEqualTo: '2')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          List<QueryDocumentSnapshot> billItems = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              itemCount: billItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) =>
                  BillItemCard(billItem: BillItem.fromDocumentSnapshot(billItems[index])),
            ),
          );
        },
      ),
    );
  }
}

class BillItemCard extends StatelessWidget {
  final BillItem billItem;

  BillItemCard({required this.billItem});

  @override
  Widget build(BuildContext context) {
    String statusText = '';

    switch (billItem.status) {
      case '1':
        return Container();
      case '2':
        statusText = 'Chờ xử lý';
        break;
      case '3':
        statusText = 'Đã hoàn thành đơn hàng';
        break;
      default:
        statusText = 'Đơn hàng đã bị hủy';
    }

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
                        billItem.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        billItem.description,
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
                        'Status: $statusText',
                        style: TextStyle(color: primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tổng: \$${billItem.pricelast}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Số lượng: ${billItem.count}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateOrderStatus('3');
                  },
                  child: const Text('Hoàn thành'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateOrderStatus('4');
                  },
                  child: const Text('Hủy đơn hàng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateOrderStatus(String newStatus) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('/k2n2/kfkktA9ggoZ652bCM091/cart')
          .doc(billItem.collectID)
          .get();

      if (documentSnapshot.exists) {
        // The document exists, update its status
        await FirebaseFirestore.instance
            .collection('/k2n2/kfkktA9ggoZ652bCM091/cart')
            .doc(billItem.collectID)
            .update({'status': newStatus});
      } else {
        // The document doesn't exist, handle accordingly
        print('Document not found: ${billItem.collectID}');
      }
    } catch (error) {
      // Handle the error (e.g., print or log it)
      print('Error updating status: $error');
    }
  }

}

class BillItem {
  final String productId;
  final String collectID;
  final String title;
  final String description;
  final int pricelast;
  final int count;
  final String imageUrl;
  final String status;

  BillItem({
    required this.productId,
    required this.collectID,
    required this.title,
    required this.description,
    required this.pricelast,
    required this.count,
    required this.imageUrl,
    required this.status,
  });

  factory BillItem.fromDocumentSnapshot(QueryDocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return BillItem(
      productId: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      pricelast: data['pricelast'] ?? 0,
      count: data['count'] ?? 0,
      imageUrl: data['urlImage'] ?? '',
      status: data['status'] ?? '',
      collectID: documentSnapshot.id, // Use documentSnapshot.id to get the collection ID
    );
  }
}