import 'package:flutter/material.dart';
import '../../../../core/network/apiutils.dart';
import '../../../../core/network/url_manager.dart';
import '../../../../core/storage/local_storage_manager.dart';
import '../../../../core/localization/appLocalization.dart';

class RegisterViewModel extends ChangeNotifier {
  String _name = '';
  String _spouseName = '';
  int? _childrenCount;
  String _phone = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _preferredLanguage = 'en';
  String _role = 'user';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  String _errorKey = '';
  Map<String, String> _errorParams = {};
  String? _userId;
  String? _contact;

  // Getters
  String get name => _name;
  String get spouseName => _spouseName;
  int? get childrenCount => _childrenCount;
  String get phone => _phone;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get preferredLanguage => _preferredLanguage;
  String get role => _role;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String get errorMessage => _errorMessage;
  String get errorKey => _errorKey;
  Map<String, String> get errorParams => _errorParams;
  String? get userId => _userId;
  String? get contact => _contact;

  // Setters
  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setSpouseName(String spouseName) {
    _spouseName = spouseName;
    notifyListeners();
  }

  void setChildrenCount(int? childrenCount) {
    _childrenCount = childrenCount;
    notifyListeners();
  }

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
  }

  void setConfirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  void setPreferredLanguage(String language) {
    _preferredLanguage = language;
    notifyListeners();
  }

  void setRole(String role) {
    _role = role;
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

  // Password visibility toggles
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Validation methods
  bool validateName(String name) {
    return name.isNotEmpty && name.length >= 2;
  }

  bool validateSpouseName(String spouseName) {
    return spouseName.isNotEmpty && spouseName.length >= 2;
  }

  bool validateChildrenCount(int? childrenCount) {
    return childrenCount != null && childrenCount >= 0;
  }

  bool validatePhone(String phone) {
    return phone.isNotEmpty && phone.length >= 8;
  }

  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool validatePassword(String password) {
    return password.length >= 6;
  }

  bool validateConfirmPassword(String confirmPassword) {
    return confirmPassword == _password;
  }

  // Register method
  Future<void> register(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    // Validate all fields
    if (!validateName(_name)) {
      setError(
        localizations.translate('register_name_min_length'),
        errorKey: 'register_name_min_length',
      );
      return;
    }

    // Spouse name and children count are now optional
    // Only validate if provided
    if (_spouseName.isNotEmpty && !validateSpouseName(_spouseName)) {
      setError(
        localizations.translate('register_spouse_name_min_length'),
        errorKey: 'register_spouse_name_min_length',
      );
      return;
    }

    if (!validatePhone(_phone)) {
      setError(
        localizations.translate('valid_phone_required'),
        errorKey: 'valid_phone_required',
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

    if (!validatePassword(_password)) {
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

    setLoading(true);
    clearError();

    try {
      final response = await ApiUtils.post(
        endpoint: UrlManager.register,
        body: {
          'name': _name,
          'spouseName': _spouseName,
          'kidsCount': _childrenCount,
          'email': _email,
          'phoneNumber': _phone,
          'password': _password,
          'confirmPassword': _confirmPassword,
          'preferredLanguage': _preferredLanguage,
          'role': _role,
        },
      );

      if (response.isSuccess && response.hasData) {
        // Extract user data from response
        final data = response.data['data'];
        if (data != null) {
          _userId = data['userId'];
          _contact = data['contact'];
          
          // Save user data to local storage
          final storage = await LocalStorageManager.getInstance();
          await storage.saveUserData(
            userId: _userId!,
            name: _name,
            email: _email,
            phone: _phone,
            spouseName: _spouseName,
            kidsCount: _childrenCount,
            preferredLanguage: _preferredLanguage,
            role: _role,
          );
          
          setSuccess(true);
        } else {
          setError(
            localizations.translate('register_invalid_response'),
            errorKey: 'register_invalid_response',
          );
        }
      } else {
        final errorMsg = response.message.isNotEmpty ? response.message : localizations.translate('register_failed');
        setError(
          errorMsg,
          errorKey: response.message.isEmpty ? 'register_failed' : '',
        );
      }
    } catch (e) {
      setError(
        localizations.translate('register_failed'),
        errorKey: 'register_failed',
      );
    } finally {
      setLoading(false);
    }
  }

  // Reset state
  void reset() {
    _name = '';
    _spouseName = '';
    _childrenCount = null;
    _phone = '';
    _email = '';
    _password = '';
    _confirmPassword = '';
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    notifyListeners();
  }
}

