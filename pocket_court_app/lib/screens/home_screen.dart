import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_transitions.dart';
import '../widgets/error_view.dart';
import 'situation_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CategoryModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getCategories();
  }

  IconData _icon(String cat) {
    switch (cat.toLowerCase()) {
      case 'traffic rules':           return Icons.traffic_rounded;
      case 'consumer rights':         return Icons.shopping_bag_rounded;
      case 'criminal':                return Icons.gavel_rounded;
      case 'family':                  return Icons.family_restroom_rounded;
      case 'labour rights':           return Icons.work_rounded;
      case 'cyber crime':             return Icons.security_rounded;
      case 'women safety':            return Icons.shield_rounded;
      case 'public rights':           return Icons.people_rounded;
      case 'tenant rights':           return Icons.home_rounded;
      case 'environmental rights':    return Icons.eco_rounded;
      case 'banking rights':          return Icons.account_balance_rounded;
      case 'digital payments & upi safety': return Icons.payment_rounded;
      case 'road rage & public safety':     return Icons.car_crash_rounded;
      case 'rental & property issues':      return Icons.house_rounded;
      default:                        return Icons.balance_rounded;
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName {
    final name = AuthService.currentUser?.name ?? '';
    if (name.isEmpty) return '';
    return ', ${name.trim().split(' ').first}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async =>
            setState(() => _future = ApiService.getCategories()),
        child: CustomScrollView(
          slivers: [
            // ── Greeting + stats banner ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.indigoDark, AppTheme.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.indigo.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting$_firstName 👋',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Know your rights. Stay protected.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    FutureBuilder<List<CategoryModel>>(
                      future: _future,
                      builder: (context, snap) {
                        final cats = snap.data ?? [];
                        final totalSituations = cats.fold<int>(
                            0, (sum, c) => sum + c.situations.length);
                        return Row(
                          children: [
                            _statChip(
                                Icons.category_rounded,
                                '${cats.isEmpty ? '—' : cats.length}',
                                'Categories'),
                            const SizedBox(width: 12),
                            _statChip(
                                Icons.gavel_rounded,
                                totalSituations == 0 ? '—' : '$totalSituations',
                                'Laws Covered'),
                            const SizedBox(width: 12),
                            _statChip(Icons.verified_rounded, '100%', 'Free'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Section label ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(children: [
                  const Icon(Icons.grid_view_rounded,
                      size: 15, color: AppTheme.indigo),
                  const SizedBox(width: 6),
                  Text('Browse Categories',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700)),
                ]),
              ),
            ),

            // ── Category grid ───────────────────────────────────────────────
            FutureBuilder<List<CategoryModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: ErrorView(
                      message: snapshot.error.toString(),
                      onRetry: () => setState(
                          () => _future = ApiService.getCategories()),
                    ),
                  );
                }
                final cats = snapshot.data!;
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final gradient = AppTheme.categoryGradients[
                            i % AppTheme.categoryGradients.length];
                        return _CategoryCard(
                          category: cats[i],
                          gradient: gradient,
                          icon: _icon(cats[i].category),
                          onTap: () => Navigator.push(
                              context,
                              SlideUpRoute(
                                page: SituationListScreen(
                                    category: cats[i].category,
                                    gradient: gradient),
                              )),
                        );
                      },
                      childCount: cats.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard(
      {required this.category,
      required this.gradient,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: gradient.first.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category.category,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.3)),
                  const SizedBox(height: 3),
                  Text('${category.situations.length} situations',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
