import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_theme.dart';
import 'auth/login_screen.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  final TransactionProvider provider;
  const SplashScreen({super.key, required this.provider});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Check user login session
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Tunggu animasi splash screen sekitar 2.3 detik
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final user = await StorageService.getUser();
    if (user != null) {
      await widget.provider.init(user);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigation(provider: widget.provider),
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(provider: widget.provider),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Container
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Si Catat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola Keuangan Anda Dengan Mudah',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
