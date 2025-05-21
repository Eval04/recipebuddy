import 'package:flutter/material.dart';
import 'package:RecipeBuddy/pages/home_page.dart';
import 'package:RecipeBuddy/pages/cari_resep.dart';

class CustomBottomNavbar extends StatelessWidget {
  final String currentPage;
  final VoidCallback? onMenuPressed;

  const CustomBottomNavbar({
    super.key,
    required this.currentPage,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor(String page) {
      return currentPage == page ? Colors.brown : Colors.grey[700]!;
    }

    return BottomAppBar(
      color: const Color(0xFFFAF5F2),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.menu, size: 28, color: getColor('menu')),
              onPressed: onMenuPressed,
            ),
            IconButton(
              icon: Icon(Icons.home, size: 28, color: getColor('home')),
              onPressed: () {
                if (currentPage != 'home') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.search, size: 28, color: getColor('search')),
              onPressed: () {
                if (currentPage != 'search') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchRecipeScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
