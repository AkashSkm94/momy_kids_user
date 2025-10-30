import 'package:flutter/material.dart';
import '../../../../core/network/apiutils.dart';
import '../../../../core/network/url_manager.dart';
import '../../../../core/localization/appLocalization.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  String _newPassword = '';
  String _confirmPassword = '';
  String? _email;
  String _otpCode = '';
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  String _errorKey = '';
  Map<String, String> _errorParams = {};

  // Getters
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;
  String? get email => _email;
  String get otpCode => _otpCode;
  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String get errorMessage => _errorMessage;
  String get errorKey => _errorKey;
  Map<String, String> get errorParams => _errorParams;

  // Setters
  void setNewPassword(String password) {
    _newPassword = password;
    notifyListeners();
  }

  void setConfirmPassword(String password) {
    _confirmPassword = password;
    notifyListeners();
  }


  void setEmail(String? email) {
    _email = email;
  }

  void setOtpCode(String otpCode) {
    _otpCode = otpCode;
  }

  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
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

  // Validation
  bool validatePassword(String password) {
    return password.length >= 6;
  }

  bool validatePasswordsMatch() {
    return _newPassword == _confirmPassword && _newPassword.isNotEmpty;
  }

  // Reset password method
  Future<void> resetPassword(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    if (_newPassword.isEmpty) {
      setError(
        localizations.translate('new_password_required'),
        errorKey: 'new_password_required',
      );
      return;
    }

    if (!validatePassword(_newPassword)) {
      setError(
        localizations.translate('password_min_length'),
        errorKey: 'password_min_length',
      );
      return;
    }

    if (_confirmPassword.isEmpty) {
      setError(
        localizations.translate('confirm_password_required'),
        errorKey: 'confirm_password_required',
      );
      return;
    }

    if (!validatePasswordsMatch()) {
      setError(
        localizations.translate('passwords_not_match'),
        errorKey: 'passwords_not_match',
      );
      return;
    }

    setLoading(true);
    clearError();

    try {
      final response = await ApiUtils.post(
        endpoint: UrlManager.resetPassword,
        body: {
          "email": "akash4@yopmail.com",
          "otpCode": "500806",
          "newPassword": "new123",
          "confirmPassword": "new123"
        }

      );

      if (response.isSuccess) {
        setSuccess(true);
      } else {
        // Translate the error message from API response
        final errorMsg = response.message.isNotEmpty 
            ? localizations.translate(response.message) 
            : localizations.translate('forgot_password_failed');
        setError(errorMsg);
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
    _newPassword = '';
    _confirmPassword = '';
    _email = "";
    _otpCode = '';
    _obscureNewPassword = true;
    _obscureConfirmPassword = true;
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    notifyListeners();
  }
}

