import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momy_kids/core/components/text_widgets.dart';
import '../constants/color_palette.dart';
import '../constants/images_utils.dart';
import '../localization/appLocalization.dart';
import 'image_widgets.dart' as image_widgets;

/// Reusable bottom sheet for image actions (Change Picture, Delete Picture)
/// Returns an enum indicating the user's action
enum ImageAction {
  changePicture,
  deletePicture,
  cancel,
}

class DeleteImageBottomSheet {
  /// Shows a bottom sheet with options to change or delete picture
  /// Returns the selected ImageAction
  static Future<ImageAction?> show(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    return await showModalBottomSheet<ImageAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top indicator bar
                image_widgets.BaseImage(
                  source: image_widgets.ImageSource.asset,
                  assetPath: ImageUtilsPath.bottomSheetTop,
                ),
                
                const SizedBox(height: 20),
                
                // Change Picture option
                _buildOption(
                  context: context,
                  title: localizations.translate('change_picture'),
                  color: ColorPalette.textPrimary,
                  onTap: () {
                    Navigator.pop(context, ImageAction.changePicture);
                  },
                ),
                
                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[300],
                  indent: 0,
                  endIndent: 0,
                ),
                
                // Delete Picture option
                _buildOption(
                  context: context,
                  title: localizations.translate('delete_picture'),
                  color: ColorPalette.txtRed,
                  onTap: () {
                    Navigator.pop(context, ImageAction.deletePicture);
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        side: BorderSide(
                          color: ColorPalette.primaryLight,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, ImageAction.cancel);
                      },
                      child: SubHeadingText(
                        text: localizations.translate('cancel'),
                        color: ColorPalette.primaryLight,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Helper method to build option items
  static Widget _buildOption({
    required BuildContext context,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SubHeadingText(
            text: title,
            color: color,
          ),
        ),
      ),
    );
  }
}

