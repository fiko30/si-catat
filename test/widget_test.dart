import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_catat/main.dart';
import 'package:si_catat/providers/transaction_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Si Catat Smoke Test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = TransactionProvider();
    await tester.pumpWidget(SiCatatApp(provider: provider));
    // Let the splash screen timer finish
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(SiCatatApp), findsOneWidget);
  });
}
