import 'package:flutter/material.dart';

class DrinksPage extends StatelessWidget {
  const DrinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
        10,
        (i) => {
              'name': 'Drink ${i + 1}',
              'price': 'E${15 + i * 3}',
            });

    return Scaffold(
      appBar: AppBar(title: const Text('Drinks')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return ListTile(
            leading: const Icon(Icons.local_drink),
            title: Text(item['name']!),
            subtitle: Text(item['price']!),
          );
        },
      ),
    );
  }
}
