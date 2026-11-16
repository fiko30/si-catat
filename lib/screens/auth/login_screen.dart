import 'package:flutter/material.dart';
import '../../providers/transaction_provider.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import '../main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final TransactionProvider provider;
  const LoginScreen({super.key, required this.provider});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Real-time per-column error messages
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail(String val) {
    setState(() {
      if (val.trim().isEmpty) {
        _emailError = null; // Jangan munculkan sebelum user mengisi
      } else if (!val.contains('@') || !val.contains('.')) {
        _emailError = 'Format Email Tidak Valid (Contoh: nama@gmail.com)';
      } else if (!val.toLowerCase().endsWith('@gmail.com')) {
        _emailError = 'Harus Menyertakan Domain @gmail.com Yang Valid';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String val) {
    setState(() {
      if (val.isEmpty) {
        _passwordError = null; // Jangan munculkan sebelum user mengisi
      } else if (val.length < 6) {
        _passwordError = 'Password Minimal 6 Karakter';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validasi saat submit
    bool hasError = false;
    setState(() {
      if (email.isEmpty) {
        _emailError = 'Email Wajib Diisi';
        hasError = true;
      } else if (!email.contains('@') || !email.contains('.')) {
        _emailError = 'Format Email Tidak Valid (Contoh: nama@gmail.com)';
        hasError = true;
      } else if (!email.toLowerCase().endsWith('@gmail.com')) {
        _emailError = 'Harus Menyertakan Domain @gmail.com Yang Valid';
        hasError = true;
      }

      if (password.isEmpty) {
        _passwordError = 'Password Wajib Diisi';
        hasError = true;
      } else if (password.length < 6) {
        _passwordError = 'Password Minimal 6 Karakter';
        hasError = true;
      }
    });

    if (hasError) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.login(
      email: email,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.success && result.data != null) {
      final user = result.data!;
      await StorageService.saveUser(user);
      await widget.provider.init(user);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigation(provider: widget.provider),
        ),
      );
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  void _showForgotPasswordDialog() {
    // Kotak email lupa password dibuka bersih (kosong), tidak mengambil apa yang diketik di login
    final emailForgotController = TextEditingController();
    bool isSending = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Lupa Password?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan email akun Anda. Kami akan mengirimkan password Anda langsung ke email tersebut.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailForgotController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) {
                  setDialogState(() {
                    if (val.trim().isEmpty) {
                      dialogError = null;
                    } else if (!val.contains('@') || !val.contains('.')) {
                      dialogError = 'Format Email Tidak Valid (Contoh: nama@gmail.com)';
                    } else if (!val.toLowerCase().endsWith('@gmail.com')) {
                      dialogError = 'Harus Menyertakan Domain @gmail.com Yang Valid';
                    } else {
                      dialogError = null;
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan Email Anda',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: dialogError != null ? AppTheme.expenseColor : AppTheme.borderColor,
                    ),
                  ),
                ),
              ),
              if (dialogError != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dialogError!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.expenseColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final email = emailForgotController.text.trim();
                      if (email.isEmpty) {
                        setDialogState(() {
                          dialogError = 'Email Wajib Diisi';
                        });
                        return;
                      } else if (!email.toLowerCase().endsWith('@gmail.com')) {
                        setDialogState(() {
                          dialogError = 'Harus Menyertakan Domain @gmail.com Yang Valid';
                        });
                        return;
                      }

                      setDialogState(() {
                        isSending = true;
                        dialogError = null;
                      });

                      final res = await ApiService.forgotPassword(email);

                      setDialogState(() {
                        isSending = false;
                      });

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.message),
                            backgroundColor: res.success ? AppTheme.primary : AppTheme.expenseColor,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Kirim Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo & Title
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Selamat Datang di Si Catat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Masuk untuk mengelola keuangan harianmu',
                    style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 32),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.expenseColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.expenseColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.expenseColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppTheme.expenseColor, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Field
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _validateEmail,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Email Anda',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textMuted),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _emailError != null ? AppTheme.expenseColor : AppTheme.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _emailError != null ? AppTheme.expenseColor : AppTheme.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                // Alert Tepat di Ujung Kiri Kotak Input
                if (_emailError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _emailError!,
                      style: const TextStyle(
                        color: AppTheme.expenseColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                // Password Field
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: _validatePassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Password Anda',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _passwordError != null ? AppTheme.expenseColor : AppTheme.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _passwordError != null ? AppTheme.expenseColor : AppTheme.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                // Alert Tepat di Ujung Kiri Kotak Input
                if (_passwordError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _passwordError!,
                      style: const TextStyle(
                        color: AppTheme.expenseColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Lupa Password Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Masuk'),
                ),
                const SizedBox(height: 20),

                // Navigate to Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(provider: widget.provider),
                          ),
                        );
                      },
                      child: const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
