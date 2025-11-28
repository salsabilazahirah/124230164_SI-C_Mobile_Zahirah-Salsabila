import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/database_helper.dart';
import '../models/cart_item.dart';
import '../models/cake_model.dart';
import '../services/notification_service.dart';
import '../models/order_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  final NotificationService _notificationService = NotificationService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Orders
  List<Order> _orders = [];
  List<Order> get orders => _orders;
  int? _userId;
  set userId(int? id) {
    _userId = id;
    loadOrders();
  }

  Future<void> removeOrder(int orderId) async {
    if (_userId == null) return;
    await _dbHelper.deleteOrder(orderId);
    await loadOrders();
    notifyListeners();
  }

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart');
      if (cartData != null) {
        final List<dynamic> decoded = json.decode(cartData);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> loadOrders() async {
    if (_userId == null) return;
    try {
      _orders = await _dbHelper.getOrdersByUser(_userId!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart', encoded);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  void addItem(Cake cake, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.cake.id == cake.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(cake: cake));
    }

    _notificationService.showCartNotification(
      cake.title,
      existingIndex >= 0 ? _items[existingIndex].quantity : 1,
    );

    _saveCart();
    notifyListeners();
  }

  void removeItem(int cakeId) {
    final removedItem = _items.firstWhere((item) => item.cake.id == cakeId);
    _items.removeWhere((item) => item.cake.id == cakeId);

    // Show notification for item removal
    _notificationService.showItemRemovedNotification(removedItem.cake.title);

    _saveCart();
    notifyListeners();
  }

  void updateQuantity(int cakeId, int quantity) {
    final index = _items.indexWhere((item) => item.cake.id == cakeId);
    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(cakeId);
      } else {
        final oldQuantity = _items[index].quantity;
        _items[index].quantity = quantity;

        // Show notification for quantity update
        if (quantity > oldQuantity) {
          _notificationService.showCartUpdateNotification(
            _items[index].cake.title,
            quantity,
            'increase',
          );
        } else if (quantity < oldQuantity) {
          _notificationService.showCartUpdateNotification(
            _items[index].cake.title,
            quantity,
            'decrease',
          );
        }

        _saveCart();
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  Future<Order?> checkout(
    int? userId, [
    String? timezone,
    String paymentMethod = '',
    String deliveryAddress = '',
  ]) async {
    Order? createdOrder;

    if (_items.isNotEmpty && userId != null) {
      final order = Order(
        id: 0, // id akan diisi autoincrement oleh database
        items: List<CartItem>.from(_items),
        totalAmount: totalPrice,
        totalItems: itemCount,
        orderDate: DateTime.now(),
        status: 'completed',
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
      );

      // Insert order dan dapatkan ID yang baru
      final newOrderId = await _dbHelper.insertOrder(order, userId);

      // Buat order dengan ID yang benar
      createdOrder = Order(
        id: newOrderId,
        items: order.items,
        totalAmount: order.totalAmount,
        totalItems: order.totalItems,
        orderDate: order.orderDate,
        status: order.status,
        paymentMethod: order.paymentMethod,
        deliveryAddress: order.deliveryAddress,
      );

      await loadOrders();
      debugPrint(
        'Order saved: ${createdOrder.totalItems} items, total: ${createdOrder.totalAmount}, ID: ${createdOrder.id}',
      );
    }

    await _notificationService.showOrderNotification(
      totalPrice,
      itemCount,
      timezone,
    );
    clearCart();

    return createdOrder;
  }
}