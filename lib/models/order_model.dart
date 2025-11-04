import 'cart_item.dart';

class Order {
  final int id;
  final List<CartItem> items;
  final DateTime orderDate;
  final double totalAmount;
  final int totalItems;
  final String status;
  final String? paymentMethod;
  final String? deliveryAddress;

  Order({
    required this.id,
    required this.items,
    required this.orderDate,
    required this.totalAmount,
    required this.totalItems,
    required this.status,
    this.paymentMethod,
    this.deliveryAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      orderDate: DateTime.parse(json['orderDate'] ?? json['order_date']),
      totalAmount:
          (json['totalAmount'] ?? json['total_amount'])?.toDouble() ?? 0.0,
      totalItems: (json['totalItems'] ?? json['total_items']) ?? 0,
      status: json['status'] ?? 'completed',
      paymentMethod: json['paymentMethod'],
      deliveryAddress: json['deliveryAddress'],
    );
  }
}
