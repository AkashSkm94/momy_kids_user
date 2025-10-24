import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:momy_kids/core/components/image_widgets.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
import '../constants/color_palette.dart';
import '../components/text_widgets.dart';
import '../localization/appLocalization.dart';

/// Base text field widget with common properties
class BaseTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool showBorder;
  final bool filled;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final Widget? prefix;
  final Widget? suffix;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool isRequired;

  const BaseTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.showBorder = true,
    this.filled = true,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.prefix,
    this.suffix,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get text direction and locale for proper RTL support and keyboard language
    final textDirection = Directionality.of(context);
    final locale = Localizations.localeOf(context);
    
    return Localizations.override(
      context: context,
      locale: locale,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          onFieldSubmitted: onSubmitted,
          focusNode: focusNode,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,
          textDirection: textDirection,
          style: textStyle ?? const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: ColorPalette.textPrimary,
          ),
        decoration: InputDecoration(
          label: isRequired && labelText != null 
            ? RichText(
                textDirection: textDirection,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: labelText,
                      style: labelStyle ?? const TextStyle(
                        fontFamily: 'Montserrat',
                        color: ColorPalette.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              )
            : null,
          labelText: !isRequired ? labelText : null,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          prefix: prefix,
          suffix: suffix,
          filled: filled,
          fillColor: fillColor ?? Colors.white,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: labelStyle ?? const TextStyle(
            fontFamily: 'Montserrat',
            color: ColorPalette.textSecondary,
            fontSize: 16,
          ),
          hintStyle: hintStyle ?? const TextStyle(
            fontFamily: 'Montserrat',
            color: ColorPalette.textSecondary,
            fontSize: 16,
          ),
          errorStyle: errorStyle ?? const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.red,
            fontSize: 14,
          ),
          border: showBorder ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            borderSide: BorderSide.none,
          ) : InputBorder.none,
          enabledBorder: showBorder ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            borderSide: BorderSide.none,
          ) : InputBorder.none,
          focusedBorder: showBorder ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            borderSide: BorderSide(
              color: ColorPalette.primary,
              width: 2,
            ),
          ) : InputBorder.none,
          errorBorder: showBorder ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ) : InputBorder.none,
          focusedErrorBorder: showBorder ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ) : InputBorder.none,
        ),
        ),
      ),
    );
  }
}

/// Email text field widget
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool isRequired;

  const EmailTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return BaseTextField(
      controller: controller,
      labelText: labelText ?? 'Email',
      hintText: hintText ?? 'Enter your email',
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction ?? TextInputAction.next,
      prefixIcon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icEmail),
      validator: validator ?? (value){
        if (value == null || value.isEmpty) {
          return localizations.translate('email_required');
          }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return localizations.translate('valid_email_required');
        }
        return null;
      },
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      isRequired: isRequired,
    );
  }

  String? _defaultEmailValidator(String? value) {

    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}

/// Password text field widget
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool isRequired;

  const PasswordTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.isRequired = false,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      controller: widget.controller,
      labelText: widget.labelText ?? 'Password',
      hintText: widget.hintText ?? 'Enter your password',
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      prefixIcon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icPassword,),
      obscureText: _obscureText,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.remove_red_eye_outlined : Icons.visibility_off,
          color: _obscureText ? ColorPalette.iconGray : ColorPalette.primary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: widget.validator ?? (value){
        final localizations = AppLocalizations.of(context);
        if (value == null || value.isEmpty) {
          return localizations.translate('password_required');
        }
        if (value.length < 6) {
          return localizations.translate('password_min_length');
        }
        return null;
      },
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      onSubmitted: widget.onSubmitted,
      isRequired: widget.isRequired,
    );
  }

  String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

/// Phone number text field widget
class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final bool isRequired;

  const PhoneTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      controller: controller,
      labelText: labelText ?? 'Phone Number',
      hintText: hintText ?? 'Enter your phone number',
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction ?? TextInputAction.next,
      prefixIcon: Icon(Icons.phone_outlined),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
      validator: validator ?? _defaultPhoneValidator,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      isRequired: isRequired,
    );
  }

  String? _defaultPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}

/// Name text field widget
class NameTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const NameTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      controller: controller,
      labelText: labelText ?? 'Full Name',
      hintText: hintText ?? 'Enter your full name',
      keyboardType: TextInputType.name,
      textInputAction: textInputAction ?? TextInputAction.next,
      prefixIcon: Icon(Icons.person_outlined),
      textCapitalization: TextCapitalization.words,
      validator: validator ?? _defaultNameValidator,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
    );
  }

  String? _defaultNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}

/// Search text field widget
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      controller: controller,
      hintText: hintText ?? 'Search...',
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: Icon(Icons.search),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClear ?? () => controller?.clear(),
            )
          : null,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      borderRadius: 25,
    );
  }
}

/// Multi-line text field widget
class MultiLineTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const MultiLineTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.maxLines = 4,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
    );
  }
}

/// Number text field widget
class NumberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final int? maxLength;

  const NumberTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction ?? TextInputAction.next,
      prefixIcon: Icon(Icons.numbers),
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength!),
      ],
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
    );
  }
}

/// Custom text field with specific styling
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool showBorder;
  final bool filled;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.showBorder = true,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
      fillColor: fillColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      showBorder: showBorder,
      filled: filled,
    );
  }
}
