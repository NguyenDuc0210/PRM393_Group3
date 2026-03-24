
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/navigation_notifier.dart';
import 'settings_screen.dart';
import 'guides_screen.dart';
import 'tours_screen.dart';
import 'my_plans_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  // Đã xóa HomeScreen và ExploreScreen
  // Index 0: GuidesScreen
  // Index 1: ToursScreen
  // Index 2: MyPlansScreen
  // Index 3: Profile (SettingsScreen)
  static const List<Widget> _widgetOptions = <Widget>[
    GuidesScreen(),
    ToursScreen(),
    MyPlansScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        indicatorColor: const Color(0xFFC8F2C2),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Guides',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Tours',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'My Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
