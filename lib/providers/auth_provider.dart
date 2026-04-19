import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/store_model.dart';
import '../models/store_member_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();


  UserModel? _user;
  List<StoreMemberModel> _memberships = [];
  StoreMemberModel? _activeMembership;
  bool _isLoading = true;

  UserModel? get user => _user;
  List<StoreMemberModel> get memberships => _memberships;
  StoreMemberModel? get activeMembership => _activeMembership;
  StoreModel? get selectedStore => _activeMembership?.store;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final sbUser = _authRepo.currentSupabaseUser;
    if (sbUser != null) {
      await _fetchProfile(sbUser.id);
      await _loadPersistedStore();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchProfile(String userId) async {
    _user = await _authRepo.getUserProfile(userId);
    if (_user != null) {
      _memberships = await _authRepo.getUserMemberships(userId);
      
      // If only one membership and no active set, auto-select it
      if (_memberships.length == 1 && _activeMembership == null) {
        _activeMembership = _memberships.first;
      }
    }
    notifyListeners();
  }

  Future<void> _loadPersistedStore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStoreId = prefs.getString('active_store_id');
    
    if (savedStoreId != null && _memberships.isNotEmpty) {
      final match = _memberships.where((m) => m.storeId == savedStoreId).firstOrNull;
      if (match != null) {
        _activeMembership = match;
      }
    }
    notifyListeners();
  }

  Future<void> _persistStore(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_store_id', storeId);
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authRepo.signIn(email: email, password: password);
      if (response.user != null) {
        await _fetchProfile(response.user!.id);
        await _loadPersistedStore();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      _isLoading = false;
      notifyListeners();
      // Rethrow to allow UI to handle specific error messages
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_store_id');
    
    await _authRepo.signOut();
    _user = null;
    _memberships = [];
    _activeMembership = null;
    notifyListeners();
  }

  void selectMembership(StoreMemberModel? membership) {
    _activeMembership = membership;
    if (membership != null) {
      _persistStore(membership.storeId);
    } else {
      _clearPersistedStore();
    }
    notifyListeners();
  }

  Future<void> _clearPersistedStore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_store_id');
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String storeName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authRepo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        storeName: storeName,
      );
      
      if (response.user != null) {
        // Wait for profile propagation if any, though we now do it manually
        await Future.delayed(const Duration(seconds: 1));
        await _fetchProfile(response.user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register Error: $e');
      _isLoading = false;
      notifyListeners();
      // Rethrow to allow UI to handle specific error messages
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
