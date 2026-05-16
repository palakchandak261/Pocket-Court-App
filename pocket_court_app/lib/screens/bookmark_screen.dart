import 'package:flutter/material.dart';
import '../models/law_model.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_transitions.dart';
import 'law_detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});
  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<LawModel> _all = [];
  List<LawModel> _filtered = [];
  bool _loading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await BookmarkService.getAll();
    if (!mounted) return;
    setState(() {
      _all = List.from(data);
      _applyFilter(_selectedCategory);
      _loading = false;
    });
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  List<String> get _categories {
    final cats = _all.map((l) => l.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  void _applyFilter(String category) {
    _selectedCategory = category;
    _filtered = category == 'All'
        ? List.from(_all)
        : _all.where((l) => l.category == category).toList();
  }

  // ── Remove ────────────────────────────────────────────────────────────────
  Future<void> _remove(LawModel law) async {
    await BookmarkService.remove(law.category, law.situation);
    setState(() {
      _all.removeWhere(
          (l) => l.category == law.category && l.situation == law.situation);
      _applyFilter(_selectedCategory);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Bookmark removed')));
  }

  Color _color(LawModel law) => AppTheme
      .categoryGradients[
          law.category.hashCode.abs() % AppTheme.categoryGradients.length]
      .first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Saved Laws${_all.isNotEmpty ? ' (${_all.length})' : ''}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _all.isEmpty
              ? _emptyState()
              : Column(
                  children: [
                    // ── Category filter chips ─────────────────────────────
                    if (_categories.length > 2)
                      SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final cat = _categories[i];
                            final selected = cat == _selectedCategory;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _applyFilter(cat)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppTheme.indigo
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.indigo
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // ── Results count ─────────────────────────────────────
                    if (_selectedCategory != 'All')
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_filtered.length} saved in $_selectedCategory',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                          ),
                        ),
                      ),

                    // ── List ──────────────────────────────────────────────
                    Expanded(
                      child: _filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No saved laws in "$_selectedCategory"',
                                style: TextStyle(
                                    color: Colors.grey.shade500),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 12, 16, 100),
                                itemCount: _filtered.length,
                                itemBuilder: (context, i) =>
                                    _bookmarkCard(_filtered[i]),
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  // ── Bookmark card ─────────────────────────────────────────────────────────
  Widget _bookmarkCard(LawModel law) {
    final color = _color(law);
    return Dismissible(
      key: Key('${law.category}_${law.situation}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Remove Bookmark'),
            content: Text(
                'Remove "${law.situation}" from saved laws?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Remove',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => _remove(law),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
              context,
              SlideUpRoute(
                page: LawDetailScreen(
                    category: law.category,
                    situation: law.situation,
                    accentColor: color),
              ));
          _load();
        },
        child: Container(
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
          child: Row(
            children: [
              // Colored left accent bar
              Container(
                width: 5,
                height: 72,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child:
                    Icon(Icons.bookmark_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(law.situation,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(law.category,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(law.section,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              // Swipe hint icon
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.swipe_left_rounded,
                    size: 16, color: Colors.grey.shade300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
                color: AppTheme.indigo.withValues(alpha: 0.07),
                shape: BoxShape.circle),
            child: const Icon(Icons.bookmark_border_rounded,
                size: 52, color: AppTheme.indigo),
          ),
          const SizedBox(height: 20),
          const Text('No saved laws yet',
              style:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tap the bookmark icon on any law\nto save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5)),
        ],
      ),
    );
  }
}
