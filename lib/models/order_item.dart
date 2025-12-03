class OrderItem {
  final int id;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'],
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
