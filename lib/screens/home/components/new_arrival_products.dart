import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/Product.dart';
import '../../details/details_screen.dart';
import 'product_card.dart';
import 'section_title.dart';

class NewArrivalProducts extends StatelessWidget {
  const NewArrivalProducts({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Sản phẩm',
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('/k2n2/kfkktA9ggoZ652bCM091/product')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            var documents = snapshot.data?.docs;

            return GridView.builder(
              shrinkWrap: true, // Add this line
              physics: NeverScrollableScrollPhysics(), // Add this line
              itemCount: documents?.length ?? 0,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.7,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                // Use ProductCard widget to display each product
                return Padding(
                  padding: const EdgeInsets.only(right: defaultPadding),
                  child: ProductCard(
                    title: documents?[index]['title'],
                    image: documents?[index]['urlImage'],
                    price: documents?[index]['price'],
                    id: documents![index].id,
                    description: documents[index]['description'],
                    bgColor: const Color(0xFFEFEFF2),
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            product: Product(
                              title: documents?[index]['title'],
                              image: documents?[index]['urlImage'],
                              price: documents?[index]['price'],
                              bgColor: const Color(0xFFEFEFF2),
                              description: documents?[index]['description'],
                              type: documents?[index]['type'],
                              id: documents?[index]['id'],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
