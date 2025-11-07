import 'package:flutter/material.dart';
import 'package:momy_kids/core/components/image_widgets.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
import '../constants/color_palette.dart';
import '../localization/appLocalization.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                iconPath: ImageUtilsPath.icBottomOne,
                label: localizations.translate('home'),
                index: 0,
              ),
              _buildNavItem(
                context: context,
                iconPath: ImageUtilsPath.icBottomTwo,
                label: localizations.translate('services'),
                index: 1,
              ),
              _buildNavItem(
                context: context,
                iconPath: ImageUtilsPath.icBottomThree,
                label: localizations.translate('products'),
                index: 2,
              ),
              _buildNavItem(
                context: context,
                iconPath: ImageUtilsPath.icBottomFour,
                label: localizations.translate('cart'),
                index: 3,
              ),
              _buildNavItem(
                context: context,
                iconPath: ImageUtilsPath.icBottomFive,
                label: localizations.translate('menu'),
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String iconPath,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(
              //   isActive ? activeIcon : icon,
              //   color: isActive ? ColorPalette.primary : ColorPalette.bottomUnselectIcon,
              //   size: 24,
              // ),
              BaseImage(source: ImageSource.assetIcons,assetPath: iconPath,iconColors: isActive ? ColorPalette.primary : ColorPalette.bottomUnselectIcon,),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? ColorPalette.primary : ColorPalette.bottomBarText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}











