import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/law_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_transitions.dart';
import '../widgets/error_view.dart';
import 'law_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _historyKey = 'search_history';
  static const _maxHistory = 8;

  List<LawModel> _all = [];
  List<LawModel> _filtered = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  List<String> _history = [];

  final _ctrl   = TextEditingController();
  final _focusNode = FocusNode();

  static const _popular = [
    'Drunk driving',
    'UPI fraud',
    'Domestic violence',
    'Cheque bounce',
    'Cyber bullying',
    'Minimum wage',
    'Eve teasing',
    'Hit and run',
    'Security deposit',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _loadHistory();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> _load() async {
    try {
      final laws = await ApiService.getAllLaws();
      if (!mounted) return;
      setState(() {
        _all = laws;
        _filtered = laws;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Search history ────────────────────────────────────────────────────────
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    if (mounted) setState(() => _history = raw);
  }

  Future<void> _addToHistory(String term) async {
    if (term.trim().isEmpty) return;
    final updated = [
      term,
      ..._history.where((h) => h.toLowerCase() != term.toLowerCase()),
    ].take(_maxHistory).toList();
    setState(() => _history = updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, updated);
  }

  Future<void> _removeFromHistory(String term) async {
    final updated = _history.where((h) => h != term).toList();
    setState(() => _history = updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, updated);
  }

  Future<void> _clearHistory() async {
    setState(() => _history = []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── Search logic ──────────────────────────────────────────────────────────
  void _onSearch(String q) {
    final lower = q.toLowerCase().trim();
    setState(() {
      _query = q;
      _filtered = lower.isEmpty
          ? _all
          : _all.where((l) {
              return l.situation.toLowerCase().contains(lower) ||
                  l.category.toLowerCase().contains(lower) ||
                  l.act.toLowerCase().contains(lower) ||
                  l.section.toLowerCase().contains(lower);
            }).toList();
    });
  }

  void _submitSearch(String term) {
    if (term.trim().isEmpty) return;
    _ctrl.text = term;
    _onSearch(term);
    _addToHistory(term.trim());
    _focusNode.unfocus();
  }

  void _clearSearch() {
    _ctrl.clear();
    _onSearch('');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _color(String category) => AppTheme
      .categoryGradients[
          category.hashCode.abs() % AppTheme.categoryGradients.length]
      .first;

  Widget _highlight(String text, {TextStyle? style}) {
    if (_query.isEmpty) return Text(text, style: style);
    final lower = text.toLowerCase();
    final q = _query.toLowerCase().trim();
    final start = lower.indexOf(q);
    if (start == -1) return Text(text, style: style);
    final end = start + q.length;
    return RichText(
      text: TextSpan(
        style: style ??
            TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black87),
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
              text: text.substring(start, end),
              style: const TextStyle(
                  backgroundColor: Color(0xFFFFF176),
                  fontWeight: FontWeight.w700)),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }

  // ── Law card ──────────────────────────────────────────────────────────────
  Widget _lawCard(LawModel law) {
    final color = _color(law.category);
    return GestureDetector(
      onTap: () {
        _addToHistory(_query.trim().isNotEmpty ? _query.trim() : law.situation);
        Navigator.push(
            context,
            SlideUpRoute(
              page: LawDetailScreen(
                  category: law.category,
                  situation: law.situation,
                  accentColor: color),
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.gavel_rounded, color: color, size: 20),
          ),
          title: _highlight(law.situation,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(law.category,
                    style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(law.section,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ),
            ]),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: Colors.grey.shade400),
        ),
      ),
    );
  }

  // ── Empty state (no query) ────────────────────────────────────────────────
  Widget _emptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_history.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.history_rounded,
                      size: 16, color: AppTheme.indigo),
                  const SizedBox(width: 6),
                  Text('Recent Searches',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700)),
                ]),
                GestureDetector(
                  onTap: _clearHistory,
                  child: Text('Clear all',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._history.map((term) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history_rounded,
                      size: 18, color: Colors.grey),
                  title: Text(term,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.grey),
                    onPressed: () => _removeFromHistory(term),
                  ),
                  onTap: () => _submitSearch(term),
                )),
            const Divider(height: 28),
          ],

          // Popular searches
          Row(children: [
            const Icon(Icons.local_fire_department_rounded,
                size: 16, color: AppTheme.indigo),
            const SizedBox(width: 6),
            Text('Popular Searches',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700)),
          ]),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popular
                .map((term) => GestureDetector(
                      onTap: () => _submitSearch(term),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  AppTheme.indigo.withValues(alpha: 0.25)),
                        ),
                        child: Text(term,
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.indigo)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Laws'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              onChanged: _onSearch,
              onSubmitted: _submitSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search situation, category, act...',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppTheme.indigo),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Colors.grey),
                        onPressed: _clearSearch)
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppTheme.indigo, width: 1.5)),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorView(
                  message: _error!,
                  onRetry: () => setState(() {
                        _loading = true;
                        _error = null;
                        _load();
                      }))
              : Column(children: [
                  if (_query.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            '${_filtered.length} result${_filtered.length == 1 ? '' : 's'}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                      ),
                    ),
                  Expanded(
                    child: _query.isEmpty
                        ? _emptyState()
                        : _filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.search_off_rounded,
                                        size: 48,
                                        color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    Text('No results for "$_query"',
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 15)),
                                    const SizedBox(height: 6),
                                    Text('Try different keywords',
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 100),
                                itemCount: _filtered.length,
                                itemBuilder: (_, i) =>
                                    _lawCard(_filtered[i]),
                              ),
                  ),
                ]),
    );
  }
}
