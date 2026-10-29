import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class OrderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 Generate Order Reference
  static String generateOrderRef() {
    final now = DateTime.now();
    final random = Random().nextInt(9000) + 1000;

    return "ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random";
  }

  // ✅ SAVE ORDER (FIXED FOR MAP CART)
  static Future<String> saveOrder(
    List<Map<String, dynamic>> cart, {
    required String phone,
    String? orderRef,
  }) async {
    if (cart.isEmpty) {
      throw Exception("Cannot save empty order");
    }

    try {
      // Convert items
      List<Map<String, dynamic>> items = cart.map((item) {
        return {
          'name': item['name'],
          'price': item['price'],
          'quantity': item['quantity'] ?? 1,
          'total': (item['price'] ?? 0) * (item['quantity'] ?? 1),
        };
      }).toList();

      // Calculate total
      double totalAmount = 0;
      for (var item in cart) {
        totalAmount += (item['price'] ?? 0) * (item['quantity'] ?? 1);
      }

      final finalOrderRef = orderRef ?? generateOrderRef();

      await _db.collection('orders').add({
        'orderRef': finalOrderRef,
        'phone': phone,
        'status': 'pending',
        'items': items,
        'totalAmount': totalAmount,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return finalOrderRef;
    } catch (e) {
      throw Exception("Error saving order: $e");
    }
  }
}
