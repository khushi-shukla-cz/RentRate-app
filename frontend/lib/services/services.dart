import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

// ─── AUTH SERVICE ─────────────────────────────────────────────────────────────
class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final res = await ApiService.post('/auth/register', {
      'name': name, 'email': email, 'phone': phone,
      'password': password, 'role': role,
    }, auth: false);
    if (res['success'] == true) await _saveSession(res);
    return res;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiService.post('/auth/login', {'email': email, 'password': password}, auth: false);
    if (res['success'] == true) await _saveSession(res);
    return res;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchMe() async {
    final res = await ApiService.get('/auth/me');
    if (res['success'] == true && res['user'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(res['user']));
    }
    return res;
  }

  static Future<void> _saveSession(Map<String, dynamic> res) async {
    final prefs = await SharedPreferences.getInstance();
    if (res['token'] != null) await prefs.setString(AppConstants.tokenKey, res['token']);
    if (res['user'] != null) await prefs.setString(AppConstants.userKey, jsonEncode(res['user']));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey) != null;
  }
}

// ─── PROPERTY SERVICE ─────────────────────────────────────────────────────────
class PropertyService {
  static Future<Map<String, dynamic>> getProperties({
    String? city, double? minPrice, double? maxPrice,
    String? furnishing, String? propertyType, int page = 1,
  }) async {
    final params = <String, String>{'page': '$page', 'limit': '10'};
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (minPrice != null) params['minPrice'] = '$minPrice';
    if (maxPrice != null) params['maxPrice'] = '$maxPrice';
    if (furnishing != null && furnishing.isNotEmpty) params['furnishing'] = furnishing;
    if (propertyType != null && propertyType.isNotEmpty) params['propertyType'] = propertyType;
    return ApiService.get('/properties', auth: false, queryParams: params);
  }

  static Future<Map<String, dynamic>> getProperty(String id) =>
      ApiService.get('/properties/$id', auth: false);

  static Future<Map<String, dynamic>> createProperty(Map<String, dynamic> data) =>
      ApiService.post('/properties', data);

  static Future<Map<String, dynamic>> updateProperty(String id, Map<String, dynamic> data) =>
      ApiService.put('/properties/$id', data);

  static Future<Map<String, dynamic>> deleteProperty(String id) =>
      ApiService.delete('/properties/$id');

  static Future<Map<String, dynamic>> getMyProperties() =>
      ApiService.get('/properties/owner/my');

  static Future<Map<String, dynamic>> toggleSave(String id) =>
      ApiService.post('/properties/$id/save', {});

  static Future<Map<String, dynamic>> getSavedProperties() =>
      ApiService.get('/properties/saved/list');
}

// ─── REVIEW SERVICE ────────────────────────────────────────────────────────────
class ReviewService {
  static Future<Map<String, dynamic>> getUserReviews(String userId) =>
      ApiService.get('/reviews/user/$userId', auth: false);

  static Future<Map<String, dynamic>> submitReview({
    required String reviewedUserId,
    String? propertyId,
    required Map<String, double> ratings,
    required String comment,
    required String reviewType,
  }) =>
      ApiService.post('/reviews', {
        'reviewedUserId': reviewedUserId,
        if (propertyId != null) 'propertyId': propertyId,
        'ratings': ratings,
        'comment': comment,
        'reviewType': reviewType,
      });
}

// ─── MESSAGE SERVICE ───────────────────────────────────────────────────────────
class MessageService {
  static Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String content,
    String? propertyId,
    String messageType = 'message',
  }) =>
      ApiService.post('/messages', {
        'receiverId': receiverId,
        'content': content,
        if (propertyId != null) 'propertyId': propertyId,
        'messageType': messageType,
      });

    static Future<Map<String, dynamic>> getConversations({String? query}) =>
      ApiService.get(
      '/messages/conversations',
      queryParams: query != null && query.trim().isNotEmpty ? {'q': query.trim()} : null,
      );

  static Future<Map<String, dynamic>> getThread(String userId) =>
      ApiService.get('/messages/thread/$userId');

    static Future<Map<String, dynamic>> markThreadRead(String userId) =>
      ApiService.put('/messages/thread/$userId/read', {});

    static Future<Map<String, dynamic>> getUnreadCount() =>
      ApiService.get('/messages/unread/count');
}

// ─── USER SERVICE ──────────────────────────────────────────────────────────────
class UserService {
  static Future<Map<String, dynamic>> getUser(String id) =>
      ApiService.get('/users/$id', auth: false);

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) =>
      ApiService.put('/users/profile/update', data);
}
