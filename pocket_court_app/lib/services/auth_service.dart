import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'bookmark_service.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static String? _token;
  static UserModel? _user;

  static String? get token => _token;
  static UserModel? get currentUser => _user;
  static bool get isLoggedIn => _token != null;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final raw = prefs.getString(_userKey);
    if (raw != null) _user = UserModel.fromJson(jsonDecode(raw));
  }

  static Future<UserModel> register(String name, String email, String password,
      {String phone = '', String city = ''}) async {
    final res = await http
        .post(
          Uri.parse('${ApiService.baseUrl}/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'phone': phone,
            'city': city,
          }),
        )
        .timeout(const Duration(seconds: 10));
    final json = jsonDecode(res.body);
    if (res.statusCode != 201) {
      throw Exception(json['message'] ?? 'Registration failed');
    }
    return _save(json['data']);
  }

  static Future<UserModel> login(String email, String password) async {
    final res = await http
        .post(
          Uri.parse('${ApiService.baseUrl}/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));
    final json = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(json['message'] ?? 'Login failed');
    }
    return _save(json['data']);
  }

  static Future<UserModel> updateProfile(
      String name, String phone, String city) async {
    final res = await http
        .put(
          Uri.parse('${ApiService.baseUrl}/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode({'name': name, 'phone': phone, 'city': city}),
        )
        .timeout(const Duration(seconds: 10));
    final json = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(json['message'] ?? 'Update failed');
    }
    _user = UserModel.fromJson(json['data']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
    return _user!;
  }

  static Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final res = await http
        .put(
          Uri.parse('${ApiService.baseUrl}/auth/change-password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        )
        .timeout(const Duration(seconds: 10));
    final json = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(json['message'] ?? 'Password change failed');
    }
  }

  static Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await BookmarkService.clearCache(); // prevent stale data leaking to next user
  }

  static Future<UserModel> _save(Map<String, dynamic> data) async {
    _token = data['token'];
    _user = UserModel.fromJson(data['user']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
    return _user!;
  }
}