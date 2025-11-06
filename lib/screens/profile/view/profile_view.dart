import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:momy_kids/core/components/image_widgets.dart';
import 'package:momy_kids/core/constants/images_utils.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_palette.dart';
import '../../../core/localization/appLanguage.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/components/primary-button.dart';
import '../../../core/components/bottom_navigation_bar.dart';
import '../../../core/components/image_picker_bottom_sheet.dart';
import '../../../core/components/delete_image_bottom_sheet.dart';
import '../../../core/network/url_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/Common.dart';
import '../view_model/profile_view_model.dart';
import '../widgets/kid_details_bottom_sheet.dart';
import '../model/kid_model.dart';
import '../../../core/components/confirm_bottom_sheet.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _spouseNameController = TextEditingController();
  final _childrenCountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Address controllers
  final _areaController = TextEditingController();
  final _blockController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _governorateController = TextEditingController();

  late ProfileViewModel _viewModel;
  int _currentBottomNavIndex = 4; // Menu tab

  // Store original values for cancel functionality
  String _originalName = '';
  String _originalSpouseName = '';
  String _originalChildrenCount = '';
  String _originalPhoneNumber = '';
  String _originalEmail = '';
  String _originalArea = '';
  String _originalBlock = '';
  String _originalStreet = '';
  String _originalHouseNumber = '';
  String _originalGovernorate = '';
  String? _originalProfileImagePath;
  File? _originalProfileImage;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
      Future.delayed(Duration(seconds: 3), () {
        _viewModel.fetchGovernorates(context);
      });
    });
  }

  Future<void> _loadProfile() async {
    await _viewModel.loadProfile(context);
    _nameController.text = _viewModel.name;
    _spouseNameController.text = _viewModel.spouseName;
    _childrenCountController.text = _viewModel.childrenCount;
    _phoneController.text = _viewModel.phoneNumber;
    _emailController.text = _viewModel.email;

    // Load address
    _areaController.text = _viewModel.area;
    _blockController.text = _viewModel.block;
    _streetController.text = _viewModel.street;
    _houseNumberController.text = _viewModel.houseNumber;
    _governorateController.text = _viewModel.governorate;

    // Store original values for cancel functionality
    _originalName = _viewModel.name;
    _originalSpouseName = _viewModel.spouseName;
    _originalChildrenCount = _viewModel.childrenCount;
    _originalPhoneNumber = _viewModel.phoneNumber;
    _originalEmail = _viewModel.email;
    _originalArea = _viewModel.area;
    _originalBlock = _viewModel.block;
    _originalStreet = _viewModel.street;
    _originalHouseNumber = _viewModel.houseNumber;
    _originalGovernorate = _viewModel.governorate;
    _originalProfileImagePath = _viewModel.profileImagePath;
    _originalProfileImage = _viewModel.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _spouseNameController.dispose();
    _childrenCountController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _areaController.dispose();
    _blockController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _governorateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider<ProfileViewModel>(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FF),
        appBar: _buildAppBar(appLanguage, localizations),
        body: _buildBody(localizations),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() {
              _currentBottomNavIndex = index;
            });
            // TODO: Navigate to different screens based on index
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppLanguage appLanguage,
    AppLocalizations localizations,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFFF5F9FF),
      elevation: 0,
      // leading: IconButton(
      //   icon: const Icon(Icons.arrow_back, color: ColorPalette.textPrimary),
      //   onPressed: () => NavigationService.goBack(),
      // ),
      title: Text(
        localizations.translate('profile'),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorPalette.textPrimary,
        ),
      ),
      actions: [
        // Language Button
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Common.languageIcons(
            context: context,
            appLanguage: appLanguage,
            onLanguageChange: () {
              if (mounted) {
                _viewModel.clearError();
                _viewModel.onLanguageChanged(context);
                setState(() {});
              }
            },
          ),
        ),

        // Profile Picture
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              return CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    viewModel.profileImage != null
                        ? FileImage(viewModel.profileImage!)
                        : (viewModel.profileImagePath != null &&
                            viewModel.profileImagePath!.isNotEmpty)
                        ? NetworkImage(
                          UrlManager.imageBaseUrl + viewModel.profileImagePath!,
                        )
                        : null,
                child:
                    viewModel.profileImage == null
                        ? ((viewModel.profileImagePath == null ||
                                viewModel.profileImagePath!.isEmpty)
                            ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey,
                            )
                            : null)
                        : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody(AppLocalizations localizations) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        // Show loader when profile is being loaded
        if (viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: ColorPalette.primary),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Picture with Edit Button
                _buildProfilePicture(localizations),

                const SizedBox(height: 24),

                // Tab Selector
                _buildTabSelector(localizations),

                const SizedBox(height: 24),

                // Form Content based on selected tab
                _buildTabContent(localizations, viewModel),

                const SizedBox(height: 32),

                // Update and Cancel Buttons (hidden on Kids tab)
                if (viewModel.selectedTabIndex != 2)
                  _buildActionButtons(localizations),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePicture(AppLocalizations localizations) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: ColorPalette.primary.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child:
                    viewModel.profileImage != null
                        ? Image.file(viewModel.profileImage!, fit: BoxFit.cover)
                        : (viewModel.profileImagePath != null &&
                            viewModel.profileImagePath!.isNotEmpty)
                        ? Image.network(
                          '${UrlManager.imageBaseUrl}${viewModel.profileImagePath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[400],
                            );
                          },
                        )
                        : Icon(Icons.person, size: 50, color: Colors.grey[400]),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  // Store context-dependent references before async operations
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final localizations = AppLocalizations.of(context);
                  
                  // Show delete image bottom sheet first
                  final imageAction = await DeleteImageBottomSheet.show(context);
                  
                  // Check if widget is still mounted before proceeding
                  if (!mounted) return;
                  
                  if (imageAction == ImageAction.changePicture) {
                    // Show image picker bottom sheet
                    final pickedFile = await ImagePickerBottomSheet.show(context);
                    if (!mounted) return;
                    if (pickedFile != null) {
                      await viewModel.pickImage(context, pickedFile);
                    }
                  } else if (imageAction == ImageAction.deletePicture) {
                    // Delete the profile image via API
                    final success = await viewModel.deleteProfileImage(context);
                    if (!mounted) return;
                    
                    if (success) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.translate(
                              'PROFILE_PHOTO_DELETED_SUCCESSFULLY',
                            ),
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      if (viewModel.errorMessage.isNotEmpty && mounted) {
                        // Translate error message using stored localizations
                        String errorMessage = viewModel.errorMessage;
                        if (viewModel.errorKey.isNotEmpty) {
                          errorMessage = localizations.translate(viewModel.errorKey);
                          // Replace parameters in the error message
                          viewModel.errorParams.forEach((key, value) {
                            errorMessage = errorMessage.replaceAll('{$key}', value);
                          });
                        }
                        
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }
                  // If cancel, do nothing
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ColorPalette.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabSelector(AppLocalizations localizations) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (_governorateController.text.isEmpty &&
            viewModel.governorate.isNotEmpty) {
          _governorateController.text = viewModel.governorate;
        }
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
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
              _buildTab(
                localizations.translate('personal_details'),
                0,
                viewModel.selectedTabIndex,
                () => viewModel.setSelectedTabIndex(0),
                2,
              ),
              _buildTab(
                localizations.translate('address'),
                1,
                viewModel.selectedTabIndex,
                () => viewModel.setSelectedTabIndex(1),
                1,
              ),
              _buildTab(
                localizations.translate('kids'),
                2,
                viewModel.selectedTabIndex,
                () => viewModel.setSelectedTabIndex(2),
                1,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(
    String title,
    int index,
    int selectedIndex,
    VoidCallback onTap,
    int expanded,
  ) {
    final isSelected = index == selectedIndex;

    return Expanded(
      flex: expanded,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? ColorPalette.tabSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
                color:
                    isSelected
                        ? ColorPalette.primary
                        : ColorPalette.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    AppLocalizations localizations,
    ProfileViewModel viewModel,
  ) {
    switch (viewModel.selectedTabIndex) {
      case 0:
        return _buildPersonalDetailsForm(localizations);
      case 1:
        return _buildAddressForm(localizations);
      case 2:
        return _buildKidsForm(localizations);
      default:
        return _buildPersonalDetailsForm(localizations);
    }
  }

  Widget _buildPersonalDetailsForm(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            image: BaseImage(
              source: ImageSource.assetIcons,
              assetPath: ImageUtilsPath.icUser,
              iconColors: ColorPalette.primary,
            ),
            labelText: localizations.translate('name'),
            onChanged: (value) => _viewModel.setName(value),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _spouseNameController,
            image: BaseImage(
              source: ImageSource.assetIcons,
              assetPath: ImageUtilsPath.icSpouse,
              iconColors: ColorPalette.primary,
            ),
            labelText: localizations.translate('spouse_name_label'),
            onChanged: (value) => _viewModel.setSpouseName(value),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _childrenCountController,
            image: BaseImage(
              source: ImageSource.assetIcons,
              assetPath: ImageUtilsPath.icKids,
              iconColors: ColorPalette.primary,
            ),
            labelText: localizations.translate('how_many_children'),
            keyboardType: TextInputType.number,
            onChanged: (value) => _viewModel.setChildrenCount(value),
          ),
          const SizedBox(height: 16),
          _buildPhoneField(localizations),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            image: BaseImage(
              source: ImageSource.assetIcons,
              assetPath: ImageUtilsPath.icEmail,
              iconColors: ColorPalette.iconGray,
            ),
            labelText: localizations.translate('email'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => _viewModel.setEmail(value),
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _areaController,
            image: BaseImage(
              source: ImageSource.assetIcons,
              assetPath: ImageUtilsPath.icMap,
              iconColors: ColorPalette.primary,
            ),
            labelText: localizations.translate('area'),
            onChanged: (value) => _viewModel.setArea(value),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _blockController,
            image: BaseImage(
              source: ImageSource.assetIcons,
              assetPath: ImageUtilsPath.icMap,
              iconColors: ColorPalette.primary,
            ),
            labelText: localizations.translate('block'),
            onChanged: (value) => _viewModel.setBlock(value),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _streetController,
            image: BaseImage(
              source: ImageSource.assetIcons,
              assetPath: ImageUtilsPath.icMap,
              iconColors: ColorPalette.primary,
            ),
            labelText: localizations.translate('street'),
            onChanged: (value) => _viewModel.setStreet(value),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _houseNumberController,
            image: BaseImage(
              source: ImageSource.assetIcons,
              assetPath: ImageUtilsPath.icBottomOne,
              iconColors: ColorPalette.primary,
            ),
            labelText: localizations.translate('house_number'),
            keyboardType: TextInputType.number,
            onChanged: (value) => _viewModel.setHouseNumber(value),
          ),
          const SizedBox(height: 16),
          _buildGovernorateField(localizations),
        ],
      ),
    );
  }

  Widget _buildGovernorateField(AppLocalizations localizations) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Container(
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  _governorateController.text.isEmpty
                      ? null
                      : _governorateController.text,
              hint: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    BaseImage(
                      source: ImageSource.assetIcons,
                      assetPath: ImageUtilsPath.icBuildings,
                      iconColors: ColorPalette.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      localizations.translate('select'),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: ColorPalette.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              icon: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: ColorPalette.textSecondary,
                  size: 20,
                ),
              ),
              isExpanded: true,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: ColorPalette.textPrimary,
              ),
              items:
                  viewModel.governorates.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            BaseImage(
                              source: ImageSource.assetIcons,
                              assetPath: ImageUtilsPath.icBuildings,
                              iconColors: ColorPalette.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  color: ColorPalette.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _governorateController.text = newValue;
                  viewModel.setGovernorate(newValue);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildKidsForm(AppLocalizations localizations) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Header with Add Kids button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.translate('kids_details'),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Store context-dependent references before async operations
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final currentLocalizations = localizations;
                    
                    final kid = await KidDetailsBottomSheet.show(context);
                    if (!this.mounted) return;
                    
                    if (kid != null) {
                      viewModel.addKid(kid);
                      // Call API to add kids
                      final success = await viewModel.addKidsToProfile(context);
                      if (!this.mounted) return;
                      
                      if (success) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              currentLocalizations.translate(
                                'kids_added_successfully',
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // Translate error message using stored localizations
                        String errorMessage = viewModel.errorMessage;
                        if (viewModel.errorKey.isNotEmpty) {
                          errorMessage = currentLocalizations.translate(viewModel.errorKey);
                          // Replace parameters in the error message
                          viewModel.errorParams.forEach((key, value) {
                            errorMessage = errorMessage.replaceAll('{$key}', value);
                          });
                        }
                        
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: BaseImage(
                    source: ImageSource.assetIcons,
                    assetPath: ImageUtilsPath.icAddSquare,
                  ),
                  label: Text(localizations.translate('add_kids')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kids List
            if (viewModel.kids.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      localizations.translate('no_kids_added_yet'),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.translate('kids_empty_state_message'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: ColorPalette.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...viewModel.kids.asMap().entries.map((entry) {
                final index = entry.key;
                final kid = entry.value;
                return _buildKidCard(localizations, kid, index, viewModel);
              }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildKidCard(
    AppLocalizations localizations,
    Kid kid,
    int index,
    ProfileViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    BaseImage(
                      source: ImageSource.assetIcons,
                      assetPath: ImageUtilsPath.icUser,
                      iconColors: ColorPalette.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.translate('kid_name'),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: ColorPalette.textSecondary,
                            ),
                          ),
                          Text(
                            kid.name,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      // Store context-dependent references before async operations
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final currentLocalizations = localizations;
                      
                      final updatedKid = await KidDetailsBottomSheet.show(
                        context,
                        existingKid: kid,
                      );
                      if (!this.mounted) return;
                      
                      if (updatedKid != null) {
                        viewModel.updateKid(index, updatedKid);
                        // Call API to update only this kid
                        final success = await viewModel
                            .updateSingleKidInProfile(context, updatedKid);
                        if (!this.mounted) return;
                        
                        if (success) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                currentLocalizations.translate(
                                  'kids_updated_successfully',
                                ),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          // Translate error message using stored localizations
                          String errorMessage = viewModel.errorMessage;
                          if (viewModel.errorKey.isNotEmpty) {
                            errorMessage = currentLocalizations.translate(viewModel.errorKey);
                            // Replace parameters in the error message
                            viewModel.errorParams.forEach((key, value) {
                              errorMessage = errorMessage.replaceAll('{$key}', value);
                            });
                          }
                          
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: BaseImage(
                      source: ImageSource.assetIcons,
                      assetPath: ImageUtilsPath.icEdit,
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      // Store context-dependent references before async operations
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final currentLocalizations = localizations;
                      
                      final confirmed = await ConfirmBottomSheet.show(
                        context,
                        title: currentLocalizations.translate('confirm'),
                        message: currentLocalizations.translate(
                          'are_you_sure_delete_kid',
                        ),
                        confirmText: currentLocalizations.translate('yes'),
                        cancelText: currentLocalizations.translate('cancel'),
                      );
                      if (!this.mounted) return;
                      
                      if (confirmed) {
                        final success = await viewModel.deleteKidFromProfile(
                          context,
                          kid.id,
                          localIndex: index,
                        );
                        if (!this.mounted) return;
                        
                        if (success) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                currentLocalizations.translate(
                                  'kid_deleted_successfully',
                                ),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          // Translate error message using stored localizations
                          String errorMessage = viewModel.errorMessage;
                          if (viewModel.errorKey.isNotEmpty) {
                            errorMessage = currentLocalizations.translate(viewModel.errorKey);
                            // Replace parameters in the error message
                            viewModel.errorParams.forEach((key, value) {
                              errorMessage = errorMessage.replaceAll('{$key}', value);
                            });
                          }
                          
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: BaseImage(
                      source: ImageSource.assetIcons,
                      assetPath: ImageUtilsPath.icDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Gender
          Row(
            children: [
              BaseImage(
                source: ImageSource.assetIcons,
                assetPath: ImageUtilsPath.icGender,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('gender_label'),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: ColorPalette.textSecondary,
                    ),
                  ),
                  Text(
                    localizations.translate(kid.gender.toLowerCase()),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: ColorPalette.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Age
          Row(
            children: [
              BaseImage(
                source: ImageSource.assetIcons,
                assetPath: ImageUtilsPath.icKids,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('age'),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: ColorPalette.textSecondary,
                    ),
                  ),
                  Text(
                    kid.getAgeTranslated(
                      localizations.translate('years'),
                      localizations.translate('months'),
                      localizations.translate('year'),
                      localizations.translate('month'),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: ColorPalette.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AppLocalizations localizations,
    int index,
    ProfileViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('delete')),
          content: Text('Are you sure you want to delete this child?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                viewModel.deleteKid(index);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations.translate('kid_deleted_successfully'),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                localizations.translate('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required Widget image,
    required String labelText,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    bool readOnly = false,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        readOnly: readOnly,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: ColorPalette.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: image,
          filled: true,
          fillColor: readOnly ? Colors.grey[300] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            color: ColorPalette.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(AppLocalizations localizations) {
    return Container(
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
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        onChanged: (value) => _viewModel.setPhoneNumber(value),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: ColorPalette.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: localizations.translate('phone_number'),
          prefixIcon: BaseImage(
            source: ImageSource.assetIcons,
            assetPath: ImageUtilsPath.icPhoneGray,
            iconColors: ColorPalette.primary,
          ),
          suffixIcon: TextButton(
            onPressed: () {
              // TODO: Implement change phone number
              // var data = NavigationService.navigateTo(
              //   AppRoutes.mobileNumberVerified,arguments: {}
              // );
            },
            child: Text(
              localizations.translate('change'),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorPalette.primary,
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            color: ColorPalette.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations localizations) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Row(
          children: [
            // Cancel Button


            // Update Button
            Expanded(
              child: PrimaryButton(
                label: localizations.translate('update'),
                onClick: viewModel.isLoading ? null : _handleUpdate,
                isLoading: viewModel.isLoading,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCancelButton(localizations),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCancelButton(AppLocalizations localizations) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: viewModel.isLoading ? null : _handleCancel,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorPalette.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  localizations.translate('cancel'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: ColorPalette.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCancel() {
    // Restore original values to controllers
    _nameController.text = _originalName;
    _spouseNameController.text = _originalSpouseName;
    _childrenCountController.text = _originalChildrenCount;
    _phoneController.text = _originalPhoneNumber;
    _emailController.text = _originalEmail;
    _areaController.text = _originalArea;
    _blockController.text = _originalBlock;
    _streetController.text = _originalStreet;
    _houseNumberController.text = _originalHouseNumber;
    _governorateController.text = _originalGovernorate;

    // Restore original values to view model
    _viewModel.setName(_originalName);
    _viewModel.setSpouseName(_originalSpouseName);
    _viewModel.setChildrenCount(_originalChildrenCount);
    _viewModel.setPhoneNumber(_originalPhoneNumber);
    _viewModel.setEmail(_originalEmail);
    _viewModel.setArea(_originalArea);
    _viewModel.setBlock(_originalBlock);
    _viewModel.setStreet(_originalStreet);
    _viewModel.setHouseNumber(_originalHouseNumber);
    _viewModel.setGovernorate(_originalGovernorate);

    // Restore original profile image
    _viewModel.setProfileImage(_originalProfileImage, _originalProfileImagePath);

    // Clear any errors
    _viewModel.clearError();

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).translate('changes_discarded'),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      // Store context-dependent references before async operations
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final localizations = AppLocalizations.of(context);
      
      await _viewModel.updateProfile(context);
      
      // Check if widget is still mounted before showing snackbars
      if (!mounted) return;
      
      if (_viewModel.isSuccess) {
        // Update original values after successful update
        _originalName = _viewModel.name;
        _originalSpouseName = _viewModel.spouseName;
        _originalChildrenCount = _viewModel.childrenCount;
        _originalPhoneNumber = _viewModel.phoneNumber;
        _originalEmail = _viewModel.email;
        _originalArea = _viewModel.area;
        _originalBlock = _viewModel.block;
        _originalStreet = _viewModel.street;
        _originalHouseNumber = _viewModel.houseNumber;
        _originalGovernorate = _viewModel.governorate;
        _originalProfileImagePath = _viewModel.profileImagePath;
        _originalProfileImage = _viewModel.profileImage;
        
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              localizations.translate('profile_updated_successfully'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (_viewModel.errorMessage.isNotEmpty && mounted) {
          // Translate error message using stored localizations
          String errorMessage = _viewModel.errorMessage;
          if (_viewModel.errorKey.isNotEmpty) {
            errorMessage = localizations.translate(_viewModel.errorKey);
            // Replace parameters in the error message
            _viewModel.errorParams.forEach((key, value) {
              errorMessage = errorMessage.replaceAll('{$key}', value);
            });
          }
          
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
