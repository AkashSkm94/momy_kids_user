import 'package:flutter/material.dart';
import 'package:momy_kids/core/components/image_widgets.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
import '../constants/color_palette.dart';
import '../localization/appLocalization.dart';
import '../navigation/navigation_service.dart';
import '../routes/app_routes.dart';
import 'text_widgets.dart';
import 'primary-button.dart';

class OtpSuccessBottomSheet extends StatelessWidget {
  final String phoneNumber;
  const OtpSuccessBottomSheet({super.key, required this.phoneNumber});
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
          padding: const EdgeInsets.only(left: 24,right: 24,bottom: 24,top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BaseImage(source: ImageSource.asset,assetPath: ImageUtilsPath.bottomSheetTop,),
              const SizedBox(height: 24),
              
              // Success Icon
              BaseImage(source: ImageSource.asset,assetPath: ImageUtilsPath.otpSuccess,),
              
              const SizedBox(height: 24),
              
              // Success Title
              SubHeadingText(
                text: localizations.translate('phone_verified'),
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
                    Navigator.pop(context);
                    NavigationService.navigateAndReplace(AppRoutes.register,arguments: {'phoneNumber': phoneNumber},);
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
  static void show(BuildContext context, {required String phoneNumber}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // prevents closing when tapping outside
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => OtpSuccessBottomSheet(phoneNumber: phoneNumber,),
    );
  }
}

