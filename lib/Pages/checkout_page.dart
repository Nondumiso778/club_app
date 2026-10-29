import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../cart_service.dart';
import '../order_service.dart';
import 'package:club_app/pages/home_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = CartService.cart;

    return WillPopScope(
      onWillPop: () async => false, // 🚫 disables back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Checkout"),
          automaticallyImplyLeading: false, // 🚫 removes back arrow
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TITLE =================
                  const Text(
                    "Order Summary",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= PHONE INPUT =================
                  const Text(
                    "Enter your phone number:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      hintText: "e.g. 76123456",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= CART ITEMS =================
                  cart.isEmpty
                      ? const Center(child: Text("Your cart is empty"))
                      : Column(
                          children: cart.map((item) {
                            return Card(
                              child: ListTile(
                                title: Text(item['name']),
                                subtitle: Text(
                                  "E${item['price']} x ${item['quantity'] ?? 1}",
                                ),
                                trailing: Text(
                                  "E${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                  const Divider(height: 30),

                  // ================= TOTAL =================
                  Text(
                    "Total: E${CartService.getTotal().toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _processOrder,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Confirm & Pay"),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= PROCESS ORDER =================
  Future<void> _processOrder() async {
    final cart = CartService.cart;
    final phone = phoneController.text.trim();

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your cart is empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your phone number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final orderRef = OrderService.generateOrderRef();

      final savedRef = await OrderService.saveOrder(
        cart,
        phone: phone,
        orderRef: orderRef,
      );

      // copy to clipboard
      await Clipboard.setData(ClipboardData(text: savedRef));

      CartService.clearCart();

      setState(() => isLoading = false);

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Order Successful"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Your order has been placed successfully!",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              SelectableText(
                savedRef,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Reference copied to clipboard",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: savedRef),
                );
              },
              child: const Text("Copy"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog

                Future.delayed(const Duration(milliseconds: 200), () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => HomePage()),
                    (route) => false,
                  );
                });
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to place order: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
