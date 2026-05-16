import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/law_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Offline-first bookmark service.
/// - Logged-in users: syncs with backend, falls back to local cache on error.
/// - Guest users: local SharedPreferences only.
/// - Cache is cleared on logout to prevent data leaking between accounts.
class BookmarkService {
  static const _key = 'bookmarks';
  static List<LawModel>? _cache;

  // ── Read ──────────────────────────────────────────────────────────────────
  static Future<List<LawModel>> getAll() async {
    if (AuthService.isLoggedIn) {
      try {
        final res = await http.get(
          Uri.parse('${ApiService.baseUrl}/bookmarks'),
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 200) {
          final json = jsonDecode(res.body);
          _cache = (json['data'] as List).map((e) => LawModel.fromJson(e)).toList();
          await _persistLocal(); // keep local in sync with server
          return List.unmodifiable(_cache!);
        }
      } catch (_) {
        // Network error — fall through to local cache
      }
    }

    // Return in-memory cache if available
    if (_cache != null) return List.unmodifiable(_cache!);

    // Load from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _cache = raw.map((e) => LawModel.fromJson(jsonDecode(e))).toList();
    return List.unmodifiable(_cache!);
  }

  static Future<bool> isBookmarked(String category, String situation) async {
    final all = await getAll();
    return all.any((l) => l.category == category && l.situation == situation);
  }

  // ── Add ───────────────────────────────────────────────────────────────────
  static Future<void> add(LawModel law) async {
    final all = await getAll();
    if (all.any((l) => l.category == law.category && l.situation == law.situation)) return;

    if (AuthService.isLoggedIn) {
      try {
        await http.post(
          Uri.parse('${ApiService.baseUrl}/bookmarks'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          body: jsonEncode(law.toJson()),
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        // Silently continue — local save still happens below
      }
    }

    _cache = [...all, law];
    await _persistLocal();
  }

  // ── Remove ────────────────────────────────────────────────────────────────
  static Future<void> remove(String category, String situation) async {
    if (AuthService.isLoggedIn) {
      try {
        await http.delete(
          Uri.parse('${ApiService.baseUrl}/bookmarks'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          body: jsonEncode({'category': category, 'situation': situation}),
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        // Silently continue
      }
    }

    final all = await getAll();
    _cache = all.where((l) => !(l.category == category && l.situation == situation)).toList();
    await _persistLocal();
  }

  // ── Clear (called on logout) ──────────────────────────────────────────────
  static Future<void> clearCache() async {
    _cache = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ── Local persistence ─────────────────────────────────────────────────────
  static Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      (_cache ?? []).map((l) => jsonEncode(l.toJson())).toList(),
    );
  }
}
