import 'package:flutter/material.dart';
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
import '../view_model/forgot_password_view_model.dart';


class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    
    return ChangeNotifierProvider<ForgotPasswordViewModel>(
      create: (context) => _viewModel,
      child: Scaffold(
        body: AppBackground(
          child: Column(
            children: [
              // Top section with language button
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
                          _viewModel.onLanguageChanged();
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // App Logo and Name
                      _buildAppLogo(),
                      
                      const SizedBox(height: 40),
                      
                      // Reset Password Form
                      _buildResetPasswordForm(localizations),
                      
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
      ],
    );
  }

  Widget _buildResetPasswordForm(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          HeadingText(
            text: localizations.translate('reset_password'),
            fontSize: 20,
            color: ColorPalette.textPrimary,
          ),
          
          const SizedBox(height: 20),
          
          // Current Password Field
          _buildPasswordField(
            controller: _currentPasswordController,
            labelText: localizations.translate('current_password'),
            hintText: localizations.translate('current_password'),
            onChanged: (value) => _viewModel.setCurrentPassword(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('current_password_required');
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // New Password Field
          _buildPasswordField(
            controller: _newPasswordController,
            labelText: localizations.translate('new_password'),
            hintText: localizations.translate('new_password'),
            onChanged: (value) => _viewModel.setNewPassword(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('new_password_required');
              }
              if (value.length < 6) {
                return localizations.translate('password_min_length');
              }
              if (value == _currentPasswordController.text) {
                return localizations.translate('new_password_different');
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Confirm Password Field
          _buildPasswordField(
            controller: _confirmPasswordController,
            labelText: localizations.translate('confirm_password'),
            hintText: localizations.translate('confirm_password'),
            onChanged: (value) => _viewModel.setConfirmPassword(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('confirm_password_required');
              }
              if (value != _newPasswordController.text) {
                return localizations.translate('passwords_not_match');
              }
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          // Reset Password Button
          Consumer<ForgotPasswordViewModel>(
            builder: (context, viewModel, child) {
              return SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: localizations.translate('reset_password'),
                  onClick: viewModel.isLoading ? null : _handleResetPassword,
                  isLoading: viewModel.isLoading,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Consumer<ForgotPasswordViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
            obscureText: viewModel.obscurePassword,
            validator: validator,
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: ColorPalette.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: ColorPalette.primary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: ColorPalette.primary,
                ),
                onPressed: viewModel.togglePasswordVisibility,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ColorPalette.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ColorPalette.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ColorPalette.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              labelStyle: const TextStyle(
                fontFamily: 'Montserrat',
                color: ColorPalette.textSecondary,
                fontSize: 16,
              ),
              hintStyle: const TextStyle(
                fontFamily: 'Montserrat',
                color: ColorPalette.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      await _viewModel.resetPassword(context);
      if (_viewModel.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('password_reset_successful')),
            backgroundColor: Colors.green,
          ),
        );
        NavigationService.goBack();
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

