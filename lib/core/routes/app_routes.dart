class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String mobileNumberVerified = '/mobile-number-verified';
  static const String mobileNumberOtpVerified = '/mobile-number-otp-verified';
  static const String emailOtpVerified = '/email-otp-verified';
  static const String home = '/home';
  static const String products = '/products';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String help = '/help';
  static const String contact = '/contact';

  // Route paths for easy reference
  static const Map<String, String> routePaths = {
    'splash': splash,
    'onboarding': onboarding,
    'login': login,
    'register': register,
    'forgotPassword': forgotPassword,
    'resetPassword': resetPassword,
    'mobileNumberVerified': mobileNumberVerified,
    'mobileNumberOtpVerified': mobileNumberOtpVerified,
    'emailOtpVerified': emailOtpVerified,
    'home': home,
    'products': products,
    'profile': profile,
    'settings': settings,
    'about': about,
    'help': help,
    'contact': contact,
  };

  // Get route name by key
  static String getRoute(String key) {
    return routePaths[key] ?? splash;
  }

  // Check if route exists
  static bool routeExists(String routeName) {
    return routePaths.containsValue(routeName);
  }

  // Get all route names
  static List<String> getAllRoutes() {
    return routePaths.values.toList();
  }
}
