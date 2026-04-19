import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_db_service.dart';
import 'supabase_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  final _localDb = LocalDbService();
  final _supabase = SupabaseService();
  final _connectivity = Connectivity();
  
  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;

  SyncService._internal();

  factory SyncService() => _instance;

  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        syncPendingTransactions();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  Future<void> syncPendingTransactions() async {
    if (_isSyncing) return;
    
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.isEmpty || connectivity.contains(ConnectivityResult.none)) return;

    _isSyncing = true;
    try {
      final pendingTransactions = await _localDb.getPendingTransactions();
      
      for (var trx in pendingTransactions) {
        try {
          final remoteId = await _supabase.uploadTransaction(trx);
          await _localDb.markAsSynced(trx.localId, remoteId);
        } catch (e) {
          debugPrint('Sync error for transaction ${trx.localId}: $e');
          // Continue with next transaction
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
