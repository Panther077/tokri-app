import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add Product
  Future<void> addProduct(Product product) async {
    // We generate a new doc ref to get the ID, then set data
    DocumentReference docRef = _db.collection('products').doc();
    // We need to store the ID in the doc as well, or just rely on doc.id. 
    // The model has 'id', so let's update it.
    
    Map<String, dynamic> data = product.toMap();
    data['id'] = docRef.id; // Ensure ID matches
    
    await docRef.set(data);
  }

  // Get Products for a specific farmer
  Stream<List<Product>> getFarmerProducts(String farmerId) {
    return _db
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get All Products (for Customer)
  Stream<List<Product>> getAllProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList());
  }
}
