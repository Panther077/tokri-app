class OrderModel {
  final String id;
  final String customerId;
  final List<Map<String, dynamic>> items; // List of product IDs and quantities
  final double totalAmount;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'items': items,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
