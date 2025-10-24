import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get currentContext => navigatorKey.currentContext;

  static NavigatorState? get navigator => navigatorKey.currentState;

  // Navigate to a named route
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  // Navigate and replace current route
  static Future<dynamic> navigateAndReplace(String routeName, {Object? arguments}) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }

  // Navigate and clear all previous routes
  static Future<dynamic> navigateAndClearStack(String routeName, {Object? arguments}) {
    return navigator!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  // Navigate back
  static void goBack([dynamic result]) {
    return navigator!.pop(result);
  }

  // Navigate back with result
  static void goBackWithResult(dynamic result) {
    return navigator!.pop(result);
  }

  // Check if can go back
  static bool canGoBack() {
    return navigator!.canPop();
  }

  // Pop until specific route
  static void popUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
  }

  // Pop until first route
  static void popUntilFirst() {
    navigator!.popUntil((Route<dynamic> route) => route.isFirst);
  }

  // Navigate to home
  static Future<dynamic> navigateToHome({Object? arguments}) {
    return navigateAndClearStack(AppRoutes.home, arguments: arguments);
  }

  // Navigate to login
  static Future<dynamic> navigateToLogin({Object? arguments}) {
    return navigateAndClearStack(AppRoutes.login, arguments: arguments);
  }

  // Navigate to onboarding
  static Future<dynamic> navigateToOnboarding({Object? arguments}) {
    return navigateAndReplace(AppRoutes.onboarding, arguments: arguments);
  }

  // Navigate to splash
  static Future<dynamic> navigateToSplash({Object? arguments}) {
    return navigateAndClearStack(AppRoutes.splash, arguments: arguments);
  }

  // Show dialog
  static Future<dynamic> showDialog({
    required Widget child,
    bool barrierDismissible = true,
    Color barrierColor = Colors.white,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
  }) {
    return showGeneralDialog(
      context: currentContext!,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
    );
  }

  // Show bottom sheet
  static Future<dynamic> showBottomSheet({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool useRootNavigator = false,
  }) {
    return showModalBottomSheet(
      context: currentContext!,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      builder: (context) => child,
    );
  }

  // Show snackbar
  static void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
    ShapeBorder? shape,
    SnackBarBehavior? behavior,
    Animation<double>? animation,
    VoidCallback? onVisible,
  }) {
    ScaffoldMessenger.of(currentContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
        behavior: behavior,
        shape: shape,
        margin: margin,
        padding: padding,
        width: width,
        animation: animation,
        onVisible: onVisible,
      ),
    );
  }
}
