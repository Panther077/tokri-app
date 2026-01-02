import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/cart_provider.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final user = Provider.of<AppUser?>(context);

    // Redirect if cart empty or user null (though CheckButton handles this)
    if (cart.itemCount == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text("Cart is empty")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Total Amount",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${cart.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Payment Details",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Card Number",
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Expiry",
                        hintText: "MM/YY",
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "CVV"),
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Card Holder Name",
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please login to proceed"),
                              ),
                            );
                            return;
                          }
                          setState(() => _isLoading = true);
                          try {
                            // Simulate network delay
                            await Future.delayed(const Duration(seconds: 2));

                            await _processOrder(cart, user);

                            if (mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const OrderSuccessScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Order failed: $e")),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("PAY NOW"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processOrder(CartProvider cart, AppUser user) async {
    final orderItems = cart.items.values
        .map(
          (item) => {
            'productId': item.product.id,
            'name': item.product.name,
            'quantity': item.quantity,
            'price': item.product.price,
            'farmerId': item.product.farmerId,
          },
        )
        .toList();

    final farmerIds = cart.items.values
        .map((item) => item.product.farmerId)
        .toSet()
        .toList();

    final order = OrderModel(
      id: '', // Generated by firestore | Ensure OrderModel supports this
      customerId: user.uid,
      items: orderItems,
      totalAmount: cart.totalAmount,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    Map<String, dynamic> orderData = order.toMap();
    orderData['farmerIds'] = farmerIds;

    DocumentReference ref = await FirebaseFirestore.instance
        .collection('orders')
        .add(orderData);
    await ref.update({'id': ref.id});

    cart.clear();
  }
}
