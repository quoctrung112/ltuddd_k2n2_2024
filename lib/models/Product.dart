import 'package:flutter/material.dart';

class Product {
  final String image, title, description, type,id;
  final int price;
  final Color bgColor;

  Product({
    required this.image,required this.id,
    required this.type,
    required this.description,
    required this.title,
    required this.price,
    this.bgColor = const Color(0xFFEFEFF2),
  });
}

