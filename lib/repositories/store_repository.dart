import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store_model.dart';

class StoreRepository {
  final _client = Supabase.instance.client;

  Future<List<StoreModel>> getOwnedStores(String ownerEmail) async {
    final response = await _client
        .from('stores')
        .select()
        .eq('email', ownerEmail);

    return (response as List).map((e) => StoreModel.fromMap(e)).toList();
  }

  Future<StoreModel?> getStoreById(String storeId) async {
    try {
      final data = await _client
          .from('stores')
          .select()
          .eq('id', storeId)
          .single();
      return StoreModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<StoreModel> createStore(String name, String ownerEmail) async {
    final response = await _client.from('stores').insert({
      'name': name,
      'email': ownerEmail,
    }).select().single();
    return StoreModel.fromMap(response);
  }
}
