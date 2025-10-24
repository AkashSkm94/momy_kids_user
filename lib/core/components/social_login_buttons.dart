import 'package:flutter/material.dart';
import 'package:momy_kids/core/components/image_widgets.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
import '../constants/color_palette.dart';

/// Google login button
class GoogleLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final double? width;
  final double? height;

  const GoogleLoginButton({
    super.key,
    this.onPressed,
    this.text,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 40,
      height: height ?? 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icGoogle,)
          ),
        ),
      ),
    );
  }
}

/// Apple login button
class AppleLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final double? width;
  final double? height;

  const AppleLoginButton({
    super.key,
    this.onPressed,
    this.text,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 40,
      height: height ?? 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Center(
                child: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icApple,)
            ),
          ),
        ),
      ),
    );
  }
}

/// Social login section
class SocialLoginSection extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final String? orText;

  const SocialLoginSection({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.orText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // OR divider
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 2,
              color: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                orText ?? 'OR',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              height: 2,
              width: 10,
              color: Colors.grey[300],
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Social login buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GoogleLoginButton(
              onPressed: onGooglePressed,
            ),
            const SizedBox(width: 20),
            AppleLoginButton(
              onPressed: onApplePressed,
            ),
          ],
        ),
      ],
    );
  }
}

