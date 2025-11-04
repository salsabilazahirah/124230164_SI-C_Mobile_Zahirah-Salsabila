import 'cake_model.dart';

class CartItem {
  final Cake cake;
  int quantity;

  CartItem({required this.cake, this.quantity = 1});

  double get totalPrice => cake.price * quantity;

  Map<String, dynamic> toJson() {
    return {'cake': cake.toJson(), 'quantity': quantity};
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cake: Cake.fromJson(json['cake']),
      quantity: json['quantity'] ?? 1,
    );
  }
}
