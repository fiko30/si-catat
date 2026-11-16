import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const String _keyUser = 'sicatat_user';
  static const String _keyGasUrl = 'sicatat_gas_url';
  static const String _keyTransactions = 'sicatat_cached_transactions';

  // Default GAS Web App URL Si Catat (Ganti dengan URL deployment Web App Anda)
  static const String defaultGasUrl = 'YOUR_GOOGLE_APPS_SCRIPT_URL_HERE';

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_keyUser);
    if (userStr != null && userStr.isNotEmpty) {
      try {
        return UserModel.fromJson(jsonDecode(userStr));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyTransactions);
  }

  static Future<void> saveGasUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGasUrl, url.trim());
  }

  static Future<String> getGasUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString(_keyGasUrl);
    if (customUrl != null && customUrl.trim().isNotEmpty) {
      return customUrl.trim();
    }
    return defaultGasUrl;
  }

  static Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_keyTransactions, jsonEncode(listJson));
  }

  static Future<List<TransactionModel>> getCachedTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyTransactions);
    if (data != null && data.isNotEmpty) {
      try {
        final List decoded = jsonDecode(data);
        return decoded.map((item) => TransactionModel.fromJson(item)).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }
}
