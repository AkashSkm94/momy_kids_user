import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/images_utils.dart';
import '../../../core/constants/color_palette.dart';
import '../../../core/localization/appLanguage.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/components/text_widgets.dart';
import '../../../core/components/image_widgets.dart';
import '../../../core/components/app_background.dart';
import '../../../core/components/primary-button.dart';
import '../../../core/components/language_dialog.dart';
import '../../../core/utils/Common.dart';
import '../view_model/mobile_number_verified_view_model.dart';

class MobileNumberVerifiedView extends StatefulWidget {
  const MobileNumberVerifiedView({super.key});

  @override
  State<MobileNumberVerifiedView> createState() => _MobileNumberVerifiedViewState();
}

class _MobileNumberVerifiedViewState extends State<MobileNumberVerifiedView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  late MobileNumberVerifiedViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MobileNumberVerifiedViewModel();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    
    return ChangeNotifierProvider<MobileNumberVerifiedViewModel>(
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
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App Logo and Name
                      _buildAppLogo(),

                      // Verification Form
                      _buildVerificationForm(localizations),

                      // Submit Button
                      Column(
                        children: [
                          Consumer<MobileNumberVerifiedViewModel>(
                            builder: (context, viewModel, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  label: localizations.translate('send_otp'),
                                  onClick: viewModel.isLoading ? null : _handleSendOtp,
                                  isLoading: viewModel.isLoading,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
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

  Widget _buildVerificationForm(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          HeadingText(
            text: localizations.translate('verify_phone_number'),
            fontSize: 20,
            color: ColorPalette.textPrimary,
          ),
          const SizedBox(height: 16),

          _buildPhoneNumberField(localizations),
          
          // Error Message Display
          Consumer<MobileNumberVerifiedViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.errorMessage.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: BodyText(
                            text: viewModel.getTranslatedError(context),
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberField(AppLocalizations localizations) {
    return Consumer<MobileNumberVerifiedViewModel>(
      builder: (context, viewModel, child) {
        final isArabic =
            Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

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
          child: Row(
            children: [
              // Country Code Dropdown
              Container(
                height: 48, // Fixed height to reduce dropdown size
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE9FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isArabic ? 0 : 12),
                    bottomLeft: Radius.circular(isArabic ? 0 : 12),
                    topRight: Radius.circular(isArabic ? 12 : 0),
                    bottomRight: Radius.circular(isArabic ? 12 : 0),
                  ),
                  border: Border.all(
                    color: ColorPalette.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: viewModel.selectedCountry,
                    icon: const Icon(Icons.keyboard_arrow_down, color: ColorPalette.primary, size: 20),
                    iconSize: 20,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: ColorPalette.textPrimary,
                    ),
                    isExpanded: false,
                    isDense: true,
                    items: viewModel.countryCodes.map((country) {
                      return DropdownMenuItem<String>(
                        value: country['country'],
                        child: Container(
                          height: 32, // Reduced height for dropdown items
                          alignment: Alignment.centerLeft,
                          child: Text(
                            country['country']!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: ColorPalette.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        viewModel.setSelectedCountry(newValue);
                        viewModel.setError('');
                      }
                    },
                  ),
                ),
              ),
              
              // Phone Number Input
              Expanded(
                child: Container(
                  height: 48, // Match the dropdown height
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(isArabic ? 0 : 12),
                      bottomRight: Radius.circular(isArabic ? 0 : 12),
                      topLeft: Radius.circular(isArabic ? 12 : 0),
                      bottomLeft: Radius.circular(isArabic ? 12 : 0),
                    ),
                    border: Border.all(
                      color: ColorPalette.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: ColorPalette.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: localizations.translate('phone_number'),
                      hintStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        color: ColorPalette.iconGray,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      viewModel.setPhoneNumber(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSendOtp() async {
    if (_formKey.currentState!.validate()) {
      await _viewModel.sendOtp(context);
      
      if (_viewModel.errorMessage.isNotEmpty && mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(_viewModel.errorMessage),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    }
  }
}

