import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'manage_recipe.dart';
import 'manage_user.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [ManageRecipePage(), ManageUserPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.brown),
              child: Center(
                child: Text(
                  'Admin Panel',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFEEFD3),
        selectedItemColor: Colors.brown,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Manajemen Resep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Manajemen User',
          ),
        ],
      ),
    );
  }
}
