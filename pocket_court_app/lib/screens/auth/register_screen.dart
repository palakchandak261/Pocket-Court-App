import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl  = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  int  _passStrength = 0; // 0–4

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() {
      setState(() => _passStrength = _calcStrength(_passCtrl.text));
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // ── Password strength calculator ──────────────────────────────────────────
  int _calcStrength(String p) {
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 6)  score++;
    if (p.length >= 10) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score.clamp(0, 4);
  }

  Color get _strengthColor {
    switch (_passStrength) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.amber.shade700;
      case 4: return Colors.green;
      default: return Colors.grey.shade300;
    }
  }

  String get _strengthLabel {
    switch (_passStrength) {
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong';
      default: return '';
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
        phone: _phoneCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainNavigation()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.indigoDark, AppTheme.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
                const Text('Create Account',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Join Pocket Court today',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _field(_nameCtrl, 'Full Name', Icons.person_outline,
                            validator: (v) =>
                                v!.trim().length >= 2 ? null : 'Min 2 characters'),
                        const SizedBox(height: 14),
                        _field(_emailCtrl, 'Email', Icons.email_outlined,
                            keyboard: TextInputType.emailAddress,
                            validator: (v) => v!.contains('@')
                                ? null
                                : 'Enter a valid email'),
                        const SizedBox(height: 14),

                        // ── Password field ──────────────────────────────────
                        _field(_passCtrl, 'Password', Icons.lock_outline,
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) =>
                                v!.length >= 6 ? null : 'Min 6 characters'),

                        // ── Password strength bar ───────────────────────────
                        if (_passCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _passStrength / 4,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _strengthColor),
                                    minHeight: 5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(_strengthLabel,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _strengthColor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Use uppercase, numbers & symbols for a stronger password',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],

                        const SizedBox(height: 14),
                        _field(_phoneCtrl, 'Phone (optional)',
                            Icons.phone_outlined,
                            keyboard: TextInputType.phone),
                        const SizedBox(height: 14),
                        _field(_cityCtrl, 'City (optional)',
                            Icons.location_city_outlined),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Text('Create Account',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                          ),
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
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.indigo),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.indigo, width: 1.5),
        ),
      ),
    );
  }
}
