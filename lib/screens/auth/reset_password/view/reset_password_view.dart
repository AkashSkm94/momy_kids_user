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
import '../view_model/reset_password_view_model.dart';


class ResetPasswordView extends StatefulWidget {
  final String? email;
  final String? otpCode;
  
  const ResetPasswordView({
    super.key,
    this.email,
    this.otpCode,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late ResetPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ResetPasswordViewModel();
    _viewModel.setEmail(widget.email);
    _viewModel.setOtpCode(widget.otpCode ?? '');
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    
    return ChangeNotifierProvider<ResetPasswordViewModel>(
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
                        // Unfocus any text field to close keyboard before language change
                        FocusScope.of(context).unfocus();
                        
                        final languageChanged = await showLanguageDialog(context);
                        if (languageChanged && mounted) {
                          // Reset form and hide error messages when language changes
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                          _formKey.currentState?.reset();
                          _viewModel.clearError();
                          _viewModel.setNewPassword('');
                          _viewModel.setConfirmPassword('');
                          
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResetPasswordForm(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reset Password Title
          HeadingText(
            text: localizations.translate('reset_password_title'),
            fontSize: 20,
          ),
          
          const SizedBox(height: 24),
          
          // New Password Field
          Consumer<ResetPasswordViewModel>(
            builder: (context, viewModel, child) {
              return _buildPasswordField(
                controller: _newPasswordController,
                labelText: localizations.translate('new_password'),
                obscureText: viewModel.obscureNewPassword,
                onToggleVisibility: viewModel.toggleNewPasswordVisibility,
                onChanged: (value) => viewModel.setNewPassword(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.translate('new_password_required');
                  }
                  if (value.length < 6) {
                    return localizations.translate('password_min_length');
                  }
                  return null;
                },
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Confirm Password Field
          Consumer<ResetPasswordViewModel>(
            builder: (context, viewModel, child) {
              return _buildPasswordField(
                controller: _confirmPasswordController,
                labelText: localizations.translate('confirm_password'),
                obscureText: viewModel.obscureConfirmPassword,
                onToggleVisibility: viewModel.toggleConfirmPasswordVisibility,
                onChanged: (value) => viewModel.setConfirmPassword(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.translate('confirm_password_required');
                  }
                  if (value != _newPasswordController.text) {
                    return localizations.translate('passwords_not_match');
                  }
                  return null;
                },
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Reset Password Button
          Consumer<ResetPasswordViewModel>(
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
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
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
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: ColorPalette.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: ColorPalette.primary,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: ColorPalette.textSecondary,
            ),
            onPressed: onToggleVisibility,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
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
          errorStyle: const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.red,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      await _viewModel.resetPassword(context);
      if (_viewModel.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('password_reset_successful')
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to login screen
        NavigationService.navigateAndClearStack(AppRoutes.login);
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

