import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/CategoryLocation.dart';
import '../notifiers/location_notifier.dart';

class LocationMenuPopup extends ConsumerWidget {
  final List<CategoryLocation> listCategory = CategoryLocation.getCategories();

  LocationMenuPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<CategoryLocation?>(
      icon: const Icon(Icons.menu),
      tooltip: "Select a Continent",
      onSelected: (CategoryLocation? value) {
        final currentContinent = ref.read(selectedContinentProvider);
        if (currentContinent == value?.id) {
          ref.read(locationNotifierProvider.notifier).filterByContinent(null);
        } else {
          ref.read(locationNotifierProvider.notifier).filterByContinent(value?.id);
        }
      },
      itemBuilder: (BuildContext context) {
        return listCategory.map((CategoryLocation item) {
          return PopupMenuItem<CategoryLocation>(
            value: item,
            child: Row(
              children: <Widget>[
                Icon(item.icon),
                const SizedBox(width: 8),
                Text(item.name),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
