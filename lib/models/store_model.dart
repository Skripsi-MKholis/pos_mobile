class StoreModel {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final DateTime? createdAt;
  String? get ownerEmail => email;

  StoreModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.createdAt,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }
}
