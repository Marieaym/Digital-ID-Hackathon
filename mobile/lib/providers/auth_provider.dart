import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient api;
  bool loading = false;
  Map<String, dynamic>? user;

  AuthProvider(this.api);

  Future<void> login(String username, String password) async {
    loading = true; notifyListeners();
    try {
      final res = await api.post('/auth/login', {'username': username, 'password': password});
      api.token = res['token'] as String;
      user = res['user'] as Map<String, dynamic>;
    } finally {
      loading = false; notifyListeners();
    }
  }

  void logout() { api.token = null; user = null; notifyListeners(); }
  bool get isLoggedIn => api.token != null;
}
