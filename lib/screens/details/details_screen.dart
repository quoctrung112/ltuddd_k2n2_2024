import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Trendique_TLU/screens/cart/cart_screen.dart';
import '../../components/rounder_icon.dart';
import '../../constants.dart';
import '../../models/Product.dart';
import 'components/color_dot.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({Key? key, required this.product}) : super(key: key);

  final Product product;



  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int quantity = 1;
  Color selectedColor = Color(0xFF141B4A); // Default selected color
  Future<void> _addCart(quantity) async {
    final user = FirebaseAuth.instance.currentUser!;
    final cartRef = FirebaseFirestore.instance.collection('/k2n2/kfkktA9ggoZ652bCM091/cart');

    try {
      // Kiểm tra xem đã có cart của người dùng với "id" đã cho hay chưa
      final existingCart = await cartRef
          .where('user', isEqualTo: user?.email)
          .where('id', isEqualTo: widget.product.id)
          .get();

      if (existingCart.docs.isEmpty) {
        await cartRef.add({
          'user': user?.email,
          'urlImage': widget.product.image,
          'description': widget.product.description,
          'id': widget.product.id,
          'price': widget.product.price,
          'title': widget.product.title,
          'count': quantity,
          'status':'1'

        });

        print('Image added to Firestore with URL: ${widget.product.image}');
      } else if(existingCart.docs.first['status'] != '1'){
        await cartRef.add({
          'user': user?.email,
          'urlImage': widget.product.image,
          'description': widget.product.description,
          'id': widget.product.id,
          'price': widget.product.price,
          'title': widget.product.title,
          'count': quantity,
          'status':'1'

        });

        print('Image added to Firestore with URL: ${widget.product.image}');
      }else {
        final cartDocId = existingCart.docs.first.id;
        final existingCount = existingCart.docs.first['count'] ?? 0;
        await cartRef.doc(cartDocId).update({'count': existingCount + quantity});

        print('Increased count for the product in the cart');
      }
    } catch (e) {
      print('Error adding image to Firestore: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.product.bgColor,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {},
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: SvgPicture.asset(
                "assets/icons/Heart.svg",
                height: 20,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Hero(
            tag: "product_${widget.product.title}",
            child: Image.network(
              widget.product.image,
              height: MediaQuery.of(context).size.height * 0.4,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: defaultPadding * 1.5),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(defaultPadding,
                  defaultPadding * 2, defaultPadding, defaultPadding),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(defaultBorderRadius * 3),
                  topRight: Radius.circular(defaultBorderRadius * 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.title,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Text(
                        "\$" + widget.product.price.toString(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                    child: Text(
                      widget.product.description,
                    ),
                  ),
                  Text(
                    "Colors",
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ColorDot(
                            color: Color(0xFFBEE8EA),
                            isActive: selectedColor == Color(0xFFBEE8EA),
                            onTap: () {
                              setState(() {
                                selectedColor = Color(0xFFBEE8EA);
                              });
                            },
                          ),
                          ColorDot(
                            color: Color(0xFF141B4A),
                            isActive: selectedColor == Color(0xFF141B4A),
                            onTap: () {
                              setState(() {
                                selectedColor = Color(0xFF141B4A);
                              });
                            },
                          ),
                          ColorDot(
                            color: Color(0xFFF4E5C3),
                            isActive: selectedColor == Color(0xFFF4E5C3),
                            onTap: () {
                              setState(() {
                                selectedColor = Color(0xFFF4E5C3);
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          RoundedIconBtn(
                            icon: Icons.remove,
                            press: () {
                              setState(() {
                                if (quantity > 1) {
                                  quantity--;
                                }
                              });
                            },
                            showShadow: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              quantity.toString(),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          RoundedIconBtn(
                            icon: Icons.add,
                            press: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            showShadow: true,
                          ),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: EdgeInsets.all(defaultPadding),
        child: ElevatedButton(
          onPressed: () {
            _addCart(quantity);
            Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>CartScreen()
            ),
          );
          },
          style: ElevatedButton.styleFrom(
            primary: primaryColor,
            shape: const StadiumBorder(),
          ),
          child: const Text("Thêm vào giỏ hàng"),
        ),
      ),
    );
  }
}
