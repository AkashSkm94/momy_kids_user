import 'package:flutter/material.dart';
import 'package:momy_kids/core/constants/color_palette.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onClick;
  final bool isLoading;
  final bool enabled;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onClick,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);
    final Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (icon != null) Padding(padding: const EdgeInsets.only(right: 8), child: icon),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );

    final Widget loader = const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled && !isLoading ? onClick : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: enabled ? ColorPalette.primaryGradient : null,
            color: enabled ? null : Colors.grey.shade400,
            borderRadius: borderRadius,
            boxShadow: enabled
                ? const [
                    BoxShadow(
                      color: Color(0x26000000),
                      offset: Offset(0, 2),
                      blurRadius: 15,
                    ),
                  ]
                : null,
          ),
          child: Center(child: isLoading ? loader : content),
        ),
      ),
    );
  }
}