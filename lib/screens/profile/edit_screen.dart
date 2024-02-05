import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'components/edit_item.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({Key? key}) : super(key: key);

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController addressController;
  late TextEditingController phoneNumberController;

  late String originalName;
  late String originalAge;
  late String originalAddress;
  late String originalPhoneNumber;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    ageController = TextEditingController();
    addressController = TextEditingController();
    phoneNumberController = TextEditingController();
    originalName = ''; // Initialize originalName
    originalAge = ''; // Initialize originalAge
    originalAddress = ''; // Initialize originalAddress
    originalPhoneNumber = ''; // Initialize originalPhoneNumber
    fetchAccountInfo();
  }

  bool _isInfoChanged() {
    // Compare current values with original values
    return nameController.text != originalName ||
        ageController.text != originalAge ||
        addressController.text != originalAddress ||
        phoneNumberController.text != originalPhoneNumber;
  }

  void updateAccountInfo() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('/k2n2/kfkktA9ggoZ652bCM091/account')
          .where('user', isEqualTo: user?.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Document exists, update the existing document
        DocumentSnapshot<Map<String, dynamic>> snapshot = querySnapshot.docs.first;
        String documentId = snapshot.id;

        await FirebaseFirestore.instance
            .collection('/k2n2/kfkktA9ggoZ652bCM091/account')
            .doc(documentId)
            .update({
          'name': nameController.text,
          'age': ageController.text,
          'address': addressController.text,
          'phoneNumber': phoneNumberController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thông tin đã được cập nhật thành công!'),
          ),
        );
      } else {
        // Document does not exist, create a new document
        await FirebaseFirestore.instance
            .collection('/k2n2/kfkktA9ggoZ652bCM091/account')
            .add({
          'user': user?.email,
          'name': nameController.text,
          'age': ageController.text,
          'address': addressController.text,
          'phoneNumber': phoneNumberController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thông tin đã được thêm vào database!'),
          ),
        );
      }
    } catch (e) {
      print('Error updating/adding account information: $e');
    }
  }

  void fetchAccountInfo() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('/k2n2/kfkktA9ggoZ652bCM091/account')
          .where('user', isEqualTo: user?.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = querySnapshot.docs.first;
        setState(() {
          nameController.text = snapshot['name'] ?? '';
          ageController.text = snapshot['age'] ?? '';
          addressController.text = snapshot['address'] ?? '';
          phoneNumberController.text = snapshot['phoneNumber'] ?? '';

          originalName = snapshot['name'] ?? '';
          originalAge = snapshot['age'] ?? '';
          originalAddress = snapshot['address'] ?? '';
          originalPhoneNumber = snapshot['phoneNumber'] ?? '';
        });
      } else {
        print('No documents found');
      }
    } catch (e) {
      print('Error fetching account information: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                // Call the update function when the checkmark is pressed
                updateAccountInfo();
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                fixedSize: Size(60, 50),
                elevation: 3,
              ),
              icon: Icon(Ionicons.checkmark, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Tên",
                widget: TextField(
                  controller: nameController,
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Tuổi",
                widget: TextField(
                  controller: ageController,
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Địa chỉ",
                widget: TextField(
                  controller: addressController,
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Số điện thoại",
                widget: TextField(
                  controller: phoneNumberController,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_isInfoChanged()) {
                    Navigator.pop(context);
                    updateAccountInfo();
                  } else {
                    // Show a message indicating that no changes were made
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Không có thay đổi để cập nhật!'),
                      ),
                    );
                  }
                },
                child: Text('Cập nhật thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
