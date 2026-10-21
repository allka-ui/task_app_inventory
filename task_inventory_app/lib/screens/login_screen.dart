import 'package:flutter/material.dart';

import '../models/item_model.dart';
import 'admin_dashboard.dart';
import 'register_screen.dart';
import 'user_dashboard.dart';

const _kGradientStart = Color(0xFF4F46E5);
const _kGradientEnd = Color(0xFF7C3AED);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.user;
  bool _obscure = true;
  bool _loading = false;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    if (!value.contains('@')) {
      return 'Email tidak valid';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  String _roleDescription(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'User hanya dapat melihat data.';
      case UserRole.admin:
        return 'Admin dapat menambah, mengubah, dan menghapus data.';
      case UserRole.adminSuper:
        return 'Super Admin dapat mengelola semua data dan akun.';
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loginError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final emailInput = _emailController.text.trim().toLowerCase();
    final passwordInput = _passwordController.text;

    UserAccount? found;

    for (final user in AppData.users) {
      if (user.email.toLowerCase() == emailInput &&
          user.password == passwordInput) {
        found = user;
        break;
      }
    }

    if (found == null) {
      setState(() {
        _loading = false;
        _loginError = 'Email atau password salah';
      });
      return;
    }


    
if (found.isRejected) {
  setState(() {
    _loading = false;
    _loginError = 'Pendaftaran akun ditolak oleh admin.';
  });
  return;
}

if (!found.isApproved) {
  setState(() {
    _loading = false;
    _loginError = 'Akun belum disetujui admin.';
  });
  return;
}


    if (found.role != _selectedRole) {
      // Hitung pesan di luar closure setState: di dalam closure, 'found'
      // (nullable) tidak otomatis dianggap non-null oleh Dart.
      final roleLabel = found.role.label;
      setState(() {
        _loading = false;
        _loginError = 'Akun ini terdaftar sebagai $roleLabel. '
            'Pilih "$roleLabel" untuk masuk.';
      });
      return;
    }

    AppData.currentUser = found;

    final Widget target =
        found.isAdmin ? const AdminDashboard() : const UserDashboard();

    setState(() {
      _loading = false;
    });

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => target,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kGradientStart, _kGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo sekolah
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_smkn1.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 96,
                            height: 96,
                            child: Icon(
                              Icons.school_rounded,
                              size: 56,
                              color: _kGradientStart,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'SMKN 1 Beringin\nTask & Inventory Manager',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Masuk untuk mengelola data kamu',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Pilihan User atau Admin
                          SegmentedButton<UserRole>(
                            segments: const [
                              ButtonSegment<UserRole>(
                                value: UserRole.user,
                                label: Text('User'),
                              ),
                              ButtonSegment<UserRole>(
                                value: UserRole.admin,
                                label: Text('Admin'),
                              ),
                              ButtonSegment<UserRole>(
                                value: UserRole.adminSuper,
                                label: Text('Super Admin'),
                              ),
                            ],
                            selected: {_selectedRole},
                            showSelectedIcon: false,
                            onSelectionChanged: (selection) {
                              setState(() {
                                _selectedRole = selection.first;
                                _loginError = null;
                              });
                            },
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor:
                                  _kGradientStart.withValues(alpha: 0.12),
                              selectedForegroundColor: _kGradientStart,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            _roleDescription(_selectedRole),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Username/email',
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                              ),
                            ),
                            validator: _validateEmail,
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                              ),
                            ),
                            validator: _validatePassword,
                          ),

                          if (_loginError != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _loginError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 22),

                          ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kGradientStart,
                              foregroundColor: Colors.white,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Masuk sebagai ${_selectedRole.label}'),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun?',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Daftar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}