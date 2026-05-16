import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_transitions.dart';
import '../main.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Profile controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;

  // Email is read-only — use a fixed controller, disposed properly
  late final TextEditingController _emailCtrl;

  bool _loading = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final u = AuthService.currentUser;
    _nameCtrl  = TextEditingController(text: u?.name ?? '');
    _phoneCtrl = TextEditingController(text: u?.phone ?? '');
    _cityCtrl  = TextEditingController(text: u?.city ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Save profile ─────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.updateProfile(
          _nameCtrl.text.trim(), _phoneCtrl.text.trim(), _cityCtrl.text.trim());
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Change password dialog ────────────────────────────────────────────────
  Future<void> _showChangePasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey     = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew     = true;
    bool saving         = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Change Password',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current password
                TextFormField(
                  controller: currentCtrl,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setDialogState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                // New password
                TextFormField(
                  controller: newCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  validator: (v) =>
                      v!.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 12),
                // Confirm password
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_rounded),
                  ),
                  validator: (v) =>
                      v == newCtrl.text ? null : 'Passwords do not match',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => saving = true);
                      try {
                        await AuthService.changePassword(
                            currentCtrl.text, newCtrl.text);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Password changed successfully')));
                        }
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text(e
                                  .toString()
                                  .replaceAll('Exception: ', ''))));
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Change'),
            ),
          ],
        ),
      ),
    );

    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      SlideUpRoute(page: const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final initials = (user?.name ?? 'U')
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .take(2)
        .join();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _editing = true),
            )
          else
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.indigo, AppTheme.indigoLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.indigo.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.name ?? '',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(user?.email ?? '',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 28),

            // ── Profile form ─────────────────────────────────────────────────
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _tile(Icons.person_rounded, 'Full Name', _nameCtrl,
                      enabled: _editing,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  // Email — read-only, uses a proper class-level controller
                  _tile(Icons.email_rounded, 'Email', _emailCtrl, enabled: false),
                  const SizedBox(height: 12),
                  _tile(Icons.phone_rounded, 'Phone', _phoneCtrl,
                      enabled: _editing, keyboard: TextInputType.phone),
                  const SizedBox(height: 12),
                  _tile(Icons.location_city_rounded, 'City', _cityCtrl,
                      enabled: _editing),
                ],
              ),
            ),

            if (_editing) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // ── Theme toggle ─────────────────────────────────────────────────
            ListTile(
              leading: Icon(
                themeService.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppTheme.indigo,
              ),
              title: Text(themeService.isDark ? 'Dark Mode' : 'Light Mode',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  themeService.isDark ? 'Switch to light theme' : 'Switch to dark theme',
                  style: const TextStyle(fontSize: 12)),
              trailing: Switch(
                value: themeService.isDark,
                activeThumbColor: AppTheme.indigo,
                onChanged: (_) => themeService.toggle(),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),

            const SizedBox(height: 8),

            // ── Change password ──────────────────────────────────────────────
            if (AuthService.isLoggedIn)
              ListTile(
                leading: const Icon(Icons.lock_reset_rounded, color: AppTheme.indigo),
                title: const Text('Change Password',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Update your account password',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: _showChangePasswordDialog,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),

            const SizedBox(height: 16),

            // ── Sign out ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text('Sign Out',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String label,
    TextEditingController ctrl, {
    bool enabled = true,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? AppTheme.indigo : Colors.grey.shade400),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.indigo, width: 1.2)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
    );
  }
}
