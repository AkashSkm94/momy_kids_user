import 'package:flutter/material.dart';
import '../constants/color_palette.dart';
import '../constants/images_utils.dart';
import 'image_widgets.dart';
import 'primary-button.dart';

class ConfirmBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  const ConfirmBottomSheet({super.key, required this.title, required this.message, this.confirmText = 'Yes', this.cancelText = 'Cancel'});

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BaseImage(
                source: ImageSource.asset,
                assetPath: ImageUtilsPath.bottomSheetTop,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorPalette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: confirmText,
                      onClick: () => Navigator.of(context).pop(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ColorPalette.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        cancelText,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool> show(BuildContext context, {required String title, required String message, String confirmText = 'Yes', String cancelText = 'Cancel'}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfirmBottomSheet(title: title, message: message, confirmText: confirmText, cancelText: cancelText),
    );
    return result ?? false;
  }
}










