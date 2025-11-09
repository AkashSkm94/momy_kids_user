import 'package:flutter/material.dart';
import 'package:momy_kids/core/components/image_widgets.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_palette.dart';
import '../../../core/localization/appLanguage.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/utils/Common.dart';
import '../../../core/components/bottom_navigation_bar.dart';
import '../../../core/components/confirm_bottom_sheet.dart';
import '../../../core/storage/local_storage_manager.dart';
import '../../../core/network/url_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int _currentBottomNavIndex = 4; // Menu tab
  String? _profileImagePath;

  get scaffoldMessenger => null;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final storage = await LocalStorageManager.getInstance();
    final imagePath = storage.getString(LocalStorageManager.keyProfilePicture);
    if (mounted) {
      setState(() {
        _profileImagePath = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    final isRTL = localizations.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: _buildAppBar(appLanguage, localizations),
      body: _buildBody(localizations, appLanguage),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          _handleBottomNavigation(index);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLanguage appLanguage,
      AppLocalizations localizations,) {
    final isRTL = localizations.locale?.languageCode == 'ar';

    return AppBar(
      backgroundColor: const Color(0xFFF5F9FF),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          isRTL ? Icons.arrow_forward : Icons.arrow_back,
          color: ColorPalette.textPrimary,
        ),
        onPressed: () => NavigationService.goBack(),
      ),
      title: Text(
        localizations.translate('settings'),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorPalette.textPrimary,
        ),
      ),
      actions: [
        // Profile Picture
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0),
          child: _buildProfilePicture(),
        ),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey[300],
      backgroundImage: _profileImagePath != null &&
          _profileImagePath!.isNotEmpty
          ? NetworkImage(
        UrlManager.imageBaseUrl + _profileImagePath!,
      )
          : null,
      child: _profileImagePath == null || _profileImagePath!.isEmpty
          ? const Icon(
        Icons.person,
        size: 20,
        color: Colors.grey,
      )
          : null,
    );
  }

  Widget _buildBody(AppLocalizations localizations, AppLanguage appLanguage) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            Text(
              localizations.translate('account'),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Account Options Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Option
                  _buildSettingsOption(
                    icon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icSettingUser,iconColors: ColorPalette.settingIconColors,),
                    title: localizations.translate('profile'),
                    onTap: () {
                      NavigationService.navigateTo(AppRoutes.profile);
                    },
                  ),
                  // Language Option
                  _buildLanguageOption(localizations, appLanguage),

                  // Logout Option
                  _buildSettingsOption(
                    icon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icLogout,iconColors: ColorPalette.settingIconColors,),
                    title: localizations.translate('logout'),
                    onTap: () => _handleLogout(localizations),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final localizations = AppLocalizations.of(context);
    final isRTL = localizations.locale?.languageCode == 'ar';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorPalette.settingTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(AppLocalizations localizations,
      AppLanguage appLanguage,) {
    final isEnglish = appLanguage.appLocal.languageCode == 'en';
    final currentLanguageText = isEnglish
        ? localizations.translate('english').toUpperCase()
        : localizations.translate('arabic').toUpperCase();

    return InkWell(
      onTap: () async {
        // Toggle language
        final newLanguage = isEnglish ? const Locale('ar') : const Locale('en');
        await appLanguage.changeLanguage(newLanguage);
        if (mounted) {
          setState(() {});
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icLanguage,iconColors: ColorPalette.settingIconColors,),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                localizations.translate('language'),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorPalette.textPrimary,
                ),
              ),
            ),
            // Language Toggle Button (Blue pill with text and toggle switch)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ColorPalette.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentLanguageText,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Toggle Switch Circle
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(AppLocalizations localizations) async {
    final confirmed = await ConfirmBottomSheet.show(
      context,
      title: localizations.translate('logout'),
      message: localizations.translate('logout_confirmation_message'),
      confirmText: localizations.translate('yes'),
      cancelText: localizations.translate('cancel'),
    );

    if (!mounted) return;

    if (confirmed) {
      // Clear session
      final storage = await LocalStorageManager.getInstance();
      await storage.logout();

      // Navigate to login screen
      if (mounted) {
        NavigationService.navigateToLogin();

        // Show success message using stored reference
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              localizations.translate('logout_successful'),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
    void _handleBottomNavigation(int index) {
      switch (index) {
        case 0: // Home
          NavigationService.navigateAndReplace(AppRoutes.home);
          break;
        case 1: // Services
        // TODO: Navigate to services
          break;
        case 2: // Products
          NavigationService.navigateAndReplace(AppRoutes.products);
          break;
        case 3: // Cart
        NavigationService.navigateAndReplace(AppRoutes.cart);
          break;
        case 4: // Menu/Profile
        // Already on settings page (or navigate to profile)
          setState(() {
            _currentBottomNavIndex = index;
          });
          break;
      }
    }

}
