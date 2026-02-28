import 'package:flutter/material.dart';

class CategoryProduct {
  final String caId;
  final String caName;
  final Icon icon;

  CategoryProduct({
    required this.caId,
    required this.caName,
    required this.icon,
  });

  static List<CategoryProduct> getCategories() {
    return [
      CategoryProduct(
          caId: 'ca01',
          caName: 'Fast Food',
          icon: const Icon(Icons.fastfood)),
      CategoryProduct(
          caId: 'ca02',
          caName: 'Drink',
          icon: const Icon(Icons.local_drink)),
      CategoryProduct(
          caId: 'ca03',
          caName: 'Shopping',
          icon: const Icon(Icons.add_shopping_cart)),
    ];
  }
}
