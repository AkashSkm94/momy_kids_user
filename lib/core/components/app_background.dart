import 'package:flutter/material.dart';
import 'package:momy_kids/core/components/image_widgets.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
import '../constants/color_palette.dart';

/// Reusable app background component
class AppBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const AppBackground({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildDecoration(),
      child: SafeArea(
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    
      return BoxDecoration(
        image:DecorationImage(
          image: AssetImage(ImageUtilsPath.appBg), // your image path
          fit: BoxFit.cover, // options: cover, contain, fill, etc.
        ),
      );
  }
}

