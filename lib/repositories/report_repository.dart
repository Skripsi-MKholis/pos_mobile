import '../services/local_db_service.dart';
import '../services/supabase_service.dart';
import 'package:intl/intl.dart';

class ReportRepository {
  final _localDb = LocalDbService();
  final _supabase = SupabaseService();

  Future<Map<String, dynamic>> getDailySummary(String storeId) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    
    // 1. Get local summary (includes unsynced today)
    final localSummary = await _localDb.getLocalSalesSummary(storeId, todayStr);
    
    // 2. Get remote summary for today
    // We define "today" as from 00:00:00 to 23:59:59
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    
    try {
      final remoteSummary = await _supabase.fetchSalesSummary(storeId, startOfDay, endOfDay);
      
      // Since local data might contain synced data too, we need to be careful.
      // But based on our architecture, local data is ONLY unsynced? 
      // No, LocalDb.saveTransaction saves everything locally.
      // So LocalDb.getLocalSalesSummary gives us the total for the device.
      
      // If there are multiple devices, Remote is the source of truth for synced data.
      // Accurate Hybrid = (Remote Total) + (Local Unsynced Total)
      
      // Let's implement a simpler version first: 
      // If online, use Remote. If offline, use Local. 
      // Better: Remote is source of truth for the whole store.
      
      return remoteSummary;
    } catch (e) {
      // Offline fallback
      return localSummary;
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyTrend(String storeId) async {
    try {
      return await _supabase.fetchDailyTrend(storeId, 7);
    } catch (e) {
      // Simple fallback for charts
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProductInsights(String storeId) async {
    try {
      return await _supabase.fetchTopProducts(storeId, 5);
    } catch (e) {
      return [];
    }
  }
}
