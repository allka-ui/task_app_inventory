import 'package:flutter/material.dart';

import '../models/item_model.dart';

const _kGradientStart = Color(0xFF4F46E5); // indigo
const _kGradientEnd = Color(0xFF7C3AED); // violet

// =========================================================================
// SCREEN 2 — REGISTER
// Akun baru TIDAK langsung aktif: harus disetujui Super Admin dulu.
// Role yang dipilih di sini hanya permintaan; Super Admin yang menentukan.
// =========================================================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  UserRole _selectedRole = UserRole.user;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!v.contains('@')) return 'Email tidak valid';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi password tidak boleh kosong';
    if (v != _passwordController.text) return 'Password tidak sama';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // efek loading
    if (!mounted) return;

    final email = _emailController.text.trim().toLowerCase();

    final exists = AppData.users.any((u) => u.email.toLowerCase() == email);
    if (exists) {
      setState(() {
        _loading = false;
        _error = 'Email sudah terdaftar';
      });
      return;
    }

    // Akun baru berstatus menunggu persetujuan (isApproved = false).
    AppData.users.add(
      UserAccount(
        name: _nameController.text.trim(),
        email: email,
        password: _passwordController.text,
        role: _selectedRole,
        isApproved: false,
      ),
    );

    setState(() => _loading = false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.hourglass_top_rounded,
            color: _kGradientStart, size: 40),
        title: const Text('Pendaftaran Terkirim'),
        content: const Text(
          'Akun Anda menunggu persetujuan Super Admin. '
          'Anda baru bisa masuk setelah akun disetujui.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kGradientStart),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (mounted) Navigator.pop(context); // kembali ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _selectedRole == UserRole.admin;

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
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Buat Akun Baru',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Akun perlu disetujui Super Admin sebelum dapat digunakan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      const SizedBox(height: 24),
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
                              SegmentedButton<UserRole>(
                                segments: const [
                                  ButtonSegment(
                                    value: UserRole.user,
                                    label: Text('Siswa / User'),
                                    icon: Icon(Icons.school_rounded),
                                  ),
                                  ButtonSegment(
                                    value: UserRole.admin,
                                    label: Text('Admin'),
                                    icon: Icon(
                                        Icons.admin_panel_settings_rounded),
                                  ),
                                ],
                                selected: {_selectedRole},
                                showSelectedIcon: false,
                                onSelectionChanged: (s) =>
                                    setState(() => _selectedRole = s.first),
                                style: SegmentedButton.styleFrom(
                                  selectedBackgroundColor:
                                      _kGradientStart.withValues(alpha: 0.12),
                                  selectedForegroundColor: _kGradientStart,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isAdmin
                                    ? 'Pendaftaran admin akan diperiksa Super Admin.'
                                    : 'Siswa hanya dapat melihat data.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12.5),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Nama lengkap',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: _validateName,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon:
                                      Icon(Icons.person_outline_rounded),
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _obscure,
                                decoration: const InputDecoration(
                                  labelText: 'Konfirmasi password',
                                  prefixIcon: Icon(Icons.lock_outline_rounded),
                                ),
                                validator: _validateConfirm,
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        color: Colors.red, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 13),
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
                                    : const Text('Daftar'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Sudah punya akun?',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13)),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Masuk'),
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
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}