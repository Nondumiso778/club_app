import 'package:flutter/material.dart';
import '../cart_service.dart';
import 'checkout_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    final cart = CartService.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                setState(() {
                  CartService.clearCart();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cart cleared")),
                );
              },
            )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🧾 CART ITEMS
            Expanded(
              child: cart.isEmpty
                  ? const Center(child: Text("Your cart is empty"))
                  : ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(item['name']),
                            subtitle: Text("E ${item['price']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: (item['quantity'] ?? 1) > 1
                                      ? () {
                                          setState(() {
                                            CartService.decreaseQuantity(index);
                                          });
                                        }
                                      : null,
                                ),
                                Text("${item['quantity'] ?? 1}"),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      CartService.increaseQuantity(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // 💰 TOTAL + CHECKOUT
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Total: E${CartService.getTotal().toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text("Proceed to Checkout"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: cart.isEmpty
                        ? null
                        : () {
                            if (CartService.getTotal() <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Invalid cart total"),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckoutPage(),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
