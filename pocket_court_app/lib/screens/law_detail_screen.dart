import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/law_model.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_transitions.dart';
import '../widgets/error_view.dart';

class LawDetailScreen extends StatefulWidget {
  final String category;
  final String situation;
  final Color accentColor;

  const LawDetailScreen({
    super.key,
    required this.category,
    required this.situation,
    this.accentColor = AppTheme.indigo,
  });

  @override
  State<LawDetailScreen> createState() => _LawDetailScreenState();
}

class _LawDetailScreenState extends State<LawDetailScreen> {
  late Future<LawModel> _future;
  Future<List<LawModel>>? _relatedFuture;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getLaw(widget.category, widget.situation);
    _relatedFuture =
        ApiService.getRelatedLaws(widget.category, widget.situation);
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final saved =
        await BookmarkService.isBookmarked(widget.category, widget.situation);
    if (mounted) setState(() => _bookmarked = saved);
  }

  Future<void> _toggleBookmark(LawModel law) async {
    if (_bookmarked) {
      await BookmarkService.remove(law.category, law.situation);
      if (!mounted) return;
      setState(() => _bookmarked = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from bookmarks')));
    } else {
      await BookmarkService.add(law);
      if (!mounted) return;
      setState(() => _bookmarked = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved to bookmarks')));
    }
  }

  void _share(LawModel law) {
    Share.share(
      '⚖️ Pocket Court\n\n📌 ${law.situation}\n🏷️ ${law.category}\n📖 ${law.act}\n📄 ${law.section}\n💰 ${law.fine}\n🔖 ${law.article}\n\nShared via Pocket Court App',
      subject: 'Know Your Rights — ${law.situation}',
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _infoCard(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
        ),
      ),
    );
  }

  // ── Related law chip ──────────────────────────────────────────────────────
  Widget _relatedChip(LawModel law) {
    final color = AppTheme
        .categoryGradients[
            law.category.hashCode.abs() % AppTheme.categoryGradients.length]
        .first;
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        SlideUpRoute(
          page: LawDetailScreen(
            category: law.category,
            situation: law.situation,
            accentColor: color,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.gavel_rounded, color: color, size: 14),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                law.situation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 10, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<LawModel>(
        future: _future,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              // ── Collapsible app bar ───────────────────────────────────────
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                actions: [
                  if (snapshot.hasData) ...[
                    IconButton(
                      icon: const Icon(Icons.share_rounded,
                          color: Colors.white),
                      onPressed: () => _share(snapshot.data!),
                    ),
                    IconButton(
                      icon: Icon(
                        _bookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: _bookmarked ? AppTheme.amber : Colors.white,
                      ),
                      onPressed: () => _toggleBookmark(snapshot.data!),
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.fromLTRB(56, 0, 100, 16),
                  title: Text(widget.situation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.accentColor,
                          widget.accentColor.withValues(alpha: 0.7)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Loading / error ───────────────────────────────────────────
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(() => _future = ApiService.getLaw(
                        widget.category, widget.situation)),
                  ),
                )
              else ...[
                // ── Law details ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Category badge
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: widget.accentColor
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(snapshot.data!.category,
                              style: TextStyle(
                                  color: widget.accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info cards
                      _infoCard('Act', snapshot.data!.act,
                          Icons.menu_book_rounded, AppTheme.indigo),
                      _infoCard('Section', snapshot.data!.section,
                          Icons.article_rounded, const Color(0xFF00897B)),
                      _infoCard('Fine / Penalty', snapshot.data!.fine,
                          Icons.money_off_rounded, const Color(0xFFE53935)),
                      _infoCard(
                          'Constitutional Article',
                          snapshot.data!.article,
                          Icons.account_balance_rounded,
                          const Color(0xFF8E24AA)),
                      const SizedBox(height: 8),

                      // Share button
                      OutlinedButton.icon(
                        onPressed: () => _share(snapshot.data!),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share this Law'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.accentColor,
                          side: BorderSide(
                              color: widget.accentColor
                                  .withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ]),
                  ),
                ),

                // ── Related Laws ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: FutureBuilder<List<LawModel>>(
                    future: _relatedFuture,
                    builder: (context, relSnap) {
                      if (!relSnap.hasData || relSnap.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Row(children: [
                              Icon(Icons.link_rounded,
                                  size: 16, color: widget.accentColor),
                              const SizedBox(width: 6),
                              Text('Related Laws in ${widget.category}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade700)),
                            ]),
                          ),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(
                                  16, 0, 16, 0),
                              itemCount: relSnap.data!.length,
                              itemBuilder: (_, i) =>
                                  _relatedChip(relSnap.data![i]),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
