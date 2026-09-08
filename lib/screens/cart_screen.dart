import 'package:flutter/material.dart';

import '../models/shoe_product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  final ShoeProduct product;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
}

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.cartItems,
    required this.total,
    required this.onCheckout,
    required this.onContinueShopping,
  });

  final List<CartItem> cartItems;
  final double total;
  final VoidCallback onCheckout;
  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your cart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            if (cartItems.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your cart is empty.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: onContinueShopping,
                        child: const Text('Continue Shopping'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item in cartItems)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name),
                                    Text('Qty: ${item.quantity}', style: const TextStyle(fontSize: 12)),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: item.onDecrease,
                                          icon: const Icon(Icons.remove),
                                          tooltip: 'Decrease quantity',
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        const SizedBox(width: 4),
                                        Text('${item.quantity}'),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          onPressed: item.onIncrease,
                                          icon: const Icon(Icons.add),
                                          tooltip: 'Increase quantity',
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Subtotal', style: TextStyle(fontSize: 12)),
                                  Text('₱${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                          Text('₱${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCheckout,
                  child: const Text('Proceed to Checkout'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CheckoutConfirmationScreen extends StatelessWidget {
  const CheckoutConfirmationScreen({
    super.key,
    required this.total,
    required this.itemCount,
    required this.onBackHome,
  });

  final double total;
  final int itemCount;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Checkout confirmed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text('Items: $itemCount'),
                  const SizedBox(height: 8),
                  Text('Total: ₱${total.toStringAsFixed(2)}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: onBackHome,
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
