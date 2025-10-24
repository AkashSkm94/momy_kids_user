import 'package:flutter/material.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/routes/app_routes.dart';

class OnboardingViewModel extends ChangeNotifier {
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;

  // Setters
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Navigate to login screen
  void handleGetStarted() {
    NavigationService.navigateAndReplace(AppRoutes.login);
  }

  // Reset state
  void reset() {
    _isLoading = false;
    notifyListeners();
  }
}

