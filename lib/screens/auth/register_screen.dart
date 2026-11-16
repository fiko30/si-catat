import 'package:flutter/material.dart';
import '../../providers/transaction_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  final TransactionProvider provider;
  const RegisterScreen({super.key, required this.provider});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Real-time per-column error messages
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateName(String val) {
    setState(() {
      if (val.trim().isEmpty) {
        _nameError = null; // Tidak muncul sebelum user mengisi
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail(String val) {
    setState(() {
      if (val.trim().isEmpty) {
        _emailError = null;
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
        _passwordError = null;
      } else if (val.length < 6) {
        _passwordError = 'Password Minimal 6 Karakter';
      } else {
        _passwordError = null;
      }

      if (_confirmPasswordController.text.isNotEmpty) {
        if (_confirmPasswordController.text != val) {
          _confirmPasswordError = 'Konfirmasi Password Tidak Cocok';
        } else {
          _confirmPasswordError = null;
        }
      }
    });
  }

  void _validateConfirmPassword(String val) {
    setState(() {
      if (val.isEmpty) {
        _confirmPasswordError = null;
      } else if (val != _passwordController.text) {
        _confirmPasswordError = 'Konfirmasi Password Tidak Cocok';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    bool hasError = false;
    setState(() {
      if (name.isEmpty) {
        _nameError = 'Nama Lengkap Wajib Diisi';
        hasError = true;
      }

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

      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Konfirmasi Password Wajib Diisi';
        hasError = true;
      } else if (confirmPassword != password) {
        _confirmPasswordError = 'Konfirmasi Password Tidak Cocok';
        hasError = true;
      }
    });

    if (hasError) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.register(
      name: name,
      email: email,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.message}. Silakan masuk dengan akun baru Anda.'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      // Redirect kembali ke halaman login
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
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
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'Daftar Akun Baru',
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
                    'Mulai catat transaksi harianmu dengan rapi',
                    style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 24),

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

                // Nama Lengkap
                const Text(
                  'Nama Lengkap',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  onChanged: _validateName,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama Lengkap Anda',
                    prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textMuted),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _nameError != null ? AppTheme.expenseColor : AppTheme.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _nameError != null ? AppTheme.expenseColor : AppTheme.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                if (_nameError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _nameError!,
                      style: const TextStyle(color: AppTheme.expenseColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Email
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
                if (_emailError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _emailError!,
                      style: const TextStyle(color: AppTheme.expenseColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Password
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
                if (_passwordError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _passwordError!,
                      style: const TextStyle(color: AppTheme.expenseColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Konfirmasi Password
                const Text(
                  'Konfirmasi Password',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onChanged: _validateConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Ulangi Password Anda',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _confirmPasswordError != null ? AppTheme.expenseColor : AppTheme.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _confirmPasswordError != null ? AppTheme.expenseColor : AppTheme.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                if (_confirmPasswordError != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _confirmPasswordError!,
                      style: const TextStyle(color: AppTheme.expenseColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Daftar'),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk',
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
