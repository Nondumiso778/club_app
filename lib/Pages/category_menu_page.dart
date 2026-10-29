import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cart_service.dart';
import 'cart_page.dart';

class CategoryMenuPage extends StatelessWidget {
  final String category;

  CategoryMenuPage({super.key, required this.category});

  final CollectionReference menuRef =
      FirebaseFirestore.instance.collection('menu');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: Column(
        children: [
          // 🔙 BACK TO MENU BUTTON
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Menu"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // 📋 MENU ITEMS
          Expanded(
            child: StreamBuilder(
              stream:
                  menuRef.where('category', isEqualTo: category).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!.docs;

                if (items.isEmpty) {
                  return const Center(child: Text("No items found"));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index].data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text("E${item['price']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          CartService.addToCart(item);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${item['name']} added to cart"),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CartPage(),
            ),
          );
        },
        icon: const Icon(Icons.shopping_cart),
        label: Text(
          CartService.cart.isEmpty
              ? "Cart"
              : "Cart (${CartService.cart.length})",
        ),
      ),
    );
  }
}
