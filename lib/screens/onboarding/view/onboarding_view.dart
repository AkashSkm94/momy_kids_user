import 'package:flutter/material.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
import 'package:provider/provider.dart';
import '../../../core/components/language_dialog.dart';
import '../../../core/localization/appLanguage.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/constants/color_palette.dart';
import '../../../core/components/text_widgets.dart';
import '../../../core/components/image_widgets.dart';
import '../../../core/components/app_background.dart';
import '../../../core/components/primary-button.dart';
import '../view_model/onboarding_view_model.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late OnboardingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OnboardingViewModel();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    
    return ChangeNotifierProvider<OnboardingViewModel>(
      create: (context) => _viewModel,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [


                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 60),

                            // App Logo
                            BaseImage(
                              source: ImageSource.asset,
                              assetPath: ImageUtilsPath.momyKidzLogo,
                            ),

                            const SizedBox(height: 20),

                            // Onboarding Image
                            BaseImage(
                              source: ImageSource.asset,
                              assetPath: ImageUtilsPath.onboarding,
                            ),

                            // Text Content
                            const SizedBox(height: 20),
                            _buildTextContent(localizations),

                            const SizedBox(height: 20),

                            // Get Started Button
                            _buildGetStartedButton(localizations),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LanguageButton(
                      currentLanguage: appLanguage.appLocal.languageCode == 'ar' ? 'AR' : 'EN',
                      onTap: () async {
                        final languageChanged = await showLanguageDialog(context);
                        if (languageChanged && mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
                                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(AppLocalizations localizations) {
    return Column(
      children: [
        // Main heading
        HeadingText(
          text: localizations.translate('welcome'),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 16),
        
        // Description
        BodyText(
          text: localizations.translate('welcome_subtitle'),
          textAlign: TextAlign.center,
          color: ColorPalette.textSecondary,
          fontSize: 16,
        ),
        SizedBox(height: 16),

        // Description
        BodyText(
          text: localizations.translate('welcome_subtitle2'),
          textAlign: TextAlign.center,
          color: ColorPalette.textSecondary,
          fontSize: 16,
        ),
      ],
    );
  }

  Widget _buildGetStartedButton(AppLocalizations localizations) {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: localizations.translate('get_started'),
            onClick: viewModel.isLoading ? null : () => viewModel.handleGetStarted(),
            isLoading: viewModel.isLoading,
          ),
        );
      },
    );
  }
}

