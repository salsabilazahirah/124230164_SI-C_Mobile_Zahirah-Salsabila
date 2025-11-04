import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tokokue.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType UNIQUE,
        email $textType UNIQUE,
        password_hash $textType,
        full_name $textTypeNull,
        phone $textTypeNull,
        profile_picture $textTypeNull,
        created_at $textType,
        last_login $textTypeNull
      )
    ''');

    // Tabel orders
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        items TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        totalItems INTEGER NOT NULL,
        orderDate TEXT NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT,
        deliveryAddress TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
    // Create default admin user
    await db.insert('users', {
      'username': 'admin',
      'email': 'admin@tokokue.com',
      'password_hash': _hashPassword('admin123'),
      'full_name': 'Admin',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Create demo user
    await db.insert('users', {
      'username': 'bila',
      'email': 'bila@tokokue.com',
      'password_hash': _hashPassword('bila123'),
      'full_name': 'Bila',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  String _hashPassword(String password) {
    // Simple hash for demo - in production use crypto package properly
    return password.split('').reversed.join() + '_hashed';
  }

  // Create (Register)
  Future<User?> createUser(User user) async {
    try {
      final db = await database;
      final id = await db.insert('users', user.toMap());
      return user.copyWith(id: id);
    } catch (e) {
      return null; // User already exists or error
    }
  }

  // Read single user
  Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Read user by username
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Read user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Read all users
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'created_at DESC');
    return result.map((map) => User.fromMap(map)).toList();
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Update last login
  Future<int> updateLastLogin(int userId) async {
    final db = await database;
    return db.update(
      'users',
      {'last_login': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Verify login
  Future<User?> verifyLogin(String usernameOrEmail, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);

    final maps = await db.query(
      'users',
      where: '(username = ? OR email = ?) AND password_hash = ?',
      whereArgs: [usernameOrEmail, usernameOrEmail, hashedPassword],
    );

    if (maps.isNotEmpty) {
      final user = User.fromMap(maps.first);
      // Update last login
      await updateLastLogin(user.id!);
      return user;
    }
    return null;
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }

  // CRUD Order
  // Tambahkan import json
  // import 'dart:convert';
  Future<int> insertOrder(Order order, int userId) async {
    final db = await database;
    return await db.insert('orders', {
      'user_id': userId,
      'items': jsonEncode(order.items.map((item) => item.toJson()).toList()),
      'totalAmount': order.totalAmount,
      'totalItems': order.totalItems,
      'orderDate': order.orderDate.toIso8601String(),
      'status': order.status,
      'paymentMethod': order.paymentMethod,
      'deliveryAddress': order.deliveryAddress,
    });
  }

  Future<List<Order>> getOrdersByUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'orderDate DESC',
    );
    return result.map((map) {
      final itemsJson = map['items'] as String;
      final itemsList = (itemsJson.isNotEmpty)
          ? (jsonDecode(itemsJson) as List<dynamic>)
          : <dynamic>[];
      return Order(
        id: map['id'] as int,
        items: itemsList.map((item) => CartItem.fromJson(item)).toList(),
        orderDate: DateTime.parse(map['orderDate'] as String),
        totalAmount: (map['totalAmount'] as num).toDouble(),
        totalItems: map['totalItems'] as int,
        status: map['status'] as String,
        paymentMethod: map['paymentMethod'] as String?,
        deliveryAddress: map['deliveryAddress'] as String?,
      );
    }).toList();
  }

  Future<int> updateOrder(Order order) async {
    final db = await database;
    return await db.update(
      'orders',
      {
        'items': jsonEncode(order.items.map((item) => item.toJson()).toList()),
        'totalAmount': order.totalAmount,
        'totalItems': order.totalItems,
        'orderDate': order.orderDate.toIso8601String(),
        'status': order.status,
        'paymentMethod': order.paymentMethod,
        'deliveryAddress': order.deliveryAddress,
      },
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(int orderId) async {
    final db = await database;
    return await db.delete('orders', where: 'id = ?', whereArgs: [orderId]);
  }
}
