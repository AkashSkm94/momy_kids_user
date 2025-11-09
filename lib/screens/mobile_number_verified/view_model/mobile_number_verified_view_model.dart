import 'package:flutter/material.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/network/apiutils.dart';
import '../../../core/network/url_manager.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/constants/country_codes.dart';

class MobileNumberVerifiedViewModel extends ChangeNotifier {
  String _phoneNumber = '';
  String _selectedCountryCode = '+965';
  String _selectedCountry = 'KW';
  bool _isLoading = false;
  bool _isOtpSent = false;
  String _errorMessage = '';
  String _errorKey = '';
  Map<String, String> _errorParams = {};
  String _phoneId = '';

  // Getters
  String get phoneNumber => _phoneNumber;
  String get selectedCountryCode => _selectedCountryCode;
  String get selectedCountry => _selectedCountry;
  bool get isLoading => _isLoading;
  bool get isOtpSent => _isOtpSent;
  String get errorMessage => _errorMessage;
  String get errorKey => _errorKey;
  Map<String, String> get errorParams => _errorParams;
  String get phoneId => _phoneId;
  List<Map<String, dynamic>> get countryCodes => CountryCodes.countryCodes;

  // Setters
  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void setSelectedCountry(String country) {
    _selectedCountry = country;
    final countryData = CountryCodes.getCountryByCode(country);
    _selectedCountryCode = countryData?['code'] as String? ?? '+965';
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setOtpSent(bool sent) {
    _isOtpSent = sent;
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

  void setPhoneId(String id) {
    _phoneId = id;
    notifyListeners();
  }

  // Validation
  bool validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      return false;
    }
    
    // Get the expected length for the selected country
    final expectedLength = CountryCodes.getMobileLength(_selectedCountry);
    
    // Validate phone number length matches the country's expected length
    return phone.length == expectedLength;
  }
  
  // Get expected mobile length for selected country
  int getExpectedMobileLength() {
    return CountryCodes.getMobileLength(_selectedCountry);
  }
  
  // Get country name for selected country
  String getCountryName() {
    return CountryCodes.getCountryName(_selectedCountry);
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

  // Send OTP method
  Future<void> sendOtp(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    if (_phoneNumber.isEmpty) {
      setError(
        localizations.translate('phone_required'),
        errorKey: 'phone_required',
      );
      return;
    }

    if (!validatePhoneNumber(_phoneNumber)) {
      final expectedLength = getExpectedMobileLength();
      final countryName = getCountryName();
      
      // Use localized error message with country-specific length
      setError(
        localizations.translate('phone_length_error')
            .replaceAll('{country}', countryName)
            .replaceAll('{length}', expectedLength.toString()),
        errorKey: 'phone_length_error',
        errorParams: {
          'country': countryName,
          'length': expectedLength.toString(),
        },
      );
      return;
    }

    setLoading(true);
    clearError();

    try {
      // Make API call to send OTP
      final response = await ApiUtils.post(
        endpoint: UrlManager.phoneVerify,
        body: {
          'phoneNumber': _phoneNumber,
        },
      );

      if (response.isSuccess) {
        // Extract phoneId from response
        if (response.data != null && response.data['data'] != null) {
          final phoneId = response.data['data']['phoneId'];
          if (phoneId != null) {
            setPhoneId(phoneId);
          }
        }

        setOtpSent(true);
        // Navigate to OTP verification screen with phone number
        NavigationService.navigateTo(
          AppRoutes.mobileNumberOtpVerified,
          arguments: {'phoneNumber': _phoneNumber},
        );
      } else {
        // Translate the error message from API response
        final errorMsg = response.message.isNotEmpty 
            ? localizations.translate(response.message) 
            : localizations.translate('otp_resend_failed');
        setError(
          errorMsg,
          errorKey: response.message,
        );
      }
    } catch (e) {
      setError(
        localizations.translate('otp_send_failed'),
        errorKey: 'otp_send_failed',
      );
    } finally {
      setLoading(false);
    }
  }

  // Reset state
  void reset() {
    _phoneNumber = '';
    _selectedCountryCode = '+965';
    _selectedCountry = 'KW';
    _isLoading = false;
    _isOtpSent = false;
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    _phoneId = '';
    notifyListeners();
  }
}

