import 'store_model.dart';

class StoreMemberModel {
  final String id;
  final String userId;
  final String storeId;
  final String role; // 'Owner', 'Karyawan', 'Pelanggan'
  final DateTime? createdAt;
  final StoreModel? store; // Optional: include store details for selection lists

  StoreMemberModel({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.role,
    this.createdAt,
    this.store,
  });

  factory StoreMemberModel.fromMap(Map<String, dynamic> map) {
    return StoreMemberModel(
      id: map['id'],
      userId: map['user_id'],
      storeId: map['store_id'],
      role: map['role'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      store: map['stores'] != null ? StoreModel.fromMap(map['stores']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'store_id': storeId,
      'role': role,
    };
  }
}
