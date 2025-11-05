import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/images_utils.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/localization/appLanguage.dart';
import '../../../../core/localization/appLocalization.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/components/text_widgets.dart';
import '../../../../core/components/image_widgets.dart';
import '../../../../core/components/app_background.dart';
import '../../../../core/components/primary-button.dart';
import '../../../../core/components/language_dialog.dart';
import '../../../../core/components/text_field_widgets.dart';
import '../../../../core/utils/Common.dart';
import '../view_model/forgot_password_view_model.dart';


class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    
    return ChangeNotifierProvider<ForgotPasswordViewModel>(
      create: (context) => _viewModel,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AppBackground(
          child: Column(
            children: [
              // Top section with language button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Common.languageIcons(
                      context: context,
                      appLanguage: appLanguage,
                      onLanguageChange: () {
                        FocusScope.of(context).unfocus();
                        if (mounted) {
                          // Reset form and hide error messages when language changes
                          _emailController.clear();
                          _formKey.currentState?.reset();
                          _viewModel.clearError();
                          _viewModel.setEmail('');

                          // Force rebuild to update keyboard language
                          setState(() {});
                        }
                      },
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 30),
              // App Logo
              _buildAppLogo(),
              // Main content
              const SizedBox(height: 30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [


                      const SizedBox(height: 40),

                      // Forgot Password Form
                      _buildForgotPasswordForm(localizations),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Column(
      children: [
        // Logo Icon
        BaseImage(
          assetPath: ImageUtilsPath.momyKidzLogo,
          source: ImageSource.asset,
          height: 68,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildForgotPasswordForm(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Forgot Password Title
          HeadingText(
            text: localizations.translate('forgot_password_title'),
            fontSize: 20,
          ),
          
          const SizedBox(height: 12),
          
          // Description Text
          BodyText(
            text: localizations.translate('enter_email_to_proceed'),
            fontSize: 14,
            color: ColorPalette.textSecondary,
          ),
          
          const SizedBox(height: 24),
          
          // Email Field
          EmailTextField(
            controller: _emailController,
            labelText: localizations.translate('email'),
            hintText: localizations.translate('enter_email_id'),
            onChanged: (value) {
              _viewModel.setEmail(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('email_required');
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return localizations.translate('valid_email_required');
              }
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          // Proceed Button
          Consumer<ForgotPasswordViewModel>(
            builder: (context, viewModel, child) {
              return SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: localizations.translate('proceed'),
                  onClick: viewModel.isLoading ? null : _handleProceed,
                  isLoading: viewModel.isLoading,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleProceed() async {
    if (_formKey.currentState!.validate()) {
      await _viewModel.sendForgotPasswordEmail(context);
      if (_viewModel.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('otp_sent_to_email')
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back or to next screen (e.g., email verification)
        NavigationService.navigateAndReplace(AppRoutes.emailOtpVerified,arguments: {
          'email':_viewModel.email,
          'from': AppRoutes.forgotPassword,
        });
      } else {
        if (_viewModel.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.getTranslatedError(context)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
