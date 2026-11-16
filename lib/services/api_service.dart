import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class ApiService {
  // Helper to get effective GAS URL
  static Future<String> _getUrl() async {
    return await StorageService.getGasUrl();
  }

  // Generic POST dispatcher to Google Apps Script
  static Future<Map<String, dynamic>> _sendPost(Map<String, dynamic> payload) async {
    final url = await _getUrl();
    if (url.isEmpty) {
      throw Exception('GAS_URL_EMPTY');
    }

    final uri = Uri.parse(url);
    var response = await http.post(
      uri,
      headers: {
        'Content-Type': 'text/plain;charset=utf-8', // GAS handles text/plain without CORS preflight issues
      },
      body: jsonEncode(payload),
    );

    // Follow redirects (Google Apps Script always responds to POST with 302 Found)
    int redirects = 0;
    while ((response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 303 ||
            response.statusCode == 307 ||
            response.statusCode == 308) &&
        redirects < 5) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        response = await http.get(Uri.parse(redirectUrl));
        redirects++;
      } else {
        break;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 400) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          return {'status': 'success', 'data': decoded};
        }
      } catch (e) {
        debugPrint('JSON decode error: $e, body: ${response.body}');
        throw Exception('Respon server tidak valid');
      }
    } else {
      throw Exception('Server error: HTTP ${response.statusCode}');
    }
  }

  // 1. REGISTER
  static Future<ApiResult<UserModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _sendPost({
        'action': 'register',
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      });

      if (res['status'] == 'success') {
        final data = res['data'];
        final user = UserModel(
          userId: data['user_id'] ?? 'USR-${DateTime.now().millisecondsSinceEpoch}',
          name: data['name'] ?? name,
          email: data['email'] ?? email,
          password: password,
        );
        return ApiResult(success: true, message: res['message'] ?? 'Pendaftaran berhasil', data: user);
      } else {
        return ApiResult(success: false, message: res['message'] ?? 'Pendaftaran gagal');
      }
    } catch (e) {
      if (e.toString().contains('GAS_URL_EMPTY')) {
        // Mock fallback for immediate testing before GAS setup
        final mockUser = UserModel(
          userId: 'USR-${DateTime.now().millisecondsSinceEpoch}',
          name: name.trim(),
          email: email.trim(),
          password: password,
        );
        return ApiResult(
          success: true,
          message: 'Berhasil didaftarkan (Mode Demo Offline)',
          data: mockUser,
        );
      }
      return ApiResult(success: false, message: 'Gagal terhubung: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // 2. LOGIN
  static Future<ApiResult<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _sendPost({
        'action': 'login',
        'email': email.trim(),
        'password': password,
      });

      if (res['status'] == 'success') {
        final data = res['data'];
        final user = UserModel(
          userId: data['user_id'],
          name: data['name'] ?? 'Pengguna',
          email: email.trim(),
          password: password,
        );
        return ApiResult(success: true, message: 'Login berhasil', data: user);
      } else {
        return ApiResult(success: false, message: res['message'] ?? 'Email atau password salah');
      }
    } catch (e) {
      if (e.toString().contains('GAS_URL_EMPTY')) {
        // Mock fallback
        final mockUser = UserModel(
          userId: 'USR-DEMO-123',
          name: email.split('@').first,
          email: email.trim(),
          password: password,
        );
        return ApiResult(
          success: true,
          message: 'Login berhasil (Mode Demo Offline)',
          data: mockUser,
        );
      }
      return ApiResult(success: false, message: 'Gagal terhubung: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // 2B. FORGOT PASSWORD
  static Future<ApiResult<bool>> forgotPassword(String email) async {
    try {
      final res = await _sendPost({
        'action': 'forgotPassword',
        'email': email.trim(),
      });

      if (res['status'] == 'success') {
        return ApiResult(
          success: true,
          message: res['message'] ?? 'Password telah dikirim ke email Anda',
          data: true,
        );
      } else {
        return ApiResult(
          success: false,
          message: res['message'] ?? 'Email tidak ditemukan',
          data: false,
        );
      }
    } catch (e) {
      if (e.toString().contains('GAS_URL_EMPTY')) {
        return ApiResult(
          success: true,
          message: 'Instruksi pemulihan telah dikirim (Mode Demo)',
          data: true,
        );
      }
      return ApiResult(
        success: false,
        message: 'Gagal mengirim permintaan: ${e.toString().replaceAll('Exception: ', '')}',
        data: false,
      );
    }
  }

  // 3. GET TRANSACTIONS
  static Future<ApiResult<List<TransactionModel>>> getTransactions(String userId) async {
    try {
      final res = await _sendPost({
        'action': 'getTransactions',
        'user_id': userId,
      });

      if (res['status'] == 'success') {
        final List list = res['data'] ?? [];
        final transactions = list.map((item) => TransactionModel.fromJson(item)).toList();
        return ApiResult(success: true, message: 'Sukses', data: transactions);
      } else {
        return ApiResult(success: false, message: res['message'] ?? 'Gagal memuat transaksi');
      }
    } catch (e) {
      if (e.toString().contains('GAS_URL_EMPTY')) {
        return ApiResult(
          success: true,
          message: 'Mode offline aktif',
          data: await StorageService.getCachedTransactions(),
        );
      }
      return ApiResult(success: false, message: 'Gagal sinkron: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // 4. ADD TRANSACTION
  static Future<ApiResult<TransactionModel>> addTransaction(TransactionModel item) async {
    try {
      final res = await _sendPost({
        'action': 'addTransaction',
        'user_id': item.userId,
        'type': item.type,
        'source': item.source,
        'amount': item.amount,
        'description': item.description,
        'transaction_date': item.transactionDate,
      });

      if (res['status'] == 'success') {
        final returnedId = res['data']?['transaction_id'] ?? item.transactionId;
        return ApiResult(
          success: true,
          message: 'Transaksi berhasil disimpan',
          data: item.copyWith(transactionId: returnedId.toString()),
        );
      } else {
        return ApiResult(success: false, message: res['message'] ?? 'Gagal menyimpan transaksi');
      }
    } catch (e) {
      if (e.toString().contains('GAS_URL_EMPTY')) {
        return ApiResult(
          success: true,
          message: 'Tersimpan lokal (Mode Demo)',
          data: item,
        );
      }
      return ApiResult(success: false, message: 'Gagal mengirim: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // 5. EDIT TRANSACTION
  static Future<ApiResult<TransactionModel>> editTransaction(TransactionModel item) async {
    try {
      final res = await _sendPost({
        'action': 'editTransaction',
        'transaction_id': item.transactionId,
        'user_id': item.userId,
        'type': item.type,
        'source': item.source,
        'amount': item.amount,
        'description': item.description,
        'transaction_date': item.transactionDate,
      });

      if (res['status'] == 'success') {
        return ApiResult(
          success: true,
          message: 'Transaksi berhasil diperbarui',
          data: item,
        );
      } else {
        return ApiResult(success: false, message: res['message'] ?? 'Gagal memperbarui transaksi');
      }
    } catch (e) {
      if (e.toString().contains('GAS_URL_EMPTY')) {
        return ApiResult(
          success: true,
          message: 'Diperbarui lokal (Mode Demo)',
          data: item,
        );
      }
      return ApiResult(success: false, message: 'Gagal memperbarui: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // 6. DELETE TRANSACTION
  static Future<ApiResult<bool>> deleteTransaction(String transactionId) async {
    try {
      final res = await _sendPost({
        'action': 'deleteTransaction',
        'transaction_id': transactionId,
      });

      if (res['status'] == 'success') {
        return ApiResult(success: true, message: 'Transaksi berhasil dihapus', data: true);
      } else {
        return ApiResult(success: false, message: res['message'] ?? 'Gagal menghapus transaksi');
      }
    } catch (e) {
      if (e.toString().contains('GAS_URL_EMPTY')) {
        return ApiResult(success: true, message: 'Dihapus lokal (Mode Demo)', data: true);
      }
      return ApiResult(success: false, message: 'Gagal menghapus: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
