import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
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
import '../view_model/email_otp_verified_view_model.dart';
import '../../../core/components/email_success_bottom_sheet.dart';

class EmailOtpVerifiedView extends StatefulWidget {
  final String email;
  final String from;

  const EmailOtpVerifiedView({super.key, required this.email,required this.from});

  @override
  State<EmailOtpVerifiedView> createState() => _EmailOtpVerifiedViewState();
}

class _EmailOtpVerifiedViewState extends State<EmailOtpVerifiedView> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  late EmailOtpVerifiedViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EmailOtpVerifiedViewModel();
    _viewModel.startResendCountdown();
    
    // Set email from widget
    _viewModel.setEmail(widget.email);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);
    
    return ChangeNotifierProvider<EmailOtpVerifiedViewModel>(
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
                          Consumer<EmailOtpVerifiedViewModel>(
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
          text: localizations.translate('verify_email'),
          fontSize: 20,
          color: ColorPalette.textPrimary,
        ),
        
        const SizedBox(height: 16),
        
        // Instruction text
        BodyText(
          text: localizations.translate('enter_6_digit_code_email'),
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
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 24,
        color: ColorPalette.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorPalette.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: ColorPalette.primary,
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: ColorPalette.primary,
          width: 1,
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: 6,
        controller: _otpController,
        focusNode: _otpFocusNode,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onCompleted: (pin) {
          // Update view model with complete OTP
          for (int i = 0; i < pin.length && i < 6; i++) {
            _viewModel.setOtpDigit(i, pin[i]);
          }
        },
        onChanged: (value) {
          // Update view model as user types
          for (int i = 0; i < value.length && i < 6; i++) {
            _viewModel.setOtpDigit(i, value[i]);
          }
          // Clear remaining digits if user deletes
          for (int i = value.length; i < 6; i++) {
            _viewModel.setOtpDigit(i, '');
          }
        },
      ),
    );
  }

  Widget _buildResendOtp(AppLocalizations localizations) {
    return Consumer<EmailOtpVerifiedViewModel>(
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
    await _viewModel.submitOtp(context,widget.from);
    
    if (mounted) {
      if (_viewModel.isSuccess) {
        // Show success bottom sheet
        EmailSuccessBottomSheet.show(
          context,
          email: _viewModel.email,
          from: widget.from,
          otpCode: _viewModel.otpCode,
        );
      } else if (_viewModel.errorMessage.isNotEmpty) {
        // Show error snackbar
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

  void _handleResendOtp() async {
    await _viewModel.resendOtp(context);
    
    if (mounted) {
      if (_viewModel.errorMessage.isNotEmpty) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.getTranslatedError(context)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Clear OTP controller
        _otpController.clear();
        
        // Clear view model OTP digits
        for (int i = 0; i < 6; i++) {
          _viewModel.setOtpDigit(i, '');
        }
        
        // Focus on OTP input
        _otpFocusNode.requestFocus();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('otp_resent')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

