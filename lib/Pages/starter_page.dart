import 'package:flutter/material.dart';

class StarterPage extends StatelessWidget {
  const StarterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
        10,
        (i) => {
              'name': 'Starter Item ${i + 1}',
              'price': 'E${40 + i * 5}',
            });

    return Scaffold(
      appBar: AppBar(title: const Text('Starters')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return ListTile(
            leading: const Icon(Icons.local_dining),
            title: Text(item['name']!),
            subtitle: Text(item['price']!),
          );
        },
      ),
    );
  }
}
