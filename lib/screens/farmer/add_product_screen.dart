import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  double price = 0.0;
  int quantity = 0;
  String imageUrl = ''; // Placeholder for now, would need Image Picker + Storage

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    final db = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: Text('Add New Product')),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
                onChanged: (val) => setState(() => name = val),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
                onChanged: (val) => setState(() => description = val),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter price' : null,
                onChanged: (val) => setState(() => price = double.tryParse(val) ?? 0.0),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter quantity' : null,
                onChanged: (val) => setState(() => quantity = int.tryParse(val) ?? 0),
              ),
              // Image URL Placeholder - In real app, use ImagePicker and Firebase Storage
              TextFormField(
                decoration: InputDecoration(labelText: 'Image URL'),
                onChanged: (val) => setState(() => imageUrl = val),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                child: Text('Add Product'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (user != null) {
                      Product newProduct = Product(
                        id: '', // Generated in service
                        farmerId: user.uid,
                        name: name,
                        description: description,
                        price: price,
                        quantity: quantity,
                        imageUrl: imageUrl,
                      );
                      
                      await db.addProduct(newProduct);
                      Navigator.pop(context);
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
