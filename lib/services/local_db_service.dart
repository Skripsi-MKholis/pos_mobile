import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  static Database? _database;

  LocalDbService._internal();

  factory LocalDbService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pos_local.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        store_id TEXT,
        name TEXT,
        price REAL,
        modal_price REAL,
        image_url TEXT,
        category TEXT,
        stock INTEGER,
        is_infinite_stock INTEGER,
        barcode TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        local_id TEXT PRIMARY KEY,
        remote_id TEXT,
        store_id TEXT,
        cashier_id TEXT,
        table_id TEXT,
        customer_id TEXT,
        total_amount REAL,
        payment_method TEXT,
        cash_paid REAL,
        change_amount REAL,
        status TEXT,
        notes TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Transaction items table
    await db.execute('''
      CREATE TABLE transaction_items (
        id TEXT PRIMARY KEY,
        transaction_id TEXT,
        product_id TEXT,
        product_name TEXT,
        product_sku TEXT,
        unit_price REAL,
        quantity INTEGER,
        subtotal REAL,
        notes TEXT,
        FOREIGN KEY (transaction_id) REFERENCES transactions (local_id) ON DELETE CASCADE
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        store_id TEXT,
        name TEXT,
        phone TEXT,
        email TEXT,
        notes TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await _createMasterTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createMasterTables(db);
    }
    if (oldVersion < 3) {
      // Add customer_id to transactions
      await db.execute('ALTER TABLE transactions ADD COLUMN customer_id TEXT');
      // Create customers table
      await db.execute('''
        CREATE TABLE customers (
          id TEXT PRIMARY KEY,
          store_id TEXT,
          name TEXT,
          phone TEXT,
          email TEXT,
          notes TEXT,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    }
  }

  Future<void> _createMasterTables(Database db) async {
    // Tables table
    await db.execute('''
      CREATE TABLE tables (
        id TEXT PRIMARY KEY,
        store_id TEXT,
        name TEXT,
        capacity INTEGER,
        status TEXT,
        area TEXT
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        store_id TEXT,
        name TEXT
      )
    ''');
  }

  // --- Product Methods ---
  Future<void> cacheProducts(List<ProductModel> products) async {
    final db = await database;
    Batch batch = db.batch();
    for (var product in products) {
      batch.insert('products', product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<ProductModel>> getCachedProducts(String storeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'store_id = ?',
      whereArgs: [storeId],
    );
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  // --- Transaction Methods ---
  Future<void> saveTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('transactions', transaction.toMap());
      for (var item in transaction.items) {
        await txn.insert('transaction_items', item.toMap());
      }
    });
  }

  Future<List<TransactionModel>> getPendingTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> trxMaps = await db.query(
      'transactions',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    List<TransactionModel> transactions = [];
    for (var trxMap in trxMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [trxMap['local_id']],
      );
      List<TransactionItemModel> items = List.generate(
          itemMaps.length, (i) => TransactionItemModel.fromMap(itemMaps[i]));
      transactions.add(TransactionModel.fromMap(trxMap, items: items));
    }
    return transactions;
  }

  Future<void> markAsSynced(String localId, String remoteId) async {
    final db = await database;
    await db.update(
      'transactions',
      {'is_synced': 1, 'remote_id': remoteId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<List<TransactionModel>> getAllTransactions(String storeId) async {
    final db = await database;
    final List<Map<String, dynamic>> trxMaps = await db.query(
      'transactions',
      where: 'store_id = ?',
      whereArgs: [storeId],
      orderBy: 'created_at DESC',
    );

    List<TransactionModel> transactions = [];
    for (var trxMap in trxMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [trxMap['local_id']],
      );
      List<TransactionItemModel> items = List.generate(
          itemMaps.length, (i) => TransactionItemModel.fromMap(itemMaps[i]));
      transactions.add(TransactionModel.fromMap(trxMap, items: items));
    }
    return transactions;
  }
  // --- Master Data Methods ---
  Future<void> cacheTables(List<Map<String, dynamic>> tables) async {
    final db = await database;
    Batch batch = db.batch();
    for (var table in tables) {
      batch.insert('tables', table, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedTables(String storeId) async {
    final db = await database;
    return await db.query(
      'tables',
      where: 'store_id = ?',
      whereArgs: [storeId],
    );
  }

  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    final db = await database;
    Batch batch = db.batch();
    for (var cat in categories) {
      batch.insert('categories', cat,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedCategories(String storeId) async {
    final db = await database;
    return await db.query(
      'categories',
      where: 'store_id = ?',
      whereArgs: [storeId],
    );
  }

  // --- Analytics & Reports ---
  Future<Map<String, dynamic>> getLocalSalesSummary(String storeId, String dateIso) async {
    final db = await database;
    
    // Total revenue today
    final List<Map<String, dynamic>> revenueResult = await db.rawQuery('''
      SELECT SUM(total_amount) as total 
      FROM transactions 
      WHERE store_id = ? AND date(created_at) = date(?) AND status = 'Berhasil'
    ''', [storeId, dateIso]);

    // Total transactions today
    final List<Map<String, dynamic>> countResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM transactions 
      WHERE store_id = ? AND date(created_at) = date(?) AND status = 'Berhasil'
    ''', [storeId, dateIso]);

    return {
      'total_revenue': revenueResult.first['total'] ?? 0.0,
      'transaction_count': countResult.first['count'] ?? 0,
    };
  }

  // --- Customer Methods ---
  Future<void> cacheCustomers(List<Map<String, dynamic>> customers) async {
    final db = await database;
    Batch batch = db.batch();
    for (var customer in customers) {
      batch.insert('customers', customer,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedCustomers(String storeId) async {
    final db = await database;
    return await db.query(
      'customers',
      where: 'store_id = ?',
      whereArgs: [storeId],
      orderBy: 'name ASC',
    );
  }

  Future<void> saveCustomerLocal(Map<String, dynamic> customer) async {
    final db = await database;
    await db.insert('customers', customer,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteCustomerLocal(String id) async {
    final db = await database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
