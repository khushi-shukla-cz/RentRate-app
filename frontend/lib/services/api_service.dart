import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static const Duration _requestTimeout = Duration(seconds: 8);

  static Map<String, dynamic>? _validateApiBaseUrl() {
    if (!AppConstants.hasConfiguredApiBaseUrl) {
      return {
        'success': false,
        'message': AppConstants.missingApiBaseUrlMessage,
      };
    }
    return null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<Map<String, String>> getHeaders({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String path, {bool auth = true, Map<String, String>? queryParams}) async {
    final validation = _validateApiBaseUrl();
    if (validation != null) return validation;

    try {
      var uri = Uri.parse('${AppConstants.baseUrl}$path');
      if (queryParams != null) uri = uri.replace(queryParameters: queryParams);
      final headers = await getHeaders(auth: auth);
      final response = await http.get(uri, headers: headers).timeout(_requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out in ${_requestTimeout.inSeconds}s. Check backend at ${AppConstants.baseUrl}'
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Cannot reach server at ${AppConstants.baseUrl}. Check Wi-Fi/USB routing and backend server.'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final validation = _validateApiBaseUrl();
    if (validation != null) return validation;

    try {
      final headers = await getHeaders(auth: auth);
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}$path'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(_requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out in ${_requestTimeout.inSeconds}s. Check backend at ${AppConstants.baseUrl}'
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Cannot reach server at ${AppConstants.baseUrl}. Check Wi-Fi/USB routing and backend server.'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final validation = _validateApiBaseUrl();
    if (validation != null) return validation;

    try {
      final headers = await getHeaders(auth: auth);
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}$path'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(_requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out in ${_requestTimeout.inSeconds}s. Check backend at ${AppConstants.baseUrl}'
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Cannot reach server at ${AppConstants.baseUrl}. Check Wi-Fi/USB routing and backend server.'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> delete(String path, {bool auth = true}) async {
    final validation = _validateApiBaseUrl();
    if (validation != null) return validation;

    try {
      final headers = await getHeaders(auth: auth);
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}$path'),
        headers: headers,
      ).timeout(_requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out in ${_requestTimeout.inSeconds}s. Check backend at ${AppConstants.baseUrl}'
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Cannot reach server at ${AppConstants.baseUrl}. Check Wi-Fi/USB routing and backend server.'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (_) {
      return {'success': false, 'message': 'Invalid server response (${response.statusCode})'};
    }
  }
}
