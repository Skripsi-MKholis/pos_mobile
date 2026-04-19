import '../services/local_db_service.dart';
import '../services/supabase_service.dart';

class MasterRepository {
  final _localDb = LocalDbService();
  final _supabase = SupabaseService();

  Future<List<Map<String, dynamic>>> getTables(String storeId, {bool forceRefresh = false}) async {
    final cached = await _localDb.getCachedTables(storeId);
    if (cached.isNotEmpty && !forceRefresh) {
      return cached;
    }

    try {
      final remote = await _supabase.fetchTables(storeId);
      await _localDb.cacheTables(remote);
      return remote;
    } catch (e) {
      return cached;
    }
  }

  Future<List<Map<String, dynamic>>> getCategories(String storeId, {bool forceRefresh = false}) async {
    final cached = await _localDb.getCachedCategories(storeId);
    if (cached.isNotEmpty && !forceRefresh) {
      return cached;
    }

    try {
      final remote = await _supabase.fetchCategories(storeId);
      await _localDb.cacheCategories(remote);
      return remote;
    } catch (e) {
      return cached;
    }
  }
}
