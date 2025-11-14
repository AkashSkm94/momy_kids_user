import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/color_palette.dart';
import '../localization/appLocalization.dart';
import '../navigation/navigation_service.dart';
import '../routes/app_routes.dart';
import '../storage/local_storage_manager.dart';
import 'url_manager.dart';

class ApiUtils {
  static const int _timeoutDuration = 30; // 30 seconds timeout

  /// Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Additional check by trying to reach a reliable server
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Generic GET request
  static Future<ApiResponse> get({
    required String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      // Check internet connection
      if (!await hasInternetConnection()) {
        return ApiResponse(
          success: false,
          message: 'No internet connection',
          statusCode: 0,
        );
      }

      // Build URL with query parameters
      String url = UrlManager.getFullUrl(endpoint);
      if (queryParams != null && queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString()))).query}';
      }

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      };

      // Add language header
      final languageCode = await _getLanguageCode();
      requestHeaders['x-lang'] = languageCode;

      // Add authorization header if token exists
      final token = await _getAuthToken();
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      // Make GET request
      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      ).timeout(const Duration(seconds: _timeoutDuration));
      print("url $url");
      print("headers ${requestHeaders}");
      print(response.body);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Generic POST request
  static Future<ApiResponse> post({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      // Check internet connection
      if (!await hasInternetConnection()) {
        return ApiResponse(
          success: false,
          message: 'No internet connection',
          statusCode: 0,
        );
      }

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      };

      // Add language header
      final languageCode = await _getLanguageCode();
      requestHeaders['x-lang'] = languageCode;

      // Add authorization header if token exists
      final token = await _getAuthToken();
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      print(UrlManager.getFullUrl(endpoint));
      print(body.toString());

      // Make POST request
      final response = await http.post(
        Uri.parse(UrlManager.getFullUrl(endpoint)),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: _timeoutDuration));

      print(response.body);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Generic PUT request
  static Future<ApiResponse> put({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      // Check internet connection
      if (!await hasInternetConnection()) {
        return ApiResponse(
          success: false,
          message: 'No internet connection',
          statusCode: 0,
        );
      }

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      };

      // Add language header
      final languageCode = await _getLanguageCode();
      requestHeaders['x-lang'] = languageCode;

      // Add authorization header if token exists
      final token = await _getAuthToken();
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      // Make PUT request
      final response = await http.put(
        Uri.parse(UrlManager.getFullUrl(endpoint)),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: _timeoutDuration));
      print("url ${Uri.parse(UrlManager.getFullUrl(endpoint))}");
      print("headers $requestHeaders");
      print("request ${jsonEncode(body)}");
      print("response ${response.body}");
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Generic PATCH request
  static Future<ApiResponse> patch({
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      if (!await hasInternetConnection()) {
        return ApiResponse(
          success: false,
          message: 'No internet connection',
          statusCode: 0,
        );
      }

      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      };

      // Add language header
      final languageCode = await _getLanguageCode();
      requestHeaders['x-lang'] = languageCode;

      final token = await _getAuthToken();
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      final response = await http.patch(
        Uri.parse(UrlManager.getFullUrl(endpoint)),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: _timeoutDuration));

      print('url ${UrlManager.getFullUrl(endpoint)}');
      print('requestHeaders ${requestHeaders}');
      print('body ${jsonEncode(body)}');
      print('response ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Generic DELETE request
  static Future<ApiResponse> delete({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    try {
      // Check internet connection
      if (!await hasInternetConnection()) {
        return ApiResponse(
          success: false,
          message: 'No internet connection',
          statusCode: 0,
        );
      }

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      };

      // Add language header
      final languageCode = await _getLanguageCode();
      requestHeaders['x-lang'] = languageCode;

      // Add authorization header if token exists
      final token = await _getAuthToken();
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      // Make DELETE request
      final response = await http.delete(
        Uri.parse(UrlManager.getFullUrl(endpoint)),
        headers: requestHeaders,
      ).timeout(const Duration(seconds: _timeoutDuration));
      print('url ${UrlManager.getFullUrl(endpoint)}');
      print(response.body);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Upload file with multipart request
  static Future<ApiResponse> uploadFile({
    required String endpoint,
    required String filePath,
    required String fieldName,
    Map<String, String>? additionalFields,
    Map<String, String>? headers,
  }) async {
    try {
      // Check internet connection
      if (!await hasInternetConnection()) {
        return ApiResponse(
          success: false,
          message: 'No internet connection',
          statusCode: 0,
        );
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(UrlManager.getFullUrl(endpoint)),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        ...?headers,
      });

      // Add language header
      final languageCode = await _getLanguageCode();
      request.headers['x-lang'] = languageCode;

      // Add authorization header if token exists
      final token = await _getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: _timeoutDuration),
      );

      // Convert to regular response
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Upload error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// PUT request with multipart form data
  static Future<ApiResponse> putMultipart({
    required String endpoint,
    Map<String, String>? fields,
    String? filePath,
    String? fileFieldName,
    Map<String, String>? headers,
  }) async {
    try {
      // Check internet connection
      if (!await hasInternetConnection()) {
        return ApiResponse(
          success: false,
          message: 'No internet connection',
          statusCode: 0,
        );
      }

      // Create multipart request with PUT method
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(UrlManager.getFullUrl(endpoint)),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        ...?headers,
      });

      // Add language header
      final languageCode = await _getLanguageCode();
      request.headers['x-lang'] = languageCode;

      // Add authorization header if token exists
      final token = await _getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file if provided
      if (filePath != null && fileFieldName != null) {
        final file = File(filePath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(fileFieldName, filePath),
          );
        }
      }

      print('PUT Multipart Request to: ${request.url}');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.length}');

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: _timeoutDuration),
      );

      // Convert to regular response
      final response = await http.Response.fromStream(streamedResponse);
      print('Response: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Upload error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Handle HTTP response
  static ApiResponse _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      final message = responseData['message'] ?? _getDefaultMessage(response.statusCode);

      if (!isSuccess && message == 'Unauthorized') {
        _handleUnauthorized(responseData['message'], NavigationService.currentContext);
      }

      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        data: responseData,
        message: message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Invalid response format',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get default error message based on status code
  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'Success';
      case 201:
        return 'Created successfully';
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 422:
        return 'Validation error';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      default:
        return 'Unknown error';
    }
  }

  static Future<void> _handleUnauthorized(String? serverMessage, BuildContext? context) async {
    try {
      final ctx = context ?? NavigationService.currentContext;
      if (ctx != null) {
        String localizedMessage;
        try {
          localizedMessage =
              AppLocalizations.of(ctx).translate('unauthorized_logout');
        } catch (_) {
          localizedMessage = serverMessage ?? 'Unauthorized. Logging out...';
        }
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(localizedMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }

      await clearAuthToken();
      final storage = await LocalStorageManager.getInstance();
      await storage.clearAll();
      NavigationService.navigateAndClearStack(AppRoutes.login);
    } catch (_) {}
  }

  /// Get authentication token
  static Future<String?> _getAuthToken() async {
    try {
      final storage = await LocalStorageManager.getInstance();
      return storage.getAuthToken();
    } catch (e) {
      return null;
    }
  }

  /// Get language code for API header
  static Future<String> _getLanguageCode() async {
    try {
      final storage = await LocalStorageManager.getInstance();
      final languageCode = storage.getString(LocalStorageManager.keyLanguageCode);
      // Return 'ar' if Arabic, otherwise default to 'en'
      return languageCode == 'ar' ? 'ar' : 'en';
    } catch (e) {
      // Default to English if there's any error
      return 'en';
    }
  }

  /// Set authentication token
  static Future<void> setAuthToken(String token) async {
    try {
      final storage = await LocalStorageManager.getInstance();
      await storage.saveAuthToken(token);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear authentication token
  static Future<void> clearAuthToken() async {
    try {
      final storage = await LocalStorageManager.getInstance();
      await storage.remove(LocalStorageManager.keyAuthToken);
    } catch (e) {
      // Handle error silently
    }
  }
}

/// API Response model
class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    required this.statusCode,
  });

  /// Check if response is successful
  bool get isSuccess => success;

  /// Check if response has data
  bool get hasData => data != null;

  /// Get data as Map
  Map<String, dynamic>? get dataAsMap {
    if (data is Map<String, dynamic>) {
      return data as Map<String, dynamic>;
    }
    return null;
  }

  /// Get data as List
  List<dynamic>? get dataAsList {
    if (data is List) {
      return data as List<dynamic>;
    }
    return null;
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}

