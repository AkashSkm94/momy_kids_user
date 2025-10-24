import 'package:flutter/material.dart';
import '../../../../core/network/apiutils.dart';
import '../../../../core/network/url_manager.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage_manager.dart';
import '../../../../core/localization/appLocalization.dart';

class LoginViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  String _errorKey = '';
  Map<String, String> _errorParams = {};
  String? _token;
  String? _role;

  // Getters
  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String get errorMessage => _errorMessage;
  String get errorKey => _errorKey;
  Map<String, String> get errorParams => _errorParams;
  String? get token => _token;
  String? get role => _role;

  // Setters
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
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

  bool validatePassword(String password) {
    return password.length >= 6;
  }

  // Login method
  Future<void> login(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    if (_email.isEmpty || _password.isEmpty) {
      setError(
        localizations.translate('login_fill_all_fields'),
        errorKey: 'login_fill_all_fields',
      );
      return;
    }

    if (!validateEmail(_email)) {
      setError(
        localizations.translate('login_valid_email'),
        errorKey: 'login_valid_email',
      );
      return;
    }

    if (!validatePassword(_password)) {
      setError(
        localizations.translate('login_password_min_length'),
        errorKey: 'login_password_min_length',
      );
      return;
    }

    setLoading(true);
    clearError();

    try {
      final response = await ApiUtils.post(
        endpoint: UrlManager.login,
        body: {
          'email': _email,
          'password': _password,
        },
      );

      if (response.isSuccess && response.hasData) {
        // Extract token and role from response
        final data = response.data['data'];
        if (data != null) {
          _token = data['token'];
          _role = data['role'];
          
          // Save token to ApiUtils for API requests
          if (_token != null) {
            await ApiUtils.setAuthToken(_token!);
          }
          
          // Save token and user info to local storage
          final storage = await LocalStorageManager.getInstance();
          if (_token != null) {
            await storage.saveAuthToken(_token!);
          }
          
          // Save user login status and role
          await storage.setBool(LocalStorageManager.keyIsLoggedIn, true);
          await storage.setString(LocalStorageManager.keyUserEmail, _email);
          if (_role != null) {
            await storage.setString(LocalStorageManager.keyUserRole, _role!);
          }
          
          setSuccess(true);
        } else {
          setError(
            localizations.translate('login_invalid_response'),
            errorKey: 'login_invalid_response',
          );
        }
      } else {
        // Use server message if available, otherwise use generic error key
        final errorMsg = response.message.isNotEmpty ? response.message : localizations.translate('login_failed');
        setError(
          errorMsg,
          errorKey: response.message.isEmpty ? 'login_failed' : '',
        );
      }
    } catch (e) {
      setError(
        localizations.translate('login_failed'),
        errorKey: 'login_failed',
      );
    } finally {
      setLoading(false);
    }
  }

  // Google login
  void handleGoogleLogin() {
    // TODO: Implement Google login
    print('Google login pressed');
  }

  // Apple login
  void handleAppleLogin() {
    // TODO: Implement Apple login
    print('Apple login pressed');
  }

  // Reset state
  void reset() {
    _email = '';
    _password = '';
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    _token = null;
    _role = null;
    notifyListeners();
  }
}

