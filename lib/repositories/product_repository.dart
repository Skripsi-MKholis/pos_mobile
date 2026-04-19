import '../models/product_model.dart';
import '../services/local_db_service.dart';
import '../services/supabase_service.dart';

class ProductRepository {
  final _localDb = LocalDbService();
  final _supabase = SupabaseService();

  Future<List<ProductModel>> getProducts(String storeId, {bool forceRefresh = false}) async {
    // 1. Try to get from local cache first
    final cached = await _localDb.getCachedProducts(storeId);
    
    if (cached.isNotEmpty && !forceRefresh) {
      return cached;
    }

    // 2. If empty or forceRefresh, fetch from remote
    try {
      final remoteProducts = await _supabase.fetchProducts(storeId);
      // 3. Update cache
      await _localDb.cacheProducts(remoteProducts);
      return remoteProducts;
    } catch (e) {
      // If remote fails, return cached if available, otherwise empty
      return cached;
    }
  }
}
