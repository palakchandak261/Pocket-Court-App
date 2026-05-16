import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _Contact {
  final String label;
  final String number;
  final IconData icon;
  final Color color;
  const _Contact(this.label, this.number, this.icon, this.color);
}

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});
  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  static const _mainNumber = '8007938009';

  static const _contacts = [
    _Contact('Women Helpline', '181', Icons.shield_rounded, Color(0xFF7B1FA2)),
    _Contact('Cyber Crime', '1930', Icons.security_rounded, Color(0xFF1565C0)),
    _Contact('Consumer Helpline', '1800114000', Icons.shopping_bag_rounded, Color(0xFF2E7D32)),
    _Contact('Legal Aid (NALSA)', '15100', Icons.gavel_rounded, Color(0xFFE65100)),
    _Contact('Police', '100', Icons.local_police_rounded, Color(0xFF1A237E)),
    _Contact('Ambulance', '108', Icons.local_hospital_rounded, Color(0xFFC62828)),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ── Pulsing SOS button (now tappable) ──────────────────────────
            GestureDetector(
              onTap: () => _call(_mainNumber),
              child: ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD32F2F),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10)
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emergency_rounded, color: Colors.white, size: 48),
                      SizedBox(height: 6),
                      Text('SOS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4)),
                      Text('Tap to Call',
                          style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _call(_mainNumber),
              child: const Text(_mainNumber,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD32F2F),
                      letterSpacing: 2,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFD32F2F))),
            ),
            const SizedBox(height: 4),
            const Text('Emergency Helpline — Tap to Call',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Other Helplines',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600)),
            ),
            const SizedBox(height: 12),
            // ── Helpline cards (all tappable) ───────────────────────────────
            ..._contacts.map((c) => GestureDetector(
                  onTap: () => _call(c.number),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: c.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(c.icon, color: c.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(c.number,
                                  style: TextStyle(
                                      color: c.color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      letterSpacing: 1)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: c.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.call_rounded, color: c.color, size: 14),
                              const SizedBox(width: 4),
                              Text('Call', style: TextStyle(color: c.color, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'Use this feature only in genuine emergencies. Misuse of emergency numbers is a punishable offence.',
                style: TextStyle(fontSize: 11, color: Colors.orange.shade900),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
