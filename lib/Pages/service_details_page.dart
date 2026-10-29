import 'dart:ui';
import 'package:flutter/material.dart';

class ServiceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ServiceDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? ''),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Background image
          if (data['imageUrl'] != null)
            SizedBox.expand(
              child: Image.network(
                data['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),

          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  data['description'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: () {
                      // 🔥 future booking
                    },
                    child: const Text("Book Now"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}