import 'package:flutter/material.dart';
import 'category_menu_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Breakfast',
        'category': 'Breakfast',
        'image': 'assets/images/breakfast.jpg',
      },
      {
        'title': 'Starters',
        'category': 'Starters',
        'image': 'assets/images/starter.jpg',
      },
      {
        'title': 'Main Course',
        'category': 'Main Course',
        'image': 'assets/images/maincourse.jpg',
      },
      {
        'title': 'Dessert',
        'category': 'Dessert',
        'image': 'assets/images/dessert.jpg',
      },
      {
        'title': 'Drinks',
        'category': 'Drinks',
        'image': 'assets/images/drinks.jpg',
      },
      {
        'title': 'Snacks',
        'category': 'Snacks',
        'image': 'assets/images/snacks.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Categories')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final item = categories[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryMenuPage(
                    category: item['category'] as String,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // 📸 IMAGE
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(item['image'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // 🌫️ OVERLAY
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),

                  // 📝 TITLE
                  Center(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
