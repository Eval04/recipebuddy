import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      setState(() {
        username = doc['username'];
      });
    }
  }

  // Simulasi data resep
  final List<Map<String, dynamic>> recipes = [
    {
      "title": "Hash Brown",
      "duration": "20 Menit",
      "image": "assets/menu/Hash_Brown.png",
    },
    {
      "title": "Fluffy Pancake",
      "duration": "17 Menit",
      "image": "assets/menu/Fluffy_Pancake.png",
    },
    {
      "title": "Dimsum Ayam",
      "duration": "60 Menit",
      "image": "assets/menu/Dimsum_Ayam.png",
    },
    {
      "title": "Tamagoyaki",
      "duration": "10 Menit",
      "image": "assets/menu/Tamagoyaki.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFFD0B8AC);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${username ?? 'Loading...'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Resep Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Grid Resep
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children:
                      recipes.map((recipe) {
                        return Container(
                          decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: Image.asset(
                                  recipe['image'],
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image,
                                            size: 80,
                                          ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 6,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 4),
                                        Text(recipe['duration']),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.brown[900],
                                        ),
                                        onPressed: () {},
                                        child: const Text(
                                          'Simpan',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFAF5F2),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.menu, size: 28),
              CircleAvatar(
                backgroundColor: Color(0xFFD0B8AC),
                radius: 24,
                child: Icon(Icons.home, size: 28, color: Colors.black),
              ),
              Icon(Icons.search, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
