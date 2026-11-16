import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  UserModel? _currentUser;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculators
  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpense;

  // 10 Riwayat Terakhir (diurutkan dari tanggal terbaru)
  List<TransactionModel> get recentTransactions {
    final sorted = List<TransactionModel>.from(_transactions);
    sorted.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return sorted.take(10).toList();
  }

  // Filter per Bulan & Tahun
  List<TransactionModel> getFilteredTransactions(int month, int year) {
    final filtered = _transactions.where((t) {
      try {
        final date = DateTime.parse(t.transactionDate);
        return date.month == month && date.year == year;
      } catch (_) {
        return false;
      }
    }).toList();

    filtered.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return filtered;
  }

  // Inisialisasi User & Data
  Future<void> init(UserModel user) async {
    _currentUser = user;
    // Load cache lokal terlebih dahulu agar tampilan langsung muncul (0 loading time)
    _transactions = await StorageService.getCachedTransactions();
    notifyListeners();

    // Lalu sync dari Apps Script / Spreadsheet di latar belakang
    await refreshTransactions();
  }

  Future<void> refreshTransactions() async {
    if (_currentUser == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.getTransactions(_currentUser!.userId);
    _isLoading = false;

    if (result.success && result.data != null) {
      _transactions = result.data!;
      // Simpan ke cache lokal
      await StorageService.cacheTransactions(_transactions);
    } else {
      _errorMessage = result.message;
    }
    notifyListeners();
  }

  // Tambah Transaksi (Optimistic Update)
  Future<ApiResult<TransactionModel>> addTransaction({
    required String type,
    required String source,
    required double amount,
    required String description,
    required String transactionDate,
  }) async {
    if (_currentUser == null) {
      return ApiResult(success: false, message: 'User belum login');
    }

    final tempId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';
    final newItem = TransactionModel(
      transactionId: tempId,
      userId: _currentUser!.userId,
      type: type,
      source: source,
      amount: amount,
      description: description,
      transactionDate: transactionDate,
      createdAt: DateTime.now().toIso8601String(),
    );

    // Update state lokal seketika
    _transactions.insert(0, newItem);
    notifyListeners();
    await StorageService.cacheTransactions(_transactions);

    // Kirim ke Google Apps Script
    final result = await ApiService.addTransaction(newItem);
    if (result.success && result.data != null) {
      final index = _transactions.indexWhere((t) => t.transactionId == tempId);
      if (index != -1) {
        _transactions[index] = result.data!;
        await StorageService.cacheTransactions(_transactions);
        notifyListeners();
      }
    }
    return result;
  }

  // Edit Transaksi
  Future<ApiResult<TransactionModel>> editTransaction(TransactionModel item) async {
    final index = _transactions.indexWhere((t) => t.transactionId == item.transactionId);
    if (index == -1) {
      return ApiResult(success: false, message: 'Transaksi tidak ditemukan');
    }

    // Backup lama untuk rollback jika error
    final oldItem = _transactions[index];

    // Optimistic update
    _transactions[index] = item;
    notifyListeners();
    await StorageService.cacheTransactions(_transactions);

    final result = await ApiService.editTransaction(item);
    if (!result.success) {
      // Rollback jika gagal
      _transactions[index] = oldItem;
      notifyListeners();
      await StorageService.cacheTransactions(_transactions);
    }
    return result;
  }

  // Hapus Transaksi
  Future<ApiResult<bool>> deleteTransaction(String transactionId) async {
    final index = _transactions.indexWhere((t) => t.transactionId == transactionId);
    if (index == -1) {
      return ApiResult(success: false, message: 'Transaksi tidak ditemukan');
    }

    final deletedItem = _transactions[index];

    // Hapus dari state lokal seketika
    _transactions.removeAt(index);
    notifyListeners();
    await StorageService.cacheTransactions(_transactions);

    final result = await ApiService.deleteTransaction(transactionId);
    if (!result.success) {
      // Rollback jika gagal
      _transactions.insert(index, deletedItem);
      notifyListeners();
      await StorageService.cacheTransactions(_transactions);
    }
    return result;
  }

  void logout() {
    _currentUser = null;
    _transactions = [];
    notifyListeners();
  }
}
