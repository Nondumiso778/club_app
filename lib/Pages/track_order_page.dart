import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackOrderPage extends StatefulWidget {
  final VoidCallback onBack;

  const TrackOrderPage({
    super.key,
    required this.onBack,
  });

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  final TextEditingController _searchController = TextEditingController();

  String? _query;
  String? _error;

  void _trackOrder() {
    final input = _searchController.text.trim();

    if (input.isEmpty) {
      setState(() {
        _error = "Enter phone number or order reference";
        _query = null;
      });
      return;
    }

    setState(() {
      _query = input;
      _error = null;
    });
  }

  Future<DocumentSnapshot?> _findOrder() async {
    // 1️⃣ search in orders
    final ordersByPhone = await FirebaseFirestore.instance
        .collection('orders')
        .where('phone', isEqualTo: _query)
        .get();

    final ordersByRef = await FirebaseFirestore.instance
        .collection('orders')
        .where('orderRef', isEqualTo: _query)
        .get();

    // 2️⃣ search in come_and_get
    final readyByPhone = await FirebaseFirestore.instance
        .collection('come_and_get')
        .where('phone', isEqualTo: _query)
        .get();

    final readyByRef = await FirebaseFirestore.instance
        .collection('come_and_get')
        .where('orderRef', isEqualTo: _query)
        .get();

    // Combine results
    final all = [
      ...ordersByPhone.docs,
      ...ordersByRef.docs,
      ...readyByPhone.docs,
      ...readyByRef.docs,
    ];

    if (all.isEmpty) return null;

    // Prefer latest order (if timestamp exists)
    all.sort((a, b) {
      final aTime = a['createdAt'];
      final bTime = b['createdAt'];

      if (aTime == null || bTime == null) return 0;

      return (bTime as Timestamp).compareTo(aTime as Timestamp);
    });

    return all.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Your Order"),
        backgroundColor: const Color.fromRGBO(0, 200, 83, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Phone or Order Ref",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _trackOrder,
              child: const Text("Track Order"),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_query != null)
              Expanded(
                child: FutureBuilder<DocumentSnapshot?>(
                  future: _findOrder(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data == null) {
                      return const Center(child: Text("No order found"));
                    }

                    final doc = snapshot.data!;
                    final data = doc.data() as Map<String, dynamic>;

                    final status = data['status'] ?? "Pending";
                    final items = data['items'] ?? [];

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order #${data['orderRef'] ?? doc.id}",
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _statusColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text("Items",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          ...items.map((item) {
                            return Text(
                              "${item['name']} x ${item['quantity']} - E${item['total']}",
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "In Progress":
        return Colors.orange;
      case "Ready":
        return Colors.green;
      case "Delivered":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
