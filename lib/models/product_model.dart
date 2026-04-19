class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final double price;
  final double modalPrice; // HPP — dipakai juga di M5
  final String? imageUrl;
  final String category;
  final int stock;
  final bool isInfiniteStock;
  final String? barcode;
  final List<ProductVariantModel> variants;
  final ProductDiscountModel? appliedDiscount;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    required this.modalPrice,
    this.imageUrl,
    required this.category,
    this.stock = 0,
    this.isInfiniteStock = true,
    this.barcode,
    this.variants = const [],
    this.appliedDiscount,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      storeId: map['store_id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      modalPrice: (map['modal_price'] as num).toDouble(),
      imageUrl: map['image_url'],
      category: map['category'] ?? 'Umum',
      stock: map['stock'] ?? 0,
      isInfiniteStock: map['is_infinite_stock'] == 1 || map['is_infinite_stock'] == true,
      barcode: map['barcode'],
      // Variants & Discounts would be parsed here if they were JSON
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'price': price,
      'modal_price': modalPrice,
      'image': imageUrl, // Changed from image_url to image for UI compatibility
      'category': category,
      'stock': stock,
      'is_infinite_stock': isInfiniteStock ? 1 : 0,
      'barcode': barcode,
      'variants': variants.map((v) => v.toMap()).toList(),
      'appliedDiscount': appliedDiscount?.toMap(),
    };
  }
}

class ProductVariantModel {
  final String id;
  final String name;
  final double additionalPrice;

  ProductVariantModel({
    required this.id,
    required this.name,
    required this.additionalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': additionalPrice, // UI expects ‘price’ in options sometimes
    };
  }
}

class ProductDiscountModel {
  final String id;
  final String name;
  final double value;
  final String type; // 'percentage' or 'fixed'

  ProductDiscountModel({
    required this.id,
    required this.name,
    required this.value,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'type': type == 'percentage' ? 'Persentase (%)' : 'Nominal (Rp)',
    };
  }
}
