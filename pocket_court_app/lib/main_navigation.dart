import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/bookmark_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sos_screen.dart';
import 'widgets/app_transitions.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // IndexedStack keeps all screens alive — no re-fetch on tab switch
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    BookmarkScreen(),
  ];

  static const _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search_rounded),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_outline),
      activeIcon: Icon(Icons.bookmark_rounded),
      label: 'Saved',
    ),
  ];

  String get _initials {
    final name = AuthService.currentUser?.name ?? '';
    if (name.isEmpty) return '?';
    return name
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .take(2)
        .join();
  }

  void _openProfile() {
    Navigator.push(
      context,
      SlideUpRoute(page: const ProfileScreen()),
    ).then((_) {
      // Rebuild so greeting + initials reflect any profile changes
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.balance_rounded, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text('Pocket Court'),
          ],
        ),
        actions: [
          // ── Profile avatar button ───────────────────────────────────────
          GestureDetector(
            onTap: _openProfile,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.amber, AppTheme.amberDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.amber.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: AuthService.isLoggedIn
                    ? Text(_initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13))
                    : const Icon(Icons.person_rounded,
                        color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),

      // ── Screens ───────────────────────────────────────────────────────────
      body: IndexedStack(index: _currentIndex, children: _screens),

      // ── FABs: SOS + AI ────────────────────────────────────────────────────
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'sos',
            onPressed: () => Navigator.push(
                context, SlideUpRoute(page: const SosScreen())),
            backgroundColor: const Color(0xFFD32F2F),
            tooltip: 'Emergency SOS',
            child: const Icon(Icons.emergency_rounded, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'ai',
            onPressed: () => Navigator.push(
                context, SlideUpRoute(page: const AiChatScreen())),
            tooltip: 'AI Legal Assistant',
            child: const Icon(Icons.smart_toy_rounded),
          ),
        ],
      ),

      // ── Bottom nav ────────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: _navItems,
        ),
      ),
    );
  }
}
