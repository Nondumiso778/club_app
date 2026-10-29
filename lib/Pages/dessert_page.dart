import 'package:flutter/material.dart';

class DessertPage extends StatelessWidget {
  const DessertPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
        10,
        (i) => {
              'name': 'Dessert ${i + 1}',
              'price': 'E${25 + i * 5}',
            });

    return Scaffold(
      appBar: AppBar(title: const Text('Dessert')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return ListTile(
            leading: const Icon(Icons.cake),
            title: Text(item['name']!),
            subtitle: Text(item['price']!),
          );
        },
      ),
    );
  }
}
