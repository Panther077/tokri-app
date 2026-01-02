import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

import 'add_product_screen.dart';
import 'orders_screen.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';

class FarmerHome extends StatelessWidget {
  const FarmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    final db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FarmerOrdersScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: user == null 
          ? Center(child: CircularProgressIndicator()) 
          : StreamBuilder<List<Product>>(
              stream: db.getFarmerProducts(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No products added yet. Start selling!"));
                }
                final products = snapshot.data!;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: product.imageUrl.isNotEmpty 
                            ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.shopping_basket),
                        title: Text(product.name),
                        subtitle: Text('Qty: ${product.quantity} | ₹${product.price}'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
