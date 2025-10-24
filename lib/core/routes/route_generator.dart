import 'package:flutter/material.dart';
import '../../screens/onboarding/view/onboarding_view.dart';
import '../../screens/splash_screen.dart';
import '../../screens/mobile_number_verified/view/mobile_number_verified_view.dart';
import '../../screens/mobile_number_otp_verified/view/mobile_number_otp_verified_view.dart';
import '../../screens/email_otp_verified/view/email_otp_verified_view.dart';
import '../../screens/auth/login/view/login_view.dart';
import '../../screens/auth/register/view/register_view.dart';
import '../../screens/auth/forgot_password/view/forgot_password_view.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return _createRoute(const SplashScreen(), settings.name!);

      case AppRoutes.onboarding:
        return _createRoute(const OnboardingView(), settings.name!);

      case AppRoutes.login:
        return _createRoute(const LoginView(), settings.name!);

      case AppRoutes.register:
        final arguments = args as Map<String, dynamic>?;
        final phoneNumber = arguments?['phoneNumber'] ?? "";
        return _createRoute(
          RegisterView(phoneNumber: phoneNumber),
          settings.name!,
        );

      case AppRoutes.forgotPassword:
        return _createRoute(const ForgotPasswordView(), settings.name!);

      case AppRoutes.mobileNumberVerified:
        return _createRoute(const MobileNumberVerifiedView(), settings.name!);

      case AppRoutes.mobileNumberOtpVerified:
        final arguments = args as Map<String, dynamic>?;
        final phoneNumber = arguments?['phoneNumber'] as String?;
        return _createRoute(
          MobileNumberOtpVerifiedView(phoneNumber: phoneNumber),
          settings.name!,
        );

      case AppRoutes.emailOtpVerified:
        final arguments = args as Map<String, dynamic>?;
        final email = arguments?['email'] as String?;
        return _createRoute(
          EmailOtpVerifiedView(email: email),
          settings.name!,
        );

      case AppRoutes.home:
      // TODO: Implement HomeScreen
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Home Screen - Coming Soon'),
            ),
          ),
          settings.name!,
        );

      case AppRoutes.profile:
      // TODO: Implement ProfileScreen
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Profile Screen - Coming Soon'),
            ),
          ),
          settings.name!,
        );

      case AppRoutes.settings:
      // TODO: Implement SettingsScreen
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Settings Screen - Coming Soon'),
            ),
          ),
          settings.name!,
        );

      case AppRoutes.about:
      // TODO: Implement AboutScreen
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('About Screen - Coming Soon'),
            ),
          ),
          settings.name!,
        );

      case AppRoutes.help:
      // TODO: Implement HelpScreen
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Help Screen - Coming Soon'),
            ),
          ),
          settings.name!,
        );

      case AppRoutes.contact:
      // TODO: Implement ContactScreen
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Contact Screen - Coming Soon'),
            ),
          ),
          settings.name!,
        );

      default:
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Page Not Found'),
            ),
          ),
          '404',
        );
    }
  }

  static Route<dynamic> _createRoute(Widget page, String routeName) {
    return PageRouteBuilder(
      settings: RouteSettings(name: routeName),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _getTransition(routeName, animation, child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Widget _getTransition(String routeName, Animation<double> animation, Widget child) {
    switch (routeName) {
      case AppRoutes.splash:
        return FadeTransition(opacity: animation, child: child);

      case AppRoutes.onboarding:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case AppRoutes.login:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: child,
        );

      case AppRoutes.register:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case AppRoutes.forgotPassword:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case AppRoutes.mobileNumberVerified:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case AppRoutes.mobileNumberOtpVerified:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case AppRoutes.emailOtpVerified:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      default:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
    }
  }
}
