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
import '../../../core/components/otp_success_bottom_sheet.dart';
import '../../../core/utils/Common.dart';
import '../view_model/mobile_number_otp_verified_view_model.dart';

class MobileNumberOtpVerifiedView extends StatefulWidget {
  final String? phoneNumber;
  
  const MobileNumberOtpVerifiedView({super.key, this.phoneNumber});

  @override
  State<MobileNumberOtpVerifiedView> createState() => _MobileNumberOtpVerifiedViewState();
}

class _MobileNumberOtpVerifiedViewState extends State<MobileNumberOtpVerifiedView> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  late MobileNumberOtpVerifiedViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MobileNumberOtpVerifiedViewModel();
    _viewModel.startResendCountdown();
    
    // Set phone number from widget or from previous screen's viewModel
    if (widget.phoneNumber != null) {
      _viewModel.setPhoneNumber(widget.phoneNumber!);
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    
    return ChangeNotifierProvider<MobileNumberOtpVerifiedViewModel>(
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
                      
                      // OTP Verification Form
                      _buildOtpVerificationForm(localizations),
                      
                      // Submit Button
                      Column(
                        children: [
                          Consumer<MobileNumberOtpVerifiedViewModel>(
                            builder: (context, viewModel, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  label: localizations.translate('submit'),
                                  onClick: viewModel.isLoading ? null : _handleSubmitOtp,
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

  Widget _buildOtpVerificationForm(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        HeadingText(
          text: localizations.translate('verify_phone'),
          fontSize: 20,
          color: ColorPalette.textPrimary,
        ),
        
        const SizedBox(height: 16),
        
        // Instruction text
        BodyText(
          text: localizations.translate('enter_6_digit_code'),
          color: ColorPalette.textSecondary,
          fontSize: 14,
        ),
        
        const SizedBox(height: 32),
        
        // OTP Input Fields
        _buildOtpInputFields(),
        
        const SizedBox(height: 24),
        
        // Resend OTP
        _buildResendOtp(localizations),
      ],
    );
  }

  Widget _buildOtpInputFields() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ColorPalette.primary.withOpacity(0.3),
                width: 1,
              ),
              color: Colors.white,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  color: ColorPalette.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  _viewModel.setOtpDigit(index, value);
                  if (value.isNotEmpty) {
                    if (index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      _focusNodes[index].unfocus();
                    }
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
                onTap: () {
                  // Find the first empty field from left to right
                  int firstEmptyIndex = _getFirstEmptyIndex();
                  
                  // If user taps on a field that's not the first empty, move focus to first empty
                  if (index != firstEmptyIndex) {
                    _focusNodes[firstEmptyIndex].requestFocus();
                  } else {
                    // If tapping on the first empty field, select the text
                    _otpControllers[index].selection = TextSelection.fromPosition(
                      TextPosition(offset: _otpControllers[index].text.length),
                    );
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  // Helper method to find the first empty OTP field from left to right
  int _getFirstEmptyIndex() {
    for (int i = 0; i < 6; i++) {
      if (_otpControllers[i].text.isEmpty) {
        return i;
      }
    }
    // If all fields are filled, return the last index
    return 5;
  }

  Widget _buildResendOtp(AppLocalizations localizations) {
    return Consumer<MobileNumberOtpVerifiedViewModel>(
      builder: (context, viewModel, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BodyText(
              text: localizations.translate('didnt_receive_code'),
              color: ColorPalette.textSecondary,
              fontSize: 14,
            ),
            const SizedBox(width: 4),
            if (viewModel.canResend)
              LinkText(
                text: localizations.translate('resend'),
                fontSize: 14,
                onTap: _handleResendOtp,
              )
            else
              BodyText(
                text: '${localizations.translate('resend')} (${viewModel.formatCountdown(viewModel.resendCountdown)})',
                color: ColorPalette.textSecondary,
                fontSize: 14,
              ),
          ],
        );
      },
    );
  }

  void _handleSubmitOtp() async {
    await _viewModel.submitOtp(context);
    
    if (mounted) {
      if (_viewModel.isSuccess) {
        // Show success bottom sheet
        OtpSuccessBottomSheet.show(
          context,
          phoneNumber: _viewModel.phoneNumber,

        );
      } else if (_viewModel.errorMessage.isNotEmpty) {
        // Show error snackbar
        OtpSuccessBottomSheet.show(
          context,
          phoneNumber: _viewModel.phoneNumber,

        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.getTranslatedError(context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleResendOtp() async {
    await _viewModel.resendOtp(context);
    
    // Clear all OTP controller fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    
    // Focus on first field
    _focusNodes[0].requestFocus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('otp_resent')),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}

