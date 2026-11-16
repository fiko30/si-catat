import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_theme.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '');
    }

    int value = int.tryParse(cleanText) ?? 0;
    String newFormatted = _formatter.format(value).replaceAll(',', '.');

    return TextEditingValue(
      text: newFormatted,
      selection: TextSelection.collapsed(offset: newFormatted.length),
    );
  }
}

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionProvider provider;
  final TransactionModel? itemToEdit;
  final String? initialType; // 'pemasukan' atau 'pengeluaran'

  const AddEditTransactionScreen({
    super.key,
    required this.provider,
    this.itemToEdit,
    this.initialType,
  });

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type; // 'pemasukan' atau 'pengeluaran'
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _type = widget.itemToEdit!.type;
      _sourceController.text = widget.itemToEdit!.source;
      final amountInt = widget.itemToEdit!.amount.toInt();
      _amountController.text = NumberFormat('#,###', 'id_ID').format(amountInt).replaceAll(',', '.');
      _descController.text = widget.itemToEdit!.description;
      try {
        _selectedDate = DateTime.parse(widget.itemToEdit!.transactionDate);
      } catch (_) {
        _selectedDate = DateTime.now();
      }
    } else {
      _type = widget.initialType ?? 'pemasukan';
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final effectiveInitial = _selectedDate.isAfter(now)
        ? now
        : (_selectedDate.isBefore(DateTime(2026, 11, 1)) ? DateTime(2026, 11, 1) : _selectedDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: effectiveInitial,
      firstDate: DateTime(2026, 11, 1),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _type == 'pemasukan' ? AppTheme.incomeColor : AppTheme.expenseColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final cleanDigits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(cleanDigits) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal harus lebih dari 0'),
          backgroundColor: AppTheme.expenseColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (widget.itemToEdit != null) {
      // Edit
      final updated = widget.itemToEdit!.copyWith(
        type: _type,
        source: _sourceController.text.trim(),
        amount: amount,
        description: _descController.text.trim(),
        transactionDate: formattedDate,
        updatedAt: DateTime.now().toIso8601String(),
      );

      final res = await widget.provider.editTransaction(updated);
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message),
            backgroundColor: res.success ? AppTheme.primary : AppTheme.expenseColor,
          ),
        );
        if (res.success) Navigator.pop(context);
      }
    } else {
      // Add
      final res = await widget.provider.addTransaction(
        type: _type,
        source: _sourceController.text.trim(),
        amount: amount,
        description: _descController.text.trim(),
        transactionDate: formattedDate,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message),
            backgroundColor: res.success ? AppTheme.primary : AppTheme.expenseColor,
          ),
        );
        if (res.success) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == 'pemasukan';
    final activeColor = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemToEdit != null ? 'Edit Transaksi' : 'Catat Transaksi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Type Selector: Pemasukan di KIRI, Pengeluaran di KANAN
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    // Pemasukan (Kiri)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'pemasukan';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isIncome ? AppTheme.incomeColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isIncome
                                ? [
                                    BoxShadow(
                                      color: AppTheme.incomeColor.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pemasukan',
                            style: TextStyle(
                              color: isIncome ? Colors.white : AppTheme.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Pengeluaran (Kanan)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'pengeluaran';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isIncome ? AppTheme.expenseColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !isIncome
                                ? [
                                    BoxShadow(
                                      color: AppTheme.expenseColor.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pengeluaran',
                            style: TextStyle(
                              color: !isIncome ? Colors.white : AppTheme.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nominal Card Field dengan Pemisah Titik Standar Indonesia & Awalan Rp. Selalu Muncul
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: activeColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nominal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: activeColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Rp. ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: activeColor,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                ThousandsSeparatorInputFormatter(),
                              ],
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: activeColor,
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: activeColor.withValues(alpha: 0.35),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Nominal wajib diisi';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sumber
              const Text(
                'Sumber',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sourceController,
                decoration: InputDecoration(
                  hintText: isIncome ? 'Masukkan Sumber Pemasukan' : 'Masukkan Sumber Pengeluaran',
                  prefixIcon: Icon(isIncome ? Icons.account_balance_wallet_outlined : Icons.shopping_bag_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Sumber wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tanggal Transaksi
              const Text(
                'Tanggal Transaksi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppTheme.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textDark),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Keterangan Tambahan
              const Text(
                'Catatan Tambahan (Opsional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Masukkan Keterangan Tambahan',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        widget.itemToEdit != null ? 'Perbarui Transaksi' : 'Simpan Transaksi',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
