import 'dart:async';
import 'package:flutter/material.dart';
import 'package:momy_kids/core/routes/app_routes.dart';
import '../../../core/network/apiutils.dart';
import '../../../core/network/url_manager.dart';
import '../../../core/localization/appLocalization.dart';

class EmailOtpVerifiedViewModel extends ChangeNotifier {
  final List<String> _otpDigits = List.generate(6, (index) => '');
  bool _isLoading = false;
  int _resendCountdown = 60;
  bool _canResend = false;
  String _errorMessage = '';
  String _errorKey = '';
  Map<String, String> _errorParams = {};
  bool _isSuccess = false;
  String _email = '';
  Timer? _countdownTimer;

  // Getters
  List<String> get otpDigits => _otpDigits;
  bool get isLoading => _isLoading;
  int get resendCountdown => _resendCountdown;
  bool get canResend => _canResend;
  String get errorMessage => _errorMessage;
  String get errorKey => _errorKey;
  Map<String, String> get errorParams => _errorParams;
  bool get isSuccess => _isSuccess;
  String get email => _email;

  String get otpCode => _otpDigits.join('');

  // Setters
  void setOtpDigit(int index, String value) {
    if (index >= 0 && index < 6) {
      _otpDigits[index] = value;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setResendCountdown(int countdown) {
    _resendCountdown = countdown;
    _canResend = countdown <= 0;
    notifyListeners();
  }

  void setCanResend(bool canResend) {
    _canResend = canResend;
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

  void setSuccess(bool success) {
    _isSuccess = success;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  // Format countdown timer
  String formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Start countdown timer
  void startResendCountdown() {
    // Cancel any existing timer
    stopTimer();
    
    _resendCountdown = 60;
    _canResend = false;
    notifyListeners();
    
    // Start new timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setResendCountdown(_resendCountdown - 1);
      } else {
        setCanResend(true);
        stopTimer();
      }
    });
  }

  // Stop countdown timer
  void stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  // Validation
  bool validateOtp() {
    return otpCode.length == 6;
  }

  // Submit OTP
  Future<void> submitOtp(BuildContext context,String from) async {
    final localizations = AppLocalizations.of(context);
    
    if (!validateOtp()) {
      setError(
        localizations.translate('otp_incomplete'),
        errorKey: 'otp_incomplete',
      );
      return;
    }

    if (_email.isEmpty) {
      setError(
        localizations.translate('email_required'),
        errorKey: 'email_required',
      );
      return;
    }

    setLoading(true);
    clearError();

    try {
      // Make API call to verify Email OTP
      final response = await ApiUtils.post(
        endpoint: AppRoutes.forgotPassword == from ? UrlManager.forgotOtpVerify : UrlManager.emailOtpVerify,
        body: {
          'contact': _email,
          'email': _email,
          'otpCode': otpCode,
        },
      );

      if (response.isSuccess) {
        setSuccess(true);
        // Success will be handled in the view to show bottom sheet
      } else {
        // Show error message from API
        final errorMsg = response.message.isNotEmpty ? response.message : localizations.translate('otp_verification_failed');
        setError(
          errorMsg,
          errorKey: response.message,
        );
        setSuccess(false);
      }
    } catch (e) {
      setError(
        localizations.translate('otp_verification_failed'),
        errorKey: 'otp_verification_failed',
      );
      setSuccess(false);
    } finally {
      setLoading(false);
    }
  }

  // Resend OTP
  Future<void> resendOtp(BuildContext context) async {
    if (!_canResend) return;

    final localizations = AppLocalizations.of(context);
    
    if (_email.isEmpty) {
      setError(
        localizations.translate('email_required'),
        errorKey: 'email_required',
      );
      return;
    }

    try {
      // Call API to resend OTP
      final response = await ApiUtils.post(
        endpoint: UrlManager.emailOtpResend,
        body: {
          'contact': _email,
        },
      );

      if (response.isSuccess) {
        // Clear OTP fields
        clearOtp();
        
        // Reset and restart countdown timer
        startResendCountdown();
        
        clearError();
      } else {
        final errorMsg = response.message.isNotEmpty ? response.message : localizations.translate('otp_resend_failed');
        setError(
          errorMsg,
          errorKey: response.message,
        );
      }
    } catch (e) {
      setError(
        localizations.translate('otp_resend_failed'),
        errorKey: 'otp_resend_failed',
      );
    }
  }

  // Clear OTP fields
  void clearOtp() {
    for (int i = 0; i < 6; i++) {
      _otpDigits[i] = '';
    }
    notifyListeners();
  }

  // Reset state
  void reset() {
    stopTimer();
    clearOtp();
    _isLoading = false;
    _resendCountdown = 30;
    _canResend = false;
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    _isSuccess = false;
    _email = '';
    notifyListeners();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}

