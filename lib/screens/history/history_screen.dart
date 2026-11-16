import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../transaction/add_edit_transaction_screen.dart';

class HistoryScreen extends StatefulWidget {
  final TransactionProvider provider;
  const HistoryScreen({super.key, required this.provider});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  String _typeFilter = 'semua'; // 'semua', 'pemasukan', 'pengeluaran'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default dimulai dari real-time (Tahun 2026, Bulan 11 / November)
    _selectedYear = now.year < 2026 ? 2026 : now.year;
    _selectedMonth = (_selectedYear == 2026 && now.month < 11) ? 11 : now.month;
  }

  void _showModernCalendarPicker(BuildContext context) {
    final now = DateTime.now();
    // Real-time: Mulai dari November 2026 hingga bulan dan tahun saat ini
    final int currentYear = now.year < 2026 ? 2026 : now.year;
    final int currentMonth = (now.year < 2026) ? 11 : now.month;

    int tempYear = _selectedYear > currentYear ? currentYear : (_selectedYear < 2026 ? 2026 : _selectedYear);
    int tempMonth = _selectedMonth;
    if (tempYear == 2026 && tempMonth < 11) tempMonth = 11;
    if (tempYear == currentYear && tempMonth > currentMonth) tempMonth = currentMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setPickerState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header: Judul & Pemilih Tahun Modern (Real-Time: Tidak bisa melebihi tahun sekarang)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Periode',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                size: 20,
                                color: tempYear > 2026 ? AppTheme.textDark : Colors.grey.shade300,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              // Tahun tidak boleh sebelum 2026
                              onPressed: () {
                                if (tempYear > 2026) {
                                  setPickerState(() {
                                    tempYear--;
                                    if (tempYear == 2026 && tempMonth < 11) {
                                      tempMonth = 11;
                                    }
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pencatatan keuangan dimulai dari tahun 2026.'),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.black87,
                                    ),
                                  );
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                tempYear.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: tempYear < currentYear ? AppTheme.textDark : Colors.grey.shade300,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              // Tahun tidak boleh melebihi tahun saat ini (belum tahun 2027)
                              onPressed: () {
                                if (tempYear < currentYear) {
                                  setPickerState(() {
                                    tempYear++;
                                    if (tempYear == currentYear && tempMonth > currentMonth) {
                                      tempMonth = currentMonth;
                                    }
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tahun 2027 belum tiba (Belum Real-Time).'),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.black87,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grid Bulan Modern (Real-Time: Nov 2026 s/d bulan saat ini)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final monthNum = index + 1;
                      final monthName = CurrencyFormatter.getMonthName(monthNum).substring(0, 3);

                      // Logika Real-Time Ketat:
                      // 1. Tahun 2026: Hanya bulan November (11) sampai bulan saat ini (November / 11)
                      //    Jan - Okt belum mulai, Des belum tiba!
                      // 2. Tahun berjalan: Hanya sampai bulan saat ini
                      bool isAllowed = false;
                      if (tempYear == 2026) {
                        isAllowed = (monthNum >= 11 && monthNum <= currentMonth);
                      } else if (tempYear > 2026 && tempYear <= currentYear) {
                        isAllowed = (tempYear < currentYear) ? true : (monthNum <= currentMonth);
                      }

                      final bool isSelected = (monthNum == tempMonth);

                      return InkWell(
                        onTap: isAllowed
                            ? () {
                                setState(() {
                                  _selectedMonth = monthNum;
                                  _selectedYear = tempYear;
                                });
                                Navigator.pop(ctx);
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      (tempYear == currentYear && monthNum > currentMonth)
                                          ? 'Bulan ${CurrencyFormatter.getMonthName(monthNum)} $tempYear belum tiba (Belum Real-Time).'
                                          : 'Pencatatan dimulai dari bulan November 2026.',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.black87,
                                  ),
                                );
                              },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : isAllowed
                                    ? Colors.grey.shade50
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : isAllowed
                                      ? AppTheme.borderColor
                                      : Colors.transparent,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            monthName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : isAllowed
                                      ? AppTheme.textDark
                                      : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionModel item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.isIncome ? 'Detail Pemasukan' : 'Detail Pengeluaran',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isIncome
                          ? AppTheme.incomeColor.withValues(alpha: 0.12)
                          : AppTheme.expenseColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: item.isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                CurrencyFormatter.format(item.amount),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: item.isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Sumber', item.source),
              _buildDetailRow('Tanggal', CurrencyFormatter.formatDate(item.transactionDate)),
              if (item.description.isNotEmpty) _buildDetailRow('Keterangan', item.description),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Tombol Edit di KIRI
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditTransactionScreen(
                              provider: widget.provider,
                              itemToEdit: item,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Hapus di KANAN
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.expenseColor,
                        side: const BorderSide(color: AppTheme.expenseColor),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmDelete(context, item);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TransactionModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text('Apakah kamu yakin ingin menghapus "${item.source}" (${CurrencyFormatter.format(item.amount)})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expenseColor),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await widget.provider.deleteTransaction(item.transactionId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.message),
                    backgroundColor: res.success ? AppTheme.primary : AppTheme.expenseColor,
                  ),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final monthlyList = widget.provider.getFilteredTransactions(_selectedMonth, _selectedYear);

        final displayList = monthlyList.where((t) {
          if (_typeFilter == 'pemasukan') return t.isIncome;
          if (_typeFilter == 'pengeluaran') return !t.isIncome;
          return true;
        }).toList();

        final monthIncome = monthlyList.where((t) => t.isIncome).fold(0.0, (sum, i) => sum + i.amount);
        final monthExpense = monthlyList.where((t) => !t.isIncome).fold(0.0, (sum, i) => sum + i.amount);
        final monthNet = monthIncome - monthExpense;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Riwayat Keuangan'),
          ),
          body: Column(
            children: [
              // Filter Bar Sesuai Permintaan: [Semua] [Pemasukan] [Pengeluaran] + Icon Kalender Modern (Responsive & Tidak keluar frame)
              Container(
                color: Colors.white,
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterChip('semua', 'Semua'),
                      const SizedBox(width: 6),
                      _buildFilterChip('pemasukan', 'Pemasukan'),
                      const SizedBox(width: 6),
                      _buildFilterChip('pengeluaran', 'Pengeluaran'),
                      const SizedBox(width: 8),
                      // Tombol Kalender Modern
                      InkWell(
                        onTap: () => _showModernCalendarPicker(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${CurrencyFormatter.getMonthName(_selectedMonth).substring(0, 3)} $_selectedYear',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.arrow_drop_down, color: AppTheme.primary, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Monthly Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Masuk', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(monthIncome),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.incomeColor,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 24, width: 1, color: AppTheme.borderColor),
                      Column(
                        children: [
                          const Text('Keluar', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(monthExpense),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.expenseColor,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 24, width: 1, color: AppTheme.borderColor),
                      Column(
                        children: [
                          const Text('Selisih', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(monthNet),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: monthNet >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Transaction List
              Expanded(
                child: displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada data transaksi di ${CurrencyFormatter.getMonthName(_selectedMonth)} $_selectedYear',
                              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: displayList.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = displayList[index];
                          final isIncome = item.isIncome;

                          return Dismissible(
                            key: Key(item.transactionId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppTheme.expenseColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            confirmDismiss: (dir) async {
                              _confirmDelete(context, item);
                              return false;
                            },
                            child: InkWell(
                              onTap: () => _showTransactionDetails(context, item),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isIncome
                                            ? AppTheme.incomeColor.withValues(alpha: 0.12)
                                            : AppTheme.expenseColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                        color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.source,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            CurrencyFormatter.formatDate(item.transactionDate),
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(item.amount)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _typeFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _typeFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}
