import 'package:flutter/material.dart';
import 'package:momy_kids/core/components/image_widgets.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
import 'package:provider/provider.dart';
import '../../screens/email_otp_verified/view_model/email_otp_verified_view_model.dart';
import '../constants/color_palette.dart';
import '../localization/appLocalization.dart';
import '../navigation/navigation_service.dart';
import '../routes/app_routes.dart';
import 'text_widgets.dart';
import 'primary-button.dart';

class EmailSuccessBottomSheet extends StatelessWidget {
  final String email;
  final String from;

  const EmailSuccessBottomSheet({super.key, required this.email, required this.from});
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BaseImage(
                source: ImageSource.asset,
                assetPath: ImageUtilsPath.bottomSheetTop,
              ),
              const SizedBox(height: 24),
              
              // Success Icon
              BaseImage(
                source: ImageSource.asset,
                assetPath: ImageUtilsPath.otpSuccess,
              ),
              
              const SizedBox(height: 24),
              
              // Success Title
              SubHeadingText(
                text: localizations.translate('email_verified'),
                fontSize: 16,
                color: ColorPalette.textPrimary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: localizations.translate('proceed'),
                  onClick: () {
                    // Stop the timer before navigating
                    try {
                      final viewModel = Provider.of<EmailOtpVerifiedViewModel>(
                        context,
                        listen: false,
                      );
                      viewModel.stopTimer();
                    } catch (e) {
                      // If view model not found, continue anyway
                    }
                    
                    Navigator.pop(context);
                    // Navigate to the next screen (e.g., home or dashboard)
                    if(from.contains(AppRoutes.register)) {
                      NavigationService.navigateAndReplace(AppRoutes.home);
                    }else{
                      NavigationService.navigateAndReplace(AppRoutes.resetPassword,arguments: {
                        'token': " ",
                        'email': from,
                      });
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Static method to show the bottom sheet
  static void show(BuildContext context, {required String email,required String from}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => EmailSuccessBottomSheet(email: email,from: from),
    );
  }
}

