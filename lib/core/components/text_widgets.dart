import 'package:flutter/material.dart';
import '../constants/color_palette.dart';
import '../localization/appLocalization.dart';

/// Base text widget with common properties
class BaseText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? lineHeight;
  final double? letterSpacing;
  final TextDecoration? decoration;
  final TextStyle? style;

  const BaseText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.lineHeight,
    this.letterSpacing,
    this.decoration,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? TextStyle(
        fontFamily: 'Montserrat',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: lineHeight,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Large heading text widget
class HeadingText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final double fontSize;

  const HeadingText({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color ?? ColorPalette.textPrimary,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      letterSpacing: letterSpacing ?? 1.2,
    );
  }
}

/// Medium heading text widget
class SubHeadingText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final double? fontSize;

  const SubHeadingText({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.fontSize = 16
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? ColorPalette.textPrimary,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      letterSpacing: letterSpacing ?? 0.5,
    );
  }
}

/// Section title text widget
class SectionTitleText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SectionTitleText({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color ?? ColorPalette.textPrimary,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Body text widget
class BodyText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? lineHeight;
  final double fontSize;
  final FontWeight fontWeight;
  const BodyText({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.lineHeight,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? ColorPalette.textPrimary,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      lineHeight: lineHeight ?? 1.5,
    );
  }
}




/// Caption text widget
class CaptionText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CaptionText({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: color ?? ColorPalette.textSecondary,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Label text widget
class LabelText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LabelText({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color ?? ColorPalette.textPrimary,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Button text widget
class ButtonText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;

  const ButtonText({
    super.key,
    required this.text,
    this.color,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? Colors.white,
      textAlign: TextAlign.center,
    );
  }
}

/// Link text widget
class LinkText extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;
  final TextDecoration? decoration;
  final double fontSize;


  const LinkText({
    super.key,
    required this.text,
    this.onTap,
    this.color,
    this.decoration,
    this.fontSize = 14
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BaseText(
        text: text,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? ColorPalette.primary,
        decoration: decoration ?? TextDecoration.underline,
      ),
    );
  }
}

/// Error text widget
class ErrorText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ErrorText({
    super.key,
    required this.text,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.red,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Success text widget
class SuccessText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SuccessText({
    super.key,
    required this.text,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.green,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Loading text widget
class LoadingText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  const LoadingText({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return BaseText(
      text: text,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color ?? ColorPalette.textSecondary,
      textAlign: textAlign,
    );
  }
}

/// Localized text widget
class LocalizedText extends StatelessWidget {
  final String translationKey;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? lineHeight;
  final double? letterSpacing;
  final TextDecoration? decoration;

  const LocalizedText({
    super.key,
    required this.translationKey,
    this.fontSize = 16,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.lineHeight,
    this.letterSpacing,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return BaseText(
      text: localizations.translate(translationKey),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      lineHeight: lineHeight,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}



