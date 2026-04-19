import 'transaction_item_model.dart';

class TransactionModel {
  final String localId; // UUID lokal (SQLite)
  final String? remoteId; // UUID Supabase (null jika belum sync)
  final String storeId;
  final String cashierId;
  final String? tableId;
  final String? customerId;
  final List<TransactionItemModel> items;
  final double totalAmount;
  final String paymentMethod;
  final double? cashPaid;
  final double? changeAmount;
  final String status; // Berhasil | Batal
  final String? notes;
  final DateTime createdAt;
  final bool isSynced;

  TransactionModel({
    required this.localId,
    this.remoteId,
    required this.storeId,
    required this.cashierId,
    this.tableId,
    this.customerId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    this.cashPaid,
    this.changeAmount,
    this.status = 'Berhasil',
    this.notes,
    required this.createdAt,
    this.isSynced = false,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map,
      {List<TransactionItemModel> items = const []}) {
    return TransactionModel(
      localId: map['local_id'],
      remoteId: map['remote_id'],
      storeId: map['store_id'],
      cashierId: map['cashier_id'],
      tableId: map['table_id'],
      customerId: map['customer_id'],
      items: items,
      totalAmount: (map['total_amount'] as num).toDouble(),
      paymentMethod: map['payment_method'],
      cashPaid: map['cash_paid'] != null ? (map['cash_paid'] as num).toDouble() : null,
      changeAmount: map['change_amount'] != null
          ? (map['change_amount'] as num).toDouble()
          : null,
      status: map['status'] ?? 'Berhasil',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'local_id': localId,
      'remote_id': remoteId,
      'store_id': storeId,
      'cashier_id': cashierId,
      'table_id': tableId,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'cash_paid': cashPaid,
      'change_amount': changeAmount,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }
}
