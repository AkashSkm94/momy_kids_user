import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/appLanguage.dart';
import '../localization/appLocalization.dart';
import '../constants/color_palette.dart';
import '../components/text_widgets.dart';

class LanguageDialog extends StatefulWidget {
  const LanguageDialog({super.key});

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  String? _initialLanguage;

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    
    // Store initial language on first build
    _initialLanguage ??= appLanguage.appLocal.languageCode;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.language,
                  color: ColorPalette.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                LocalizedText(
                  translationKey: 'select_language',
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Return false if closed without changing language
                    final languageChanged = _initialLanguage != appLanguage.appLocal.languageCode;
                    Navigator.of(context).pop(languageChanged);
                  },
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Language Options
            _buildLanguageOption(
              context: context,
              flag: '🇺🇸',
              language: 'English',
              languageCode: 'en',
              isSelected: appLanguage.appLocal.languageCode == 'en',
              onTap: () {
                final languageChanged = _initialLanguage != 'en';
                appLanguage.changeLanguage(const Locale('en'));
                Navigator.of(context).pop(languageChanged);
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildLanguageOption(
              context: context,
              flag: '🇸🇦',
              language: 'العربية',
              languageCode: 'ar',
              isSelected: appLanguage.appLocal.languageCode == 'ar',
              onTap: () {
                final languageChanged = _initialLanguage != 'ar';
                appLanguage.changeLanguage(const Locale('ar'));
                Navigator.of(context).pop(languageChanged);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String flag,
    required String language,
    required String languageCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.primary.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorPalette.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? ColorPalette.primary : ColorPalette.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: ColorPalette.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Language selection button


/// Show language selection dialog
/// Returns true if language was changed, false otherwise
Future<bool> showLanguageDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => const LanguageDialog(),
  );
  // Return false if dialog was dismissed without selection
  return result ?? false;
}
