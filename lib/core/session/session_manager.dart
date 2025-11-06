import 'package:flutter/material.dart';
import '../storage/local_storage_manager.dart';
import '../network/apiutils.dart';
import '../network/url_manager.dart';
import '../navigation/navigation_service.dart';
import '../routes/app_routes.dart';
import '../localization/appLocalization.dart';

class SessionManager {
  static SessionManager? _instance;
  
  SessionManager._();
  
  static SessionManager get instance {
    _instance ??= SessionManager._();
    return _instance!;
  }

  /// Check if user has valid session
  Future<bool> hasValidSession() async {
    try {
      final storage = await LocalStorageManager.getInstance();
      
      // Check if user is marked as logged in
      final isLoggedIn = storage.isLoggedIn();
      if (!isLoggedIn) {
        return false;
      }
      
      // Check if auth token exists
      final authToken = storage.getAuthToken();
      if (authToken == null || authToken.isEmpty) {
        return false;
      }
      
      // Check if user ID exists
      final userId = storage.getString(LocalStorageManager.keyUserId);
      if (userId == null || userId.isEmpty) {
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error checking session: $e');
      return false;
    }
  }

  /// Validate session with server
  Future<bool> validateSessionWithServer() async {
    try {
      final storage = await LocalStorageManager.getInstance();
      final userId = storage.getString(LocalStorageManager.keyUserId);
      
      if (userId == null || userId.isEmpty) {
        return false;
      }
      
      // Call profile API to validate session
      final endpoint = UrlManager.profile.replaceAll('{userId}', userId);
      final response = await ApiUtils.get(endpoint: endpoint);
      
      // If successful, session is valid
      return response.isSuccess;
    } catch (e) {
      print('Error validating session with server: $e');
      return false;
    }
  }

  /// Handle session validation and navigation
  Future<void> handleSessionValidation(BuildContext context) async {
    try {
      // Check if user has valid session locally
      final hasSession = await hasValidSession();
      
      if (!hasSession) {
        // No valid session, go to onboarding
        _navigateToOnboarding();
        return;
      }
      
      // Validate session with server
      final isValid = await validateSessionWithServer();
      
      if (isValid) {
        // Session is valid, go to home
        _navigateToHome();
      } else {
        // Session is invalid, logout and go to onboarding
        await _logoutAndNavigateToOnboarding();
      }
    } catch (e) {
      print('Error handling session validation: $e');
      // On error, go to onboarding
      _navigateToOnboarding();
    }
  }

  /// Navigate to home screen
  void _navigateToHome() {
    if (NavigationService.currentContext != null) {
      NavigationService.navigateAndClearStack(AppRoutes.profile);
    }
  }

  /// Navigate to onboarding screen
  void _navigateToOnboarding() {
    if (NavigationService.currentContext != null) {
      NavigationService.navigateAndReplace(AppRoutes.onboarding);
    }
  }

  /// Logout and navigate to onboarding
  Future<void> _logoutAndNavigateToOnboarding() async {
    try {
      // Clear all user data
      final storage = await LocalStorageManager.getInstance();
      await storage.logout();
      
      // Navigate to onboarding
      _navigateToOnboarding();
    } catch (e) {
      print('Error during logout: $e');
      _navigateToOnboarding();
    }
  }

  /// Get user session info
  Future<Map<String, dynamic>?> getSessionInfo() async {
    try {
      final storage = await LocalStorageManager.getInstance();
      return storage.getUserData();
    } catch (e) {
      print('Error getting session info: $e');
      return null;
    }
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
    try {
      final storage = await LocalStorageManager.getInstance();
      await storage.logout();
    } catch (e) {
      print('Error clearing session: $e');
    }
  }
}





