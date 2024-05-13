import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../presentation/blocs/add_to_cart/add_to_cart_bloc.dart';
import '../models/cart_model.dart';
import '../models/user_model.dart';

class DataBaseHelper {
  final databaseName = "shopper.db";
  String cart =
      "create table cart (id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, product TEXT NOT NULL, description TEXT NOT NULL, amount REAL)";

  String addCart =
      "create table addCart(id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, itemId INTEGER, product TEXT NOT NULL, description TEXT NOT NULL, amount REAL, quantity INTEGER, isSelected INTEGER )";

  String users =
      "create table users (userId INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT UNIQUE, password TEXT)";

  String orderHistory = "CREATE TABLE orderHistory ("
      "orderId TEXT,"
      "productId INTEGER,"
      "productName TEXT NOT NULL,"
      "productDescription TEXT NOT NULL,"
      "quantity INTEGER,"
      "amount REAL,"
      "tax REAL,"
      "totalAmount REAL,"
      "finalAmount REAL"
      ")";

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

  // this function is used for logging in the user with credentials
  Future<bool> login(Users user) async {
    final Database db = await initDB();

    var result = await db.rawQuery(
        "select * from users where userName = '${user.userName}' AND password = '${user.password}'");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // this function is used to add the user to the db
  Future<int> signup(Users user) async {
    final Database db = await initDB();

    return db.insert('users', user.toMap());
  }

  // This function is used to search products in the db
  Future<List<CartModel>> searchCartItem(String keywords) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> searchResults = await db.query(
      'cart',
      where: "product LIKE ?",
      whereArgs: ['%$keywords%'],
    );
    // print("searchResults: $searchResults");
    List<CartModel> items =
        searchResults.map((item) => CartModel.fromMap(item)).toList();
    return items;
  }

  // this function is used to add the new products to the db
  Future<int> createCartItem(CartModel addToCart) async {
    final Database db = await initDB();
    return db.insert('cart', addToCart.toMap());
  }

  // this function is used to fetch the products from the db
  Future<List<CartModel>> getCartItem() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('cart');
    return result.map((e) => CartModel.fromMap(e)).toList();
  }

  // this function is used to delete the items from the db using id
  Future<int> deleteCartItem(int id) async {
    final Database db = await initDB();
    return db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  // this function is used to update the info about the product in the db
  Future<int> updateCartItem(
      int id, String product, String description, double amount) async {
    final Database db = await initDB();
    return db.update("cart",
        {"product": product, "description": description, "amount": amount},
        where: "id = ?", whereArgs: [id]);
  }

  // this function is used to add the products in the addcart table from cart table
  Future<int> addToCart(CartItemModel cartItem) async {
    final Database db = await initDB();
    return db.insert('addCart', cartItem.toMap());
  }

  // this function is used to fetch all the products that are stored in the add cart table
  Future<List<CartItemModel>> getAddToCartItems(
      {bool fetchItems = true}) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result;
    if (fetchItems) {
      result = await db.query('addCart');
    } else {
      result =
          await db.query('addCart', where: 'isSelected = ?', whereArgs: [1]);
    }
    return result.map((e) => CartItemModel.fromMap(e)).toList();
  }

  // this function is used to delete a particular item from the adccart table using id.
  Future<int> removeFromCart(int id) async {
    final Database db = await initDB();
    return db.delete('addCart', where: 'id=?', whereArgs: [id]);
  }

  // this function is used to clear all the products from the addcart table
  Future<int> clearCart() async {
    final Database db = await initDB();
    // print("All items Cleared.");
    return db.delete('addCart');
  }

  // this function is used to check if the product is in the addcart table with the help of the itemid.
  Future<bool> isProductInCart(int itemId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> result = await db.query(
      'addCart',
      columns: ['itemId'],
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
    return result.isNotEmpty;
  }

  /// This function is used to save order history by taking orderID and list of item of datatype
  /// cartitemmodel and saves the data, in first await it is storing items and in second
  ///  await it is storing amount.
  Future<int> saveOrderHistory(
      String orderId, List<CartItemModel> items) async {
    final Database db = await initDB();
    double orderTotalAmount = 0.0;
    double orderFinalAmount = 0.0;

    for (var item in items) {
      final amount = item.amount;
      final tax = amount * 0.18;
      final totalAmount = (amount + tax) * item.quantity;

      orderTotalAmount += totalAmount;

      await db.insert('orderHistory', {
        'orderId': orderId,
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
  
Future<double> _calculateOrderFinalAmount(Database db, String orderId) async {
  final List<Map<String, dynamic>> results = await db.rawQuery(
    'SELECT SUM(totalAmount) AS finalAmount FROM orderHistory WHERE orderId = ?',
    [orderId],
  );
  double orderFinalAmount = results.first['finalAmount'] ?? 0.0;
  return orderFinalAmount;
}

  Future<List<Map<String, dynamic>>> fetchOrderHistory() async {
    final Database db = await initDB();
    List<Map<String, dynamic>> results =
        await db.query('orderHistory', columns: ['orderId', 'totalAmount']);
    return results;
  }

Future<List<Map<String, dynamic>>> fetchOrderDetails(String orderId) async {
  final Database db = await initDB();
  List<Map<String, dynamic>> results = await db.query(
    'orderHistory',
    where: 'orderId = ?',
    whereArgs: [orderId],
  );
  return results;
}

  // this function is used to calculate the discount for the item
  double _calculateDiscountedAmount(double amount, OfferState offerState) {
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
