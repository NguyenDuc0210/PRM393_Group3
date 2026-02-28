import 'package:flutter/material.dart';

class CategoryLocation {
  final String id;
  final String name;
  final IconData icon;

  CategoryLocation({
    required this.id,
    required this.name,
    required this.icon,
  });

  static List<CategoryLocation> getCategories() {
    return [
      CategoryLocation(id: 'asia', name: 'Châu Á', icon: Icons.public),
      CategoryLocation(id: 'europe', name: 'Châu Âu', icon: Icons.public),
      CategoryLocation(id: 'america', name: 'Châu Mỹ', icon: Icons.public),
      CategoryLocation(id: 'africa', name: 'Châu Phi', icon: Icons.public),
      CategoryLocation(id: 'oceania', name: 'Châu Đại Dương', icon: Icons.public),
    ];
  }
}
