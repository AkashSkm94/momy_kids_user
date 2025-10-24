import 'package:flutter/material.dart';
import '../localization/appLanguage.dart';
import 'navigation_service.dart';
import '../routes/app_routes.dart';

class NavigationHelper {
  // Navigate to authentication flow
  static Future<void> navigateToAuth() async {
    await NavigationService.navigateAndClearStack(AppRoutes.login);
  }

  // Navigate to main app flow
  static Future<void> navigateToMain() async {
    await NavigationService.navigateAndClearStack(AppRoutes.home);
  }

  // Navigate to onboarding flow
  static Future<void> navigateToOnboarding() async {
    await NavigationService.navigateAndReplace(AppRoutes.onboarding);
  }

  // Navigate to splash screen
  static Future<void> navigateToSplash() async {
    await NavigationService.navigateAndClearStack(AppRoutes.splash);
  }

  // Navigate to profile
  static Future<void> navigateToProfile() async {
    await NavigationService.navigateTo(AppRoutes.profile);
  }

  // Navigate to settings
  static Future<void> navigateToSettings() async {
    await NavigationService.navigateTo(AppRoutes.settings);
  }

  // Navigate to about
  static Future<void> navigateToAbout() async {
    await NavigationService.navigateTo(AppRoutes.about);
  }

  // Navigate to help
  static Future<void> navigateToHelp() async {
    await NavigationService.navigateTo(AppRoutes.help);
  }

  // Navigate to contact
  static Future<void> navigateToContact() async {
    await NavigationService.navigateTo(AppRoutes.contact);
  }

  // Navigate to register
  static Future<void> navigateToRegister() async {
    await NavigationService.navigateTo(AppRoutes.register);
  }

  // Navigate to forgot password
  static Future<void> navigateToForgotPassword() async {
    await NavigationService.navigateTo(AppRoutes.forgotPassword);
  }

  // Navigate back to home
  static void navigateBackToHome() {
    NavigationService.popUntil(AppRoutes.home);
  }

  // Navigate back to login
  static void navigateBackToLogin() {
    NavigationService.popUntil(AppRoutes.login);
  }

  // Navigate back to splash
  static void navigateBackToSplash() {
    NavigationService.popUntil(AppRoutes.splash);
  }

  // Show loading dialog
  static void showLoadingDialog({String? message}) {
    NavigationService.showDialog(
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? 'Loading...'),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog() {
    NavigationService.goBack();
  }

  // Show error dialog
  static void showErrorDialog({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    NavigationService.showDialog(
      child: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => NavigationService.goBack(),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                NavigationService.goBack();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  // Show success dialog
  static void showSuccessDialog({
    required String title,
    required String message,
    VoidCallback? onContinue,
  }) {
    NavigationService.showDialog(
      child: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              NavigationService.goBack();
              onContinue?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) async {
    bool? result = await NavigationService.showDialog(
      child: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => NavigationService.goBackWithResult(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => NavigationService.goBackWithResult(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Show bottom sheet
  static Future<Future> showBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
  }) async {
    return NavigationService.showBottomSheet(
      child: child,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
    );
  }

  // Show snackbar
  static void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    NavigationService.showSnackBar(
      message: message,
      duration: duration,
      action: action,
    );
  }

  // Navigate with language change
  static Future<void> navigateWithLanguageChange(
    String routeName,
    String languageCode,
  ) async {
    // This would need to be implemented with proper language management
    // For now, just navigate to the route
    await NavigationService.navigateAndReplace(routeName);
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    // This would need to be implemented with proper authentication state
    // For now, return false
    return false;
  }

  // Navigate based on authentication state
  static Future<void> navigateBasedOnAuth() async {
    if (isAuthenticated()) {
      await navigateToMain();
    } else {
      await navigateToAuth();
    }
  }
}
