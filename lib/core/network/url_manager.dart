/// Environment enum for different deployment environments
enum Environment {
  development,
  staging,
  production,
}

class UrlManager {
  // Base URLs for different environments
  static const String _baseUrlDev = 'http://14.97.95.179/api';
  static const String _baseUrlStaging = 'http://14.97.95.179/api';
  static const String _baseUrlProd = 'http://14.97.95.179/api';

  static const String _imageDev = 'http://14.97.95.179/api/';
  static const String _imageStaging = 'http://14.97.95.179/api/';
  static const String _imageProd = 'http://14.97.95.179/api/';
  // Current environment (change this to switch environments)
  static const Environment _currentEnvironment = Environment.development;

  /// Get base URL based on current environment
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return _baseUrlDev;
      case Environment.staging:
        return _baseUrlStaging;
      case Environment.production:
        return _baseUrlProd;
    }
  }

  static String get imageBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return _imageDev;
      case Environment.staging:
        return _imageStaging;
      case Environment.production:
        return _imageProd;
    }
  }

  /// Get full URL by combining base URL with endpoint
  static String getFullUrl(String endpoint) {
    // Remove leading slash if present
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    return '$baseUrl/$cleanEndpoint';
  }

  /// API Endpoints
  static const String phoneVerify = '/auth/phone/verify';
  static const String phoneVerifyOtp = '/auth/phone/verify-otp';
  static const String register = '/auth/register';
  static const String emailOtpVerify = '/auth/email/verify-otp';
  static const String emailOtpResend = '/auth/resend-otp';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String profile = '/profile/customer/{userId}';
  static const String profileUpdate = '/profile/customer/update';
  static const String forgotOtpVerify = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password';
  static const String verifyPhone = '/auth/verify-phone';
  static const String addKids = '/profile/customer/child';
  static const String updateKids = '/profile/customer/child/update';
  static const String deleteKid = '/profile/customer/child/{childId}';
  static const String governorates = '/governorates/getAll?lang=';
}




