
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../notifiers/navigation_notifier.dart';
import '../notifiers/auth_notifier.dart';
import '../repositories/auth_repository.dart';
import '../models/user_role.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import '../models/location.dart';
import '../notifiers/location_notifier.dart';
import '../widgets/CustomWidget.dart';
import '../widgets/add_edit_location_form.dart';
import 'location_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _authToken;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token');
      _currentUser = FirebaseAuth.instance.currentUser;
    });
    ref.read(authNotifierProvider.notifier).refreshRole();
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsyncValue = ref.watch(locationNotifierProvider);
    final userRole = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: LocationMenuPopup(),
        title: const Text('Locations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          if (_authToken != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () {
                  ref.read(navigationIndexProvider.notifier).state = 5;
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: _currentUser?.photoURL != null
                        ? Image.network(
                            _currentUser!.photoURL!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.green),
                          )
                        : const Icon(Icons.person, color: Colors.green),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.login, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ).then((_) => _checkLoginStatus());
              },
            ),
        ],
      ),
      body: locationsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (locations) {
          if (locations.isEmpty) {
            return const Center(child: Text('No locations found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400.0,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 0.9,
            ),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return LocationCard(location: location);
            },
          );
        },
      ),
      floatingActionButton: userRole == UserRole.admin 
        ? FloatingActionButton(
            heroTag: 'home_fab',
            backgroundColor: Colors.green,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Add New Location'),
                    content: const AddEditLocationForm(),
                  );
                },
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
    );
  }
}

class LocationCard extends StatelessWidget {
  final Location location;
  const LocationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LocationPage(locationId: location.id)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                location.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(location.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(location.address, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
