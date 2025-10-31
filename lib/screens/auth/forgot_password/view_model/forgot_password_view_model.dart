import 'package:flutter/material.dart';
import '../../../../core/network/apiutils.dart';
import '../../../../core/network/url_manager.dart';
import '../../../../core/localization/appLocalization.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  String _email = '';
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  String _errorKey = '';
  Map<String, String> _errorParams = {};

  // Getters
  String get email => _email;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String get errorMessage => _errorMessage;
  String get errorKey => _errorKey;
  Map<String, String> get errorParams => _errorParams;

  // Setters
  void setEmail(String email) {
    _email = email;
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
  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Send forgot password email
  Future<void> sendForgotPasswordEmail(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    if (_email.isEmpty) {
      setError(
        localizations.translate('email_required'),
        errorKey: 'email_required',
      );
      return;
    }

    if (!validateEmail(_email)) {
      setError(
        localizations.translate('valid_email_required'),
        errorKey: 'valid_email_required',
      );
      return;
    }

    setLoading(true);
    clearError();

    try {
      final response = await ApiUtils.post(
        endpoint: UrlManager.forgotPassword,
        body: {
          'email': _email,
        },
      );

      if (response.isSuccess) {
        setSuccess(true);
      } else {
        // Translate the error message from API response
        final errorMsg = response.message.isNotEmpty 
            ? localizations.translate(response.message) 
            : localizations.translate('forgot_password_failed');
        setError(errorMsg,errorKey: response.message);
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
    _email = '';
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    notifyListeners();
  }
}
