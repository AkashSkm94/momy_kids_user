import 'package:flutter/material.dart';
import '../../../../core/network/apiutils.dart';
import '../../../../core/network/url_manager.dart';
import '../../../../core/localization/appLocalization.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  String _errorKey = '';
  Map<String, String> _errorParams = {};

  // Getters
  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String get errorMessage => _errorMessage;
  String get errorKey => _errorKey;
  Map<String, String> get errorParams => _errorParams;

  // Setters
  void setCurrentPassword(String password) {
    _currentPassword = password;
    notifyListeners();
  }

  void setNewPassword(String password) {
    _newPassword = password;
    notifyListeners();
  }

  void setConfirmPassword(String password) {
    _confirmPassword = password;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setSuccess(bool success) {
    _isSuccess = success;
    notifyListeners();
  }

  void setError(String error, {String? errorKey, Map<String, String>? errorParams}) {
    _errorMessage = error;
    _errorKey = errorKey ?? '';
    _errorParams = errorParams ?? {};
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    notifyListeners();
  }
  
  // Get translated error message based on current language
  String getTranslatedError(BuildContext context) {
    if (_errorKey.isEmpty) {
      return _errorMessage;
    }
    
    final localizations = AppLocalizations.of(context);
    String translatedMessage = localizations.translate(_errorKey);
    
    // Replace parameters in the error message
    _errorParams.forEach((key, value) {
      translatedMessage = translatedMessage.replaceAll('{$key}', value);
    });
    
    return translatedMessage;
  }
  
  // Called when language changes to refresh error messages
  void onLanguageChanged() {
    if (_errorKey.isNotEmpty) {
      notifyListeners();
    }
  }

  // Password visibility toggle
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Validation methods
  bool validateCurrentPassword(String password) {
    return password.isNotEmpty;
  }

  bool validateNewPassword(String password) {
    return password.length >= 6;
  }

  bool validateConfirmPassword(String password) {
    return password == _newPassword;
  }

  bool validatePasswordsDifferent() {
    return _currentPassword != _newPassword;
  }

  // Reset password method
  Future<void> resetPassword(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    // Validate all fields
    if (!validateCurrentPassword(_currentPassword)) {
      setError(
        localizations.translate('current_password_required'),
        errorKey: 'current_password_required',
      );
      return;
    }

    if (!validateNewPassword(_newPassword)) {
      setError(
        localizations.translate('password_min_length'),
        errorKey: 'password_min_length',
      );
      return;
    }

    if (!validateConfirmPassword(_confirmPassword)) {
      setError(
        localizations.translate('passwords_not_match'),
        errorKey: 'passwords_not_match',
      );
      return;
    }

    if (!validatePasswordsDifferent()) {
      setError(
        localizations.translate('new_password_different'),
        errorKey: 'new_password_different',
      );
      return;
    }

    setLoading(true);
    clearError();

    try {
      final response = await ApiUtils.post(
        endpoint: UrlManager.changePassword,
        body: {
          'current_password': _currentPassword,
          'new_password': _newPassword,
        },
      );

      if (response.isSuccess) {
        setSuccess(true);
      } else {
        final errorMsg = response.message.isNotEmpty ? response.message : localizations.translate('forgot_password_failed');
        setError(
          errorMsg,
          errorKey: response.message.isEmpty ? 'forgot_password_failed' : '',
        );
      }
    } catch (e) {
      setError(
        localizations.translate('forgot_password_failed'),
        errorKey: 'forgot_password_failed',
      );
    } finally {
      setLoading(false);
    }
  }

  // Reset state
  void reset() {
    _currentPassword = '';
    _newPassword = '';
    _confirmPassword = '';
    _obscurePassword = true;
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    notifyListeners();
  }
}

