import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/store_member_model.dart';

class AuthRepository {
  final _client = Supabase.instance.client;

  User? get currentSupabaseUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String storeName,
  }) async {
    // 1. Sign up user in Auth
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );

    if (response.user != null) {
      final userId = response.user!.id;

      try {
        // 2. Ensure record exists in public.users
        // We do an upsert just in case a trigger already created it
        await _client.from('users').upsert({
          'id': userId,
          'email': email,
          'full_name': fullName,
        });

        // 3. Create the store
        final storeData = await _client.from('stores').insert({
          'name': storeName,
          'email': email,
        }).select().single();

        final storeId = storeData['id'];

        // 4. Create membership as Owner
        await _client.from('store_members').insert({
          'user_id': userId,
          'store_id': storeId,
          'role': 'Owner',
        });
      } catch (e) {
        // If profile/store creation fails, we might want to log it
        // Note: auth user is still created, but app flow is broken.
        // User will likely need to try again or admin manual fix.
        debugPrint('Error during secondary signup steps: $e');
        rethrow;
      }
    }
    
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<StoreMemberModel>> getUserMemberships(String userId) async {
    try {
      final data = await _client
          .from('store_members')
          .select('*, stores(*)')
          .eq('user_id', userId);
      
      return (data as List).map((e) => StoreMemberModel.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
