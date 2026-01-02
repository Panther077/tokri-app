import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';

class FarmerOrdersScreen extends StatelessWidget {
  const FarmerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    if (user == null) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: Text('Incoming Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('farmerIds', arrayContains: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders yet.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              final String orderId = orders[index].id;
              final List<dynamic> items = orderData['items'] ?? [];
              final String status = orderData['status'] ?? 'pending';

              // Filter items relevant to this farmer
              final myItems = items
                  .map((e) => e as Map<String, dynamic>)
                  .where((item) => item['farmerId'] == user.uid)
                  .toList();

              return Card(
                margin: EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text('Order #${orderId.substring(0, 5)}'),
                  subtitle: Text('Status: $status | Items: ${myItems.length}'),
                  children: [
                    ...myItems.map(
                      (item) => ListTile(
                        title: Text(item['name']),
                        trailing: Text(
                          '${item['quantity']} x ₹${item['price']}',
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (status == 'pending')
                          TextButton(
                            child: Text(
                              'Reject',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orderId)
                                  .update({'status': 'rejected'});
                            },
                          ),
                        if (status == 'pending')
                          TextButton(
                            child: Text(
                              'Accept',
                              style: TextStyle(color: Colors.green),
                            ),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orderId)
                                  .update({'status': 'accepted'});
                            },
                          ),
                        if (status == 'accepted')
                          TextButton(
                            child: Text('Mark Complete'),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orderId)
                                  .update({'status': 'completed'});
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
