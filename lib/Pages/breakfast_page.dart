import 'package:flutter/material.dart';
//import '../cart_service.dart';
import 'package:club_app/Pages/orders_page.dart';
import 'package:club_app/Pages/menu_page.dart';

class BreakfastPage extends StatefulWidget {
  const BreakfastPage({super.key});

  @override
  State<BreakfastPage> createState() => _BreakfastPageState();
}

class _BreakfastPageState extends State<BreakfastPage> {
  final List<Map<String, dynamic>> items = const [
    {"name": "English Breakfast", "price": 115.0},
    {"name": "Pancakes", "price": 90.0},
    {"name": "Omelette", "price": 80.0},
    {"name": "Sausage & Eggs", "price": 100.0},
    {"name": "Toast & Coffee", "price": 70.0},
    {"name": "Full Breakfast Platter", "price": 125.0},
    {"name": "Boiled Eggs", "price": 60.0},
    {"name": "Waffles", "price": 95.0},
    {"name": "French Toast", "price": 85.0},
    {"name": "Breakfast Burrito", "price": 105.0},
  ];

  final Map<int, int> selectedQty = {};
  final Map<int, bool> selected = {};

  void _init(int index) {
    selectedQty[index] = selectedQty[index] ?? 1;
    selected[index] = selected[index] ?? false;
  }

  void _addItem(int index) {
    final item = items[index];
    final qty = selectedQty[index]!;

    // CartService.addItemWithQty(
    //  CartItem(
    //name: item['name'],
    // price: item['price'],
    //quantity: qty,
    //  ),
    //  qty,
    //);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item['name']} x$qty added to cart")),
    );
  }

  void _removeItem(int index) {
    setState(() {
      selected[index] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= APPBAR =================
      appBar: AppBar(
        title: const Text("Breakfast Menu"),
        backgroundColor: const Color.fromRGBO(0, 200, 83, 1),
        actions: [
          // 🍽 ADD MORE ITEMS
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuPage()),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 6),
                  Text(
                    "Add More Items",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          // 🛒 PROCEED TO ORDERS
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersPage()),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.arrow_forward),
                  SizedBox(width: 6),
                  Text(
                    "Proceed to Orders",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          _init(index);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.fastfood, color: Colors.green),
                  const SizedBox(width: 10),

                  // ================= NAME =================
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text("E ${item['price']}"),
                      ],
                    ),
                  ),

                  // ================= QUANTITY =================
                  SizedBox(
                    width: 90,
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedQty[index],
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(500, (i) => i + 1)
                          .map(
                            (qty) => DropdownMenuItem(
                              value: qty,
                              child: Text(qty.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedQty[index] = value!;
                        });

                        if (selected[index] == true) {
                          _addItem(index);
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ================= CHECKBOX =================
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: selected[index],
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            selected[index] = value!;
                          });

                          if (value == true) {
                            _addItem(index);
                          } else {
                            _removeItem(index);
                          }
                        },
                      ),
                      const Text(
                        "Add",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
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
