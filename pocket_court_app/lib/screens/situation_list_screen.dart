import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_transitions.dart';
import '../widgets/error_view.dart';
import 'law_detail_screen.dart';

class SituationListScreen extends StatefulWidget {
  final String category;
  final List<Color> gradient;

  const SituationListScreen({
    super.key,
    required this.category,
    this.gradient = const [AppTheme.indigo, AppTheme.indigoLight],
  });

  @override
  State<SituationListScreen> createState() => _SituationListScreenState();
}

class _SituationListScreenState extends State<SituationListScreen> {
  late Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getSituations(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
              title: Text(widget.category,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: widget.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                ),
              ),
            ),
          ),
          FutureBuilder<List<String>>(
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
                    onRetry: () => setState(() =>
                        _future = ApiService.getSituations(widget.category)),
                  ),
                );
              }
              final situations = snapshot.data!;
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _SituationTile(
                      situation: situations[i],
                      index: i,
                      gradient: widget.gradient,
                      onTap: () => Navigator.push(
                          context,
                          SlideUpRoute(
                            page: LawDetailScreen(
                              category: widget.category,
                              situation: situations[i],
                              accentColor: widget.gradient.first,
                            ),
                          )),
                    ),
                    childCount: situations.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SituationTile extends StatelessWidget {
  final String situation;
  final int index;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _SituationTile(
      {required this.situation,
      required this.index,
      required this.gradient,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
          title: Text(situation,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: gradient.first.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: gradient.first),
          ),
        ),
      ),
    );
  }
}
