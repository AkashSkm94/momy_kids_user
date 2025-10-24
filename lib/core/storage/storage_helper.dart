import 'local_storage_manager.dart';

/// Helper class with common storage operations
/// This class provides convenient methods for frequent storage tasks
class StorageHelper {
  /// Check if user is authenticated
  static Future<bool> isUserAuthenticated() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.isLoggedIn() && storage.getAuthToken() != null;
  }

  /// Get current user ID
  static Future<String?> getCurrentUserId() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getString(LocalStorageManager.keyUserId);
  }

  /// Get current user name
  static Future<String?> getCurrentUserName() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getString(LocalStorageManager.keyUserName);
  }

  /// Get current user email
  static Future<String?> getCurrentUserEmail() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getString(LocalStorageManager.keyUserEmail);
  }

  /// Get current user phone
  static Future<String?> getCurrentUserPhone() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getString(LocalStorageManager.keyUserPhone);
  }

  /// Get complete user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getUserData();
  }

  /// Update user name
  static Future<bool> updateUserName(String name) async {
    final storage = await LocalStorageManager.getInstance();
    return await storage.setString(LocalStorageManager.keyUserName, name);
  }

  /// Update user email
  static Future<bool> updateUserEmail(String email) async {
    final storage = await LocalStorageManager.getInstance();
    return await storage.setString(LocalStorageManager.keyUserEmail, email);
  }

  /// Save user session after login
  static Future<bool> saveUserSession({
    required String userId,
    required String name,
    required String email,
    required String phone,
    String? authToken,
    String? spouseName,
    int? kidsCount,
    String? preferredLanguage,
    String? role,
  }) async {
    final storage = await LocalStorageManager.getInstance();
    
    // Save user data
    await storage.saveUserData(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      spouseName: spouseName,
      kidsCount: kidsCount,
      preferredLanguage: preferredLanguage,
      role: role,
    );
    
    // Save auth token if provided
    if (authToken != null) {
      await storage.saveAuthToken(authToken);
    }
    
    return true;
  }

  /// Clear user session (logout)
  static Future<bool> clearUserSession() async {
    final storage = await LocalStorageManager.getInstance();
    return await storage.logout();
  }

  /// Get auth token
  static Future<String?> getAuthToken() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getAuthToken();
  }

  /// Check if specific user data exists
  static Future<bool> hasUserData() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.hasKey(LocalStorageManager.keyUserId);
  }

  /// Get user's preferred language
  static Future<String?> getPreferredLanguage() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getString(LocalStorageManager.keyPreferredLanguage);
  }

  /// Update user's preferred language
  static Future<bool> updatePreferredLanguage(String languageCode) async {
    final storage = await LocalStorageManager.getInstance();
    return await storage.setString(
      LocalStorageManager.keyPreferredLanguage,
      languageCode,
    );
  }

  /// Get number of kids
  static Future<int?> getKidsCount() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getInt(LocalStorageManager.keyKidsCount);
  }

  /// Update number of kids
  static Future<bool> updateKidsCount(int count) async {
    final storage = await LocalStorageManager.getInstance();
    return await storage.setInt(LocalStorageManager.keyKidsCount, count);
  }

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getBool('has_completed_onboarding') ?? false;
  }

  /// Mark onboarding as completed
  static Future<bool> markOnboardingCompleted() async {
    final storage = await LocalStorageManager.getInstance();
    return await storage.setBool('has_completed_onboarding', true);
  }

  /// Save app theme preference
  static Future<bool> saveThemePreference(bool isDarkMode) async {
    final storage = await LocalStorageManager.getInstance();
    return await storage.setBool('is_dark_mode', isDarkMode);
  }

  /// Get app theme preference
  static Future<bool> isDarkModeEnabled() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getBool('is_dark_mode') ?? false;
  }

  /// Save last sync timestamp
  static Future<bool> saveLastSyncTime(DateTime timestamp) async {
    final storage = await LocalStorageManager.getInstance();
    return await storage.setString(
      'last_sync_time',
      timestamp.toIso8601String(),
    );
  }

  /// Get last sync timestamp
  static Future<DateTime?> getLastSyncTime() async {
    final storage = await LocalStorageManager.getInstance();
    final timeString = storage.getString('last_sync_time');
    if (timeString != null) {
      try {
        return DateTime.parse(timeString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save user preferences
  static Future<bool> saveUserPreferences({
    bool? notificationsEnabled,
    bool? emailUpdates,
    bool? pushNotifications,
    String? defaultView,
  }) async {
    final storage = await LocalStorageManager.getInstance();
    
    final preferences = <String, dynamic>{};
    if (notificationsEnabled != null) {
      preferences['notifications_enabled'] = notificationsEnabled;
    }
    if (emailUpdates != null) {
      preferences['email_updates'] = emailUpdates;
    }
    if (pushNotifications != null) {
      preferences['push_notifications'] = pushNotifications;
    }
    if (defaultView != null) {
      preferences['default_view'] = defaultView;
    }
    
    return await storage.setObject('user_preferences', preferences);
  }

  /// Get user preferences
  static Future<Map<String, dynamic>?> getUserPreferences() async {
    final storage = await LocalStorageManager.getInstance();
    return storage.getObject('user_preferences');
  }

  /// Debug: Print all stored keys
  static Future<void> debugPrintAllKeys() async {
    final storage = await LocalStorageManager.getInstance();
    final keys = storage.getAllKeys();
    print('=== Stored Keys ===');
    for (var key in keys) {
      print('Key: $key');
    }
    print('===================');
  }

  /// Debug: Print user data
  static Future<void> debugPrintUserData() async {
    final storage = await LocalStorageManager.getInstance();
    final userData = storage.getUserData();
    print('=== User Data ===');
    userData.forEach((key, value) {
      print('$key: $value');
    });
    print('==================');
  }

  /// Clear all app data (for debugging/testing)
  static Future<bool> clearAllData() async {
    final storage = await LocalStorageManager.getInstance();
    return await storage.clearAll();
  }
}

