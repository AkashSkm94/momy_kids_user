import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Manager class for handling local storage operations using SharedPreferences
class LocalStorageManager {
  // Singleton instance
  static LocalStorageManager? _instance;
  static SharedPreferences? _preferences;

  // Private constructor
  LocalStorageManager._();

  /// Get singleton instance
  static Future<LocalStorageManager> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageManager._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> _init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  /// Storage keys
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserPhone = 'user_phone';
  static const String keySpouseName = 'spouse_name';
  static const String keyKidsCount = 'kids_count';
  static const String keyAuthToken = 'auth_token';
  static const String keyLanguageCode = 'language_code';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyPreferredLanguage = 'preferred_language';
  static const String keyUserRole = 'user_role';
  static const String keyProfilePicture = 'profile_picture';

  // ==================== String Operations ====================

  /// Save string value
  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return await _preferences!.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  // ==================== Int Operations ====================

  /// Save int value
  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return await _preferences!.setInt(key, value);
  }

  /// Get int value
  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  // ==================== Bool Operations ====================

  /// Save bool value
  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return await _preferences!.setBool(key, value);
  }

  /// Get bool value
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  // ==================== Double Operations ====================

  /// Save double value
  Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    return await _preferences!.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  // ==================== List Operations ====================

  /// Save string list
  Future<bool> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    return await _preferences!.setStringList(key, value);
  }

  /// Get string list
  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }

  // ==================== JSON Object Operations ====================

  /// Save JSON object (converts object to string)
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    final jsonString = jsonEncode(value);
    return await _preferences!.setString(key, jsonString);
  }

  /// Get JSON object (converts string to object)
  Map<String, dynamic>? getObject(String key) {
    final jsonString = _preferences?.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ==================== Key Check Operations ====================

  /// Check if key exists
  bool hasKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  /// Get all keys
  Set<String> getAllKeys() {
    return _preferences?.getKeys() ?? {};
  }

  // ==================== Remove Operations ====================

  /// Remove specific key
  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return await _preferences!.remove(key);
  }

  /// Clear all data
  Future<bool> clearAll() async {
    await _ensureInitialized();
    return await _preferences!.clear();
  }

  // ==================== User Data Operations ====================

  /// Save user data after registration/login
  Future<bool> saveUserData({
    required String userId,
    required String name,
    required String email,
    required String phone,
    String? spouseName,
    int? kidsCount,
    String? preferredLanguage,
    String? role,
    String? profilePicture,
  }) async {
    await _ensureInitialized();
    
    try {
      await setString(keyUserId, userId);
      await setString(keyUserName, name);
      await setString(keyUserEmail, email);
      await setString(keyUserPhone, phone);
      
      if (spouseName != null) {
        await setString(keySpouseName, spouseName);
      }
      
      if (kidsCount != null) {
        await setInt(keyKidsCount, kidsCount);
      }
      
      if (preferredLanguage != null) {
        await setString(keyPreferredLanguage, preferredLanguage);
      }
      
      if (role != null) {
        await setString(keyUserRole, role);
      }
      
      if (profilePicture != null && profilePicture.isNotEmpty) {
        await setString(keyProfilePicture, profilePicture);
      }
      
      await setBool(keyIsLoggedIn, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user data
  Map<String, dynamic> getUserData() {
    return {
      'userId': getString(keyUserId),
      'name': getString(keyUserName),
      'email': getString(keyUserEmail),
      'phone': getString(keyUserPhone),
      'spouseName': getString(keySpouseName),
      'kidsCount': getInt(keyKidsCount),
      'preferredLanguage': getString(keyPreferredLanguage),
      'role': getString(keyUserRole),
      'profilePicture': getString(keyProfilePicture),
      'isLoggedIn': getBool(keyIsLoggedIn) ?? false,
    };
  }

  /// Save auth token
  Future<bool> saveAuthToken(String token) async {
    await _ensureInitialized();
    return await setString(keyAuthToken, token);
  }

  /// Get auth token
  String? getAuthToken() {
    return getString(keyAuthToken);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return getBool(keyIsLoggedIn) ?? false;
  }

  /// Logout user (clear user data)
  Future<bool> logout() async {
    await _ensureInitialized();
    
    try {
      await remove(keyUserId);
      await remove(keyUserName);
      await remove(keyUserEmail);
      await remove(keyUserPhone);
      await remove(keySpouseName);
      await remove(keyKidsCount);
      await remove(keyAuthToken);
      await remove(keyUserRole);
      await remove(keyProfilePicture);
      await setBool(keyIsLoggedIn, false);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Ensure SharedPreferences is initialized
  Future<void> _ensureInitialized() async {
    if (_preferences == null) {
      await _init();
    }
  }
}

