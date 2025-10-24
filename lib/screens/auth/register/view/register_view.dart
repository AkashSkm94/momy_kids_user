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
import '../view_model/register_view_model.dart';


class RegisterView extends StatefulWidget {
  final String phoneNumber;
  const RegisterView({super.key,required this.phoneNumber});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _spouseNameController = TextEditingController();
  final _childrenCountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late RegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel();
    _phoneController.text = widget.phoneNumber;
    _viewModel.setPhone(widget.phoneNumber);
    
    // Set preferred language after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appLanguage = Provider.of<AppLanguage>(context, listen: false);
      _viewModel.setPreferredLanguage(appLanguage.appLocal.languageCode);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _spouseNameController.dispose();
    _childrenCountController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider<RegisterViewModel>(
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
                          // Update error messages and preferred language when language changes
                          final appLanguage = Provider.of<AppLanguage>(context, listen: false);
                          _viewModel.setPreferredLanguage(appLanguage.appLocal.languageCode);
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

                      const SizedBox(height: 30),

                      // Registration Form
                      _buildRegistrationForm(localizations),

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

  Widget _buildRegistrationForm(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          HeadingText(
            text: localizations.translate('register'),
            fontSize: 24,
            color: ColorPalette.textPrimary,
          ),

          const SizedBox(height: 32),

          // Name Field
          _buildTextField(
            controller: _nameController,
            icon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icUser,),
            labelText: localizations.translate('full_name'),
            hintText: localizations.translate('full_name'),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('name_required');
              }
              return null;
            },
            onChanged: (value) => _viewModel.setName(value),
          ),

          const SizedBox(height: 20),

          // Spouse Name Field
          _buildTextField(
            controller: _spouseNameController,
            icon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icSpouse,),
            labelText: localizations.translate('spouse_name'),
            hintText: localizations.translate('spouse_name'),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) => _viewModel.setSpouseName(value),
          ),

          const SizedBox(height: 20),

          // Children Count Field
          _buildTextField(
            controller: _childrenCountController,
            icon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icKids,),
            labelText: localizations.translate('children_count'),
            hintText: localizations.translate('children_count'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
            onChanged: (value) => _viewModel.setChildrenCount(int.tryParse(value ?? '0')),
          ),

          const SizedBox(height: 20),

          // Phone Number Field
          _buildTextField(
            controller: _phoneController,
            icon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icPhoneGray,),
            labelText: localizations.translate('phone_number'),
            hintText: '+965 955-512-0951',
            keyboardType: TextInputType.phone,
            isReadOnly: true,
            isEnabled: false
          ),

          const SizedBox(height: 20),

          // Email Field
          _buildTextField(
            controller: _emailController,
            icon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icEmail,),
            labelText: localizations.translate('email'),
            hintText: localizations.translate('email'),
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('email_required');
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return localizations.translate('valid_email_required');
              }
              return null;
            },
            onChanged: (value) => _viewModel.setEmail(value),
          ),

          const SizedBox(height: 20),

          // Password Field
          PasswordTextField(
            controller: _passwordController,
            labelText: localizations.translate('password'),
            hintText: localizations.translate('password'),
            isRequired: true,
            onChanged: (value) => _viewModel.setPassword(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('password_required');
              }
              if (value.length < 6) {
                return localizations.translate('password_min_length');
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Confirm Password Field
          PasswordTextField(
            controller: _confirmPasswordController,
            labelText: localizations.translate('confirm_password'),
            hintText: localizations.translate('confirm_password'),
            isRequired: true,
            onChanged: (value) => _viewModel.setConfirmPassword(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.translate('confirm_password_required');
              }
              if (value != _passwordController.text) {
                return localizations.translate('passwords_not_match');
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Register Button
          Consumer<RegisterViewModel>(
            builder: (context, viewModel, child) {
              return SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: localizations.translate('register'),
                  onClick: viewModel.isLoading ? null : _handleRegister,
                  isLoading: viewModel.isLoading,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required Widget icon,
    required String labelText,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool isReadOnly = false,
    bool isRequired = false,
    bool isEnabled = true,
    int? maxLength,
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
        enabled: isEnabled,
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        validator: validator,
        onChanged: onChanged,
        readOnly: isReadOnly,
        maxLength: maxLength,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: ColorPalette.textPrimary,
        ),
        decoration: InputDecoration(
          label: isRequired 
            ? RichText(
                textDirection: Directionality.of(context),
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: labelText,
                      style: const TextStyle(
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
          prefixIcon: icon,
          filled: true,
          fillColor: isReadOnly ? Color(0xffF5F5F5) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          counterText: maxLength != null ? '' : null,
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
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await _viewModel.register(context);
      
      if (!mounted) return;
      
      if (_viewModel.isSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('registration_successful')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate to home page
        NavigationService.navigateAndReplace(AppRoutes.emailOtpVerified,arguments: {
          'email':_viewModel.email,
          'from': AppRoutes.register
        });
      } else {
        if (_viewModel.errorMessage.isNotEmpty) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_viewModel.getTranslatedError(context)),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}
