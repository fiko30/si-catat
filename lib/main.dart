import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/transaction_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale bahasa Indonesia untuk format tanggal
  await initializeDateFormatting('id_ID', null);

  final transactionProvider = TransactionProvider();

  runApp(SiCatatApp(provider: transactionProvider));
}

class SiCatatApp extends StatelessWidget {
  final TransactionProvider provider;
  const SiCatatApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Si Catat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(provider: provider),
    );
  }
}
