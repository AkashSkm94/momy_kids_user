import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/images_utils.dart';
import '../core/constants/color_palette.dart';
import '../core/localization/appLanguage.dart';
import '../core/localization/appLocalization.dart';
import '../core/navigation/navigation_service.dart';
import '../core/routes/app_routes.dart';
import '../core/session/session_manager.dart';
import '../core/components/text_widgets.dart';
import '../core/components/image_widgets.dart';
import '../core/components/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Start logo animation
    _logoController.forward();
    
    // Wait for logo animation to complete
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Start fade animation
    _fadeController.forward();
    
    // Wait for fade animation and then navigate
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() async {
    final appLanguage = Provider.of<AppLanguage>(context, listen: false);
    Locale _appLocale = await appLanguage.fetchLocale();
    await appLanguage.changeLanguage(_appLocale);
    
    // Handle session management
    await SessionManager.instance.handleSessionValidation(context);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: CircularImageWidget(
                      assetPath: ImageUtilsPath.appLogo,
                      source: ImageSource.asset,
                      size: 150,
                      backgroundColor: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: ColorPalette.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                      placeholder: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.child_care,
                          size: 80,
                          color: ColorPalette.primary,
                        ),
                      ),
                      errorWidget: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.child_care,
                          size: 80,
                          color: ColorPalette.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Animated App Name
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                         LocalizedText(
                           translationKey: 'app_name',
                           fontSize: 32,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Loading Indicator
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primary),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}