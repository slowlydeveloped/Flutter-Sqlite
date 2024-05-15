import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../presentation/blocs/add_to_cart/add_to_cart_bloc.dart';
import '../models/cart_model.dart';
import '../models/user_model.dart';

class DataBaseHelper {
  final databaseName = "shopper.db";
  String users =
      "create table users (userId INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, userName TEXT UNIQUE, password TEXT)";
  String cart =
      "create table cart (id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, userId INTEGER , product TEXT NOT NULL, description TEXT NOT NULL, amount REAL, FOREIGN KEY (userId) REFERENCES users(userId))";
  String addCart =
      "create table addCart(id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, userId INTEGER , itemId INTEGER, product TEXT NOT NULL, description TEXT NOT NULL, amount REAL, quantity INTEGER, isSelected INTEGER, FOREIGN KEY (userId) REFERENCES users(userId))";
  String orderHistory =
      "CREATE TABLE orderHistory (orderId TEXT, userId INTEGER , productId INTEGER, productName TEXT NOT NULL, productDescription TEXT NOT NULL, quantity INTEGER, amount REAL, tax REAL, totalAmount REAL, finalAmount REAL, FOREIGN KEY (userId) REFERENCES users(userId))";

  // Create and initialize the database
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 4, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(cart);
      await db.execute(addCart);
      await db.execute(orderHistory);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 3) {
        await db.execute(cart);
        await db.execute(addCart);
        await db.execute(orderHistory);
      }
    });
  }

  // User login
  Future<bool> login(Users user) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.rawQuery(
        "SELECT * FROM users WHERE userName = ? AND password = ?",
        [user.userName, user.password]);
    return result.isNotEmpty;
  }

  // User signup
  Future<int> signup(Users user) async {
    final Database db = await initDB();
    return db.insert('users', user.toMap());
  }

  // Search products in the cart
  Future<List<CartModel>> searchCartItem(String keywords, int userId) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> searchResults = await db.query(
      'cart',
      where: "product LIKE ? AND userId = ?",
      whereArgs: ['%$keywords%', userId],
    );
    return searchResults.map((item) => CartModel.fromMap(item)).toList();
  }

  // Get cart items for a user
  Future<List<CartModel>> getCartItem(int userId) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((e) => CartModel.fromMap(e)).toList();
  }

  // Add a new item to the cart
  Future<int> createCartItem(CartModel cartItem, int userId) async {
    final Database db = await initDB();
    cartItem.userId = userId;
    print('Inserting cart item with userId: ${cartItem.userId}');
    return db.insert('cart', cartItem.toMap());
  }

  // Delete a cart item
  Future<int> deleteCartItem(int id) async {
    final Database db = await initDB();
    return db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  // Update a cart item
  Future<int> updateCartItem(int id, String product, String description,
      double amount, int userId) async {
    final Database db = await initDB();
    return db.update(
      "cart",
      {"product": product, "description": description, "amount": amount},
      where: "id = ? AND userId = ?",
      whereArgs: [id, userId],
    );
  }

  // Add an item to addCart table
  Future<int> addToCart(CartItemModel cartItem, int userId) async {
    final Database db = await initDB();
    cartItem.userId =userId; 
    return db.insert('addCart', cartItem.toMap());
  }

  // Get addCart items for a user
  Future<List<CartItemModel>> getAddToCartItems(int userId,
      {bool fetchItems = true}) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result;
    if (fetchItems) {
      result =
          await db.query('addCart', where: 'userId = ?', whereArgs: [userId]);
    } else {
      result = await db.query('addCart',
          where: 'userId = ? AND isSelected = ?', whereArgs: [userId, 1]);
    }
    return result.map((e) => CartItemModel.fromMap(e)).toList();
  }

  // Remove an item from addCart table
  Future<int> removeFromCart(int id) async {
    final Database db = await initDB();
    return db.delete('addCart', where: 'id=?', whereArgs: [id]);
  }

  // Clear all items from addCart table
  Future<int> clearCart(int userId) async {
    final Database db = await initDB();
    return db.delete('addCart', where: 'userId = ?', whereArgs: [userId]);
  }

  // Check if product is in addCart table
  Future<bool> isProductInCart(int itemId, int userId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> result = await db.query(
      'addCart',
      columns: ['itemId'],
      where: 'itemId = ? AND userId = ?',
      whereArgs: [itemId, userId],
    );
    return result.isNotEmpty;
  }

  // Save order history
  Future<int> saveOrderHistory(
      String orderId, List<CartItemModel> items, int userId) async {
    final Database db = await initDB();
    double orderTotalAmount = 0.0;
    double orderFinalAmount = 0.0;

    for (var item in items) {
      final amount = item.amount;
      final tax = amount * 0.18;
      final totalAmount = (amount + tax) * item.quantity;

      orderTotalAmount += totalAmount;
      // print('Saving order history for userId: $userId');

      await db.insert('orderHistory', {
        'orderId': orderId,
        'userId': userId,
        'productId': item.id,
        'productName': item.product,
        'productDescription': item.description,
        'quantity': item.quantity,
        'amount': amount,
        'tax': tax,
        'totalAmount': totalAmount,
        'finalAmount': orderFinalAmount,
      });
    }

    return await db.rawInsert(
        'INSERT INTO orderHistory (orderId, totalAmount, finalAmount) VALUES (?, ?, ?)',
        [orderId, orderTotalAmount, orderFinalAmount]);
  }

  // Calculate final amount for an order
  Future<double> calculateOrderFinalAmount(Database db, String orderId) async {
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT SUM(totalAmount) AS finalAmount FROM orderHistory WHERE orderId = ?',
      [orderId],
    );
    double orderFinalAmount = results.first['finalAmount'] ?? 0.0;
    return orderFinalAmount;
  }

  // Fetch order history for a user
  Future<List<Map<String, dynamic>>> fetchOrderHistory({int? userId}) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> results = await db
        .query('orderHistory', where: 'userId = ?', whereArgs: [userId]);
    return results;
  }

  // Fetch details of a specific order
  Future<List<Map<String, dynamic>>> fetchOrderDetails(String orderId,
      {int? userId}) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> results = await db.query(
      'orderHistory',
      where: 'orderId = ? AND userId = ?',
      whereArgs: [orderId, userId],
    );
    return results;
  }

  // Calculate discounted amount
  double calculateDiscountedAmount(double amount, OfferState offerState) {
    if (offerState is SBIState) {
      return amount * (1 - offerState.discountPercentage);
    } else if (offerState is AxisState) {
      return amount * (1 - offerState.discountPercentage);
    } else if (offerState is FirstTransactionState) {
      return amount * (1 - offerState.discountPercentage);
    } else {
      return amount;
    }
  }
}
