import '../models/transaction_model.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';

class TransactionRepository {
  final _localDb = LocalDbService();
  final _syncService = SyncService();

  Future<void> saveTransaction(TransactionModel transaction) async {
    // 1. Always save locally first
    await _localDb.saveTransaction(transaction);
    
    // 2. Trigger async sync (don't wait for it to finish UI-wise)
    _syncService.syncPendingTransactions();
  }

  Future<List<TransactionModel>> getTransactions(String storeId) async {
    return await _localDb.getAllTransactions(storeId);
  }
}
