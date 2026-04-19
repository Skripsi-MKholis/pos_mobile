import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  final _client = Supabase.instance.client;

  SupabaseService._internal();

  factory SupabaseService() => _instance;

  // --- Product Methods ---
  Future<List<ProductModel>> fetchProducts(String storeId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('store_id', storeId);
    
    return (response as List).map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchTables(String storeId) async {
    final response = await _client
        .from('tables')
        .select()
        .eq('store_id', storeId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchCategories(String storeId) async {
    final response = await _client
        .from('product_categories')
        .select()
        .eq('store_id', storeId);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- Transaction Methods ---
  Future<String> uploadTransaction(TransactionModel transaction) async {
    // 1. Upload main transaction
    final trxResponse = await _client.from('transactions').insert({
      'local_id': transaction.localId,
      'store_id': transaction.storeId,
      'cashier_id': transaction.cashierId,
      'table_id': transaction.tableId,
      'customer_id': transaction.customerId, // Added customer support
      'total_amount': transaction.totalAmount,
      'payment_method': transaction.paymentMethod,
      'cash_paid': transaction.cashPaid,
      'change_amount': transaction.changeAmount,
      'status': transaction.status,
      'notes': transaction.notes,
      'created_at': transaction.createdAt.toIso8601String(),
    }).select('id').single();

    final String remoteId = trxResponse['id'];

    // 2. Upload items
    final List<Map<String, dynamic>> itemsData = transaction.items.map((item) {
      final map = item.toMap();
      map['transaction_id'] = remoteId; // Use remote ID
      map.remove('id'); // Let Supabase generate UUID for remote items if needed
      return map;
    }).toList();

    await _client.from('transaction_items').insert(itemsData);

    return remoteId;
  }

  // --- Customer Methods ---
  Future<List<Map<String, dynamic>>> fetchCustomers(String storeId) async {
    final response = await _client
        .from('customers')
        .select()
        .eq('store_id', storeId)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> customer) async {
    final response = await _client
        .from('customers')
        .insert(customer)
        .select()
        .single();
    return response;
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> updates) async {
    await _client
        .from('customers')
        .update(updates)
        .eq('id', id);
  }

  Future<void> deleteCustomer(String id) async {
    await _client
        .from('customers')
        .delete()
        .eq('id', id);
  }

  // --- Analytics & Reports ---
  Future<Map<String, dynamic>> fetchSalesSummary(String storeId, DateTime start, DateTime end) async {
    final response = await _client
        .from('transactions')
        .select('total_amount')
        .eq('store_id', storeId)
        .eq('status', 'Berhasil')
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());

    double total = 0;
    final data = response as List;
    for (var trx in data) {
      total += (trx['total_amount'] as num).toDouble();
    }

    return {
      'total_revenue': total,
      'transaction_count': data.length,
    };
  }

  Future<List<Map<String, dynamic>>> fetchDailyTrend(String storeId, int days) async {
    final start = DateTime.now().subtract(Duration(days: days));
    final response = await _client
        .from('transactions')
        .select('created_at, total_amount')
        .eq('store_id', storeId)
        .eq('status', 'Berhasil')
        .gte('created_at', start.toIso8601String())
        .order('created_at');

    Map<String, double> dailyTotals = {};
    for (var trx in (response as List)) {
      final dateStr = (trx['created_at'] as String).substring(0, 10);
      dailyTotals[dateStr] = (dailyTotals[dateStr] ?? 0) + (trx['total_amount'] as num).toDouble();
    }

    return dailyTotals.entries.map((e) => {'date': e.key, 'total': e.value}).toList();
  }

  Future<List<Map<String, dynamic>>> fetchTopProducts(String storeId, int limit) async {
    // Note: In production, using a view or RPC is better.
    // This aggregates over all transaction items for the store.
    
    // First get all successful transaction IDs for this store
    final trxResponse = await _client
        .from('transactions')
        .select('id')
        .eq('store_id', storeId)
        .eq('status', 'Berhasil');
    
    final trxIds = (trxResponse as List).map((t) => t['id']).toList();
    if (trxIds.isEmpty) return [];

    // Then get items for those transactions
    final itemsResponse = await _client
        .from('transaction_items')
        .select('product_name, quantity')
        .inFilter('transaction_id', trxIds);

    Map<String, int> productSales = {};
    for (var item in (itemsResponse as List)) {
      final name = item['product_name'] as String;
      final qty = (item['quantity'] as num).toInt();
      productSales[name] = (productSales[name] ?? 0) + qty;
    }

    var sorted = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => {'name': e.key, 'count': e.value}).toList();
  }
}
