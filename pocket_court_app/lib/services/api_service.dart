import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/law_model.dart';

/// Central API configuration.
/// Change [baseUrl] once here — everything else picks it up automatically.
///
/// For local Android emulator:  http://10.0.2.2:5000/api
/// For local physical device:   http://<YOUR_LAN_IP>:5000/api  (e.g. 192.168.1.5)
/// For production:               https://api.pocketcourt.app/api
class ApiService {
  // ── Base URL ──────────────────────────────────────────────────────────────
  // Production backend deployed on Render.
  static String get baseUrl => 'https://pocket-court-app-1.onrender.com/api';

  static const _timeout = Duration(seconds: 10);
  static const _headers = {'Content-Type': 'application/json'};

  // ── Internal helpers ──────────────────────────────────────────────────────
  static void _assertOk(http.Response res, String ctx) {
    if (res.statusCode != 200 && res.statusCode != 201) {
      final body = jsonDecode(res.body);
      final msg = body['message'] ?? '$ctx failed (${res.statusCode})';
      throw Exception(msg);
    }
  }

  static Future<http.Response> _get(String url,
      {Map<String, String>? extraHeaders}) async {
    try {
      final headers = {..._headers, ...?extraHeaders};
      return await http
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Is the backend running?');
    }
  }

  // ── Categories ────────────────────────────────────────────────────────────
  static Future<List<CategoryModel>> getCategories() async {
    final res = await _get('$baseUrl/categories');
    _assertOk(res, 'Load categories');
    return (jsonDecode(res.body)['data'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }

  static Future<List<String>> getSituations(String category) async {
    final res =
        await _get('$baseUrl/situations/${Uri.encodeComponent(category)}');
    _assertOk(res, 'Load situations');
    return List<String>.from(jsonDecode(res.body)['data']);
  }

  // ── Laws ──────────────────────────────────────────────────────────────────
  static Future<LawModel> getLaw(String category, String situation) async {
    try {
      final uri = Uri.parse('$baseUrl/law').replace(
          queryParameters: {'category': category, 'situation': situation});
      final res = await http.get(uri, headers: _headers).timeout(_timeout);
      _assertOk(res, 'Load law');
      return LawModel.fromJson(jsonDecode(res.body)['data']);
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Is the backend running?');
    }
  }

  /// Fetches all laws with optional server-side search + pagination.
  /// [query]    — full-text search term
  /// [category] — filter by category
  /// [page]     — page number (1-based)
  /// [limit]    — results per page
  static Future<List<LawModel>> getAllLaws({
    String? query,
    String? category,
    int page = 1,
    int limit = 200, // high default so search screen gets everything at once
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (query != null && query.isNotEmpty) 'q': query,
      if (category != null && category.isNotEmpty) 'category': category,
    };
    final uri = Uri.parse('$baseUrl/laws').replace(queryParameters: params);
    try {
      final res = await http.get(uri, headers: _headers).timeout(_timeout);
      _assertOk(res, 'Load laws');
      return (jsonDecode(res.body)['data'] as List)
          .map((e) => LawModel.fromJson(e))
          .toList();
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Is the backend running?');
    }
  }

  /// Fetches other laws in the same category (for "Related Laws" section).
  static Future<List<LawModel>> getRelatedLaws(
      String category, String excludeSituation) async {
    final all = await getAllLaws(category: category);
    return all.where((l) => l.situation != excludeSituation).take(4).toList();
  }
}
