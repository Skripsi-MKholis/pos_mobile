import '../models/customer_model.dart';
import '../services/local_db_service.dart';
import '../services/supabase_service.dart';

class CustomerRepository {
  final _localDb = LocalDbService();
  final _supabase = SupabaseService();

  Future<List<CustomerModel>> getCustomers(String storeId, {bool forceRefresh = false}) async {
    final cached = await _localDb.getCachedCustomers(storeId);
    if (cached.isNotEmpty && !forceRefresh) {
      return cached.map((e) => CustomerModel.fromMap(e)).toList();
    }

    try {
      final remote = await _supabase.fetchCustomers(storeId);
      await _localDb.cacheCustomers(remote);
      return remote.map((e) => CustomerModel.fromMap(e)).toList();
    } catch (e) {
      if (cached.isNotEmpty) {
        return cached.map((e) => CustomerModel.fromMap(e)).toList();
      }
      rethrow;
    }
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    // 1. Create in Supabase
    final remote = await _supabase.createCustomer(customer.toMap());
    final newCustomer = CustomerModel.fromMap(remote);
    
    // 2. Cache in local DB
    await _localDb.saveCustomerLocal(newCustomer.toMap());
    
    return newCustomer;
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    // 1. Update in Supabase
    await _supabase.updateCustomer(customer.id!, customer.toMap());
    
    // 2. Update local cache
    await _localDb.saveCustomerLocal(customer.toMap());
  }

  Future<void> deleteCustomer(String id) async {
    // 1. Delete in Supabase
    await _supabase.deleteCustomer(id);
    
    // 2. Delete local cache
    await _localDb.deleteCustomerLocal(id);
  }
}
