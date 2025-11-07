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
import '../../../../core/components/social_login_buttons.dart';
import '../../../../core/components/text_field_widgets.dart';
import '../../../../core/utils/Common.dart';
import '../view_model/login_view_model.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    
    return ChangeNotifierProvider<LoginViewModel>(
      create: (context) => _viewModel,
      child: Scaffold(
        body: AppBackground(
          child: Column(
            children: [
              // Top section with language button
              Padding(
                padding: const EdgeInsets.only(right: 16.0,left: 16.0,top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Common.languageIcons(
                      context: context,
                      appLanguage: appLanguage,
                      onLanguageChange: () {
                        if (mounted) {
                          // Reset form and hide error messages when language changes
                          FocusScope.of(context).unfocus();
                          _emailController.clear();
                          _passwordController.clear();
                          _formKey.currentState?.reset();
                          _viewModel.clearError();
                          _viewModel.setEmail('');
                          _viewModel.setPassword('');

                          // Force rebuild to update keyboard language
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
                      const SizedBox(height: 30),
                      // App Logo
                      _buildAppLogo(),
                      
                      const SizedBox(height: 30),
                      
                      // Login Form
                      _buildLoginForm(localizations),
                      
                      const SizedBox(height: 40),
                      
                      // Social Login Section
                      Consumer<LoginViewModel>(
                        builder: (context, viewModel, child) {
                          return SocialLoginSection(
                            onGooglePressed: viewModel.handleGoogleLogin,
                            onApplePressed: viewModel.handleAppleLogin,
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Sign Up Link
                      _buildSignUpLink(localizations),
                      
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

  Widget _buildLoginForm(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Login Title
          HeadingText(text: localizations.translate('login'),fontSize: 20,),
          
          const SizedBox(height: 20),
          
          // Email Field
          EmailTextField(
            controller: _emailController,
            labelText: localizations.translate('email'),
            hintText: localizations.translate('enter_email_id'),
            onChanged: (value) {
              _viewModel.setEmail(value);
            },
            validator: (value){
              if (value == null || value.isEmpty) {
                return localizations.translate('email_required');
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return localizations.translate('valid_email_required');
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Password Field
          PasswordTextField(
            controller: _passwordController,
            labelText: localizations.translate('password'),
            hintText: localizations.translate('enter_password'),
            onChanged: (value) {
              _viewModel.setPassword(value);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: LinkText(
              decoration: TextDecoration.none,
              text: localizations.translate('forgot_password'),
              onTap: () {
                NavigationService.navigateTo(AppRoutes.forgotPassword);
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Login Button
          Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              return SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: localizations.translate('login'),
                  onClick: viewModel.isLoading ? null : _handleLogin,
                  isLoading: viewModel.isLoading,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LocalizedText(
          translationKey: 'dont_have_account',
          color: ColorPalette.textSecondary,
          fontSize: 14,
        ),
        const SizedBox(width: 8),
        LinkText(
          text: localizations.translate('sign_up'),
          onTap: () {
            NavigationService.navigateTo(AppRoutes.mobileNumberVerified);
          },
        ),
      ],
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await _viewModel.login(context);
      if (_viewModel.isSuccess) {
        NavigationService.navigateAndClearStack(AppRoutes.products);
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

