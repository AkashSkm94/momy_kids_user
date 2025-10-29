import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momy_kids/core/components/text_widgets.dart';
import '../constants/color_palette.dart';
import '../constants/images_utils.dart';
import '../localization/appLocalization.dart';
import 'image_widgets.dart' as image_widgets;

class ImagePickerBottomSheet {
  static Future<XFile?> show(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    return await showModalBottomSheet<XFile?>(
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
                
                // Camera option
                _buildOption(
                  context: context,
                  title: localizations.translate('camera'),
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    Navigator.pop(context, image);
                  },
                ),
                
                // Divider
                image_widgets.BaseImage(
                  source: image_widgets.ImageSource.asset,
                  assetPath: ImageUtilsPath.bottomSheetTop,
                  height: 1,
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
                
                // Gallery option
                _buildOption(
                  context: context,
                  title: localizations.translate('gallery'),
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    Navigator.pop(context, image);
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
                          backgroundColor: Colors.white,          // White background
                          elevation: 4,                           // Shadow / elevation
                          side: BorderSide(color: Colors.blue, width: 1.5), // Border color and thickness
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: SubHeadingText(text: localizations.translate('cancel'),color: ColorPalette.primaryLight,)
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

  static Widget _buildOption({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    bool isCancel = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SubHeadingText(text: title,color: ColorPalette.txtLight,)
        ),
      ),
    );
  }
}
