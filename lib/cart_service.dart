class CartService {
  static final List<Map<String, dynamic>> cart = [];

  static void addToCart(Map<String, dynamic> item) {
    // if item already exists, increase quantity
    int index = cart.indexWhere((e) => e['name'] == item['name']);

    if (index != -1) {
      cart[index]['quantity'] = (cart[index]['quantity'] ?? 1) + 1;
    } else {
      cart.add({
        ...item,
        'quantity': item['quantity'] ?? 1,
      });
    }
  }

  static void removeFromCart(int index) {
    cart.removeAt(index);
  }

  static void clearCart() {
    cart.clear();
  }

  // ➕ INCREASE QUANTITY
  static void increaseQuantity(int index) {
    cart[index]['quantity'] = (cart[index]['quantity'] ?? 1) + 1;
  }

  // ➖ DECREASE QUANTITY
  static void decreaseQuantity(int index) {
    if ((cart[index]['quantity'] ?? 1) > 1) {
      cart[index]['quantity'] -= 1;
    }
  }

  // 💰 TOTAL
  static double getTotal() {
    double total = 0;

    for (var item in cart) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }

    return total;
  }
}
