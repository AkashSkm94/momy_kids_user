import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/appLanguage.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/network/apiutils.dart';
import '../../../core/network/url_manager.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/storage/local_storage_manager.dart';
import '../model/kid_model.dart';
import '../model/user_profile_model.dart';

class ProfileViewModel extends ChangeNotifier {


  UserProfile? _userProfile;
  String _name = '';
  String _spouseName = '';
  String _childrenCount = '';
  String _phoneNumber = '';
  String _email = '';
  String? _profileImagePath;
  File? _profileImage;
  
  // Address fields
  String _area = '';
  String _block = '';
  String _street = '';
  String _houseNumber = '';
  String _governorate = '';
  List<String> _governorates = [];
  
  // Kids list
  List<Kid> _kids = [];
  
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  String _errorKey = '';
  Map<String, String> _errorParams = {};

  // Getters
  UserProfile? get userProfile => _userProfile;
  String get name => _name;
  String get spouseName => _spouseName;
  String get childrenCount => _childrenCount;
  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String? get profileImagePath => _profileImagePath;
  File? get profileImage => _profileImage;
  
  // Address getters
  String get area => _area;
  String get block => _block;
  String get street => _street;
  String get houseNumber => _houseNumber;
  String get governorate => _governorate;
  List<String> get governorates => _governorates;
  
  // Kids getters
  List<Kid> get kids => _kids;
  
  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String get errorMessage => _errorMessage;
  String get errorKey => _errorKey;
  Map<String, String> get errorParams => _errorParams;

  // Setters
  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setSpouseName(String spouseName) {
    _spouseName = spouseName;
    notifyListeners();
  }

  void setChildrenCount(String count) {
    _childrenCount = count;
    notifyListeners();
  }

  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  // Address setters
  void setArea(String area) {
    _area = area;
    notifyListeners();
  }

  void setBlock(String block) {
    _block = block;
    notifyListeners();
  }

  void setStreet(String street) {
    _street = street;
    notifyListeners();
  }

  void setHouseNumber(String houseNumber) {
    _houseNumber = houseNumber;
    notifyListeners();
  }

  void setGovernorate(String governorate) {
    _governorate = governorate;
    notifyListeners();
  }

  Future<void> fetchGovernorates(BuildContext context) async {
    try {
      final localizations = AppLocalizations.of(context);

      String language = localizations.locale!.languageCode!;
      if(language.isNotEmpty){
        language = language[0].toUpperCase() + language.substring(1);
      }
      final response = await ApiUtils.get(
        endpoint: '${UrlManager.governorates}$language',
      );
      print(response);
      if (response.isSuccess && response.hasData) {
        final List<dynamic> list = response.data['data'] as List<dynamic>;
        _governorates = list
            .map((e) => (e as Map<String, dynamic>)['name'] as String)
            .toList();
        notifyListeners();
      }
    } catch (_) {
      print("error");
    }
  }

  // Kids methods
  void addKid(Kid kid) {
    _kids.add(kid);
    notifyListeners();
  }

  // Check if a kid with the same name, gender, and DOB already exists
  bool isDuplicateKid(Kid newKid, {String? excludeKidId}) {
    return _kids.any((existingKid) {
      // Skip the kid being updated (if excludeKidId is provided)
      if (excludeKidId != null && existingKid.id == excludeKidId) {
        return false;
      }
      
      // Compare name (case-insensitive)
      final nameMatches = existingKid.name.trim().toLowerCase() == 
                         newKid.name.trim().toLowerCase();
      
      // Compare gender (case-insensitive)
      final genderMatches = existingKid.gender.trim().toLowerCase() == 
                           newKid.gender.trim().toLowerCase();
      
      // Compare date of birth
      bool dobMatches = false;
      if (existingKid.dateOfBirth == null && newKid.dateOfBirth == null) {
        dobMatches = true;
      } else if (existingKid.dateOfBirth != null && newKid.dateOfBirth != null) {
        // Compare only year, month, and day (ignore time)
        final existingDob = existingKid.dateOfBirth!;
        final newDob = newKid.dateOfBirth!;
        dobMatches = existingDob.year == newDob.year &&
                    existingDob.month == newDob.month &&
                    existingDob.day == newDob.day;
      }
      
      return nameMatches && genderMatches && dobMatches;
    });
  }

  // Add kids via API
  Future<bool> addKidsToProfile(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    if (_kids.isEmpty) {
      setError(
        localizations.translate('no_kids_to_add'),
        errorKey: 'no_kids_to_add',
      );
      return false;
    }

    setLoading(true);
    clearError();

    try {
      // Prepare children data for API
      final children = _kids.map((kid) => kid.toApiJson()).toList();
      
      final response = await ApiUtils.post(
        endpoint: UrlManager.addKids,
        body: {
          'children': children,
        },
      );

      if (response.isSuccess) {
        setSuccess(true);
        return true;
      } else {
        // Translate the error message from API response
        final errorMsg = response.message.isNotEmpty 
            ? localizations.translate(response.message) 
            : localizations.translate('kids_add_failed');
        setError(errorMsg,errorKey: response.message);
        return false;
      }
    } catch (e) {
      setError(
        localizations.translate('kids_add_failed'),
        errorKey: 'kids_add_failed',
      );
      print('Error adding kids: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }


  // Update a single kid via API
  Future<bool> updateSingleKidInProfile(BuildContext context, Kid kid) async {
    final localizations = AppLocalizations.of(context);

    setLoading(true);
    clearError();

    try {
      final childPayload = kid.toUpdateApiJson();

      final response = await ApiUtils.put(
        endpoint: UrlManager.updateKids,
        body: {
          'children': [childPayload],
        },
      );

      if (response.isSuccess) {
        setSuccess(true);
        return true;
      } else {
        final errorMsg = response.message.isNotEmpty
            ? localizations.translate(response.message)
            : localizations.translate('kids_update_failed');
        setError(errorMsg);
        return false;
      }
    } catch (e) {
      setError(
        localizations.translate('kids_update_failed'),
        errorKey: 'kids_update_failed',
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  void updateKid(int index, Kid kid) {
    if (index >= 0 && index < _kids.length) {
      _kids[index] = kid;
      notifyListeners();
    }
  }

  void deleteKid(int index) {
    if (index >= 0 && index < _kids.length) {
      _kids.removeAt(index);
      notifyListeners();
    }
  }

  // Delete kid via API
  Future<bool> deleteKidFromProfile(BuildContext context, String childId, {int? localIndex}) async {
    final localizations = AppLocalizations.of(context);
    setLoading(true);
    clearError();

    try {
      final endpoint = UrlManager.deleteKid.replaceAll('{childId}', childId);
      final response = await ApiUtils.delete(endpoint: endpoint);

      if (response.isSuccess) {
        // Remove from local list if index provided, else search by id
        if (localIndex != null && localIndex >= 0 && localIndex < _kids.length) {
          _kids.removeAt(localIndex);
        } else {
          _kids.removeWhere((k) => k.id == childId);
        }
        notifyListeners();
        setSuccess(true);
        return true;
      } else {
        final errorMsg = response.message.isNotEmpty
            ? localizations.translate(response.message)
            : localizations.translate('kids_delete_failed');
        setError(errorMsg);
        return false;
      }
    } catch (e) {
      setError(
        localizations.translate('kids_delete_failed'),
        errorKey: 'kids_delete_failed',
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setProfileImage(File? image, String? path) {
    _profileImage = image;
    _profileImagePath = path;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setSuccess(bool success) {
    _isSuccess = success;
    notifyListeners();
  }

  void setError(String error, {String? errorKey, Map<String, String>? errorParams}) {
    _errorMessage = error;
    _errorKey = errorKey ?? '';
    _errorParams = errorParams ?? {};
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    notifyListeners();
  }
  
  // Get translated error message based on current language
  String getTranslatedError(BuildContext context) {
    if (_errorKey.isEmpty) {
      return _errorMessage;
    }
    
    final localizations = AppLocalizations.of(context);
    String translatedMessage = localizations.translate(_errorKey);
    
    // Replace parameters in the error message
    _errorParams.forEach((key, value) {
      translatedMessage = translatedMessage.replaceAll('{$key}', value);
    });
    
    return translatedMessage;
  }
  
  // Called when language changes to refresh data
  void onLanguageChanged(BuildContext context) {
    if (_errorKey.isNotEmpty) {
      notifyListeners();
    }
    fetchGovernorates(context);
  }

  // Load profile data from local storage or API
  Future<void> loadProfile(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    setLoading(true);
    clearError();

    try {
      final storage = await LocalStorageManager.getInstance();

      // Get userId from local storage
      final userId = storage.getString(LocalStorageManager.keyUserId);
      
      if (userId == null || userId.isEmpty) {
        setError(
          localizations.translate('user_id_not_found'),
          errorKey: 'user_id_not_found',
        );
        setLoading(false);
        return;
      }
      
      // Replace {userId} in the endpoint with actual userId
      final endpoint = UrlManager.profile.replaceAll('{userId}', userId);
      
      // Call profile API
      final response = await ApiUtils.get(
        endpoint: endpoint,
      );
      
      if (response.isSuccess && response.hasData) {
        final data = response.data['data'];
        if (data != null) {
          // Parse the user profile
          _userProfile = UserProfile.fromJson(data);
          
          // Update individual fields for easy access
          _name = _userProfile!.name;
          _email = _userProfile!.email;
          _phoneNumber = _userProfile!.phoneNumber;
          _profileImagePath = _userProfile!.profilePicture;
          
          // Update customer profile fields if available
          if (_userProfile!.customerProfile != null) {
            _spouseName = _userProfile!.customerProfile!.spouseName ?? '';
            _childrenCount = _userProfile!.customerProfile!.kidsCount?.toString() ?? '';
            _area = _userProfile!.customerProfile!.area ?? '';
            _block = _userProfile!.customerProfile!.block ?? '';
            _street = _userProfile!.customerProfile!.street ?? '';
            _houseNumber = _userProfile!.customerProfile!.houseNumber ?? '';
            _governorate = _userProfile!.customerProfile!.governorate ?? '';
            
            // Convert children to kids list
            _kids = _userProfile!.customerProfile!.children.map((child) {
              return Kid(
                id: child.id,
                name: child.name,
                gender: child.gender ?? '',
                dateOfBirth: child.dateOfBirth ?? DateTime.now(),
              );
            }).toList();
          }
          
          // Save profile data to local storage
          await storage.setString(LocalStorageManager.keyUserName, _name);
          await storage.setString(LocalStorageManager.keyUserEmail, _email);
          await storage.setString(LocalStorageManager.keyUserPhone, _phoneNumber);
          
          if (_spouseName.isNotEmpty) {
            await storage.setString(LocalStorageManager.keySpouseName, _spouseName);
          }
          
          if (_childrenCount.isNotEmpty) {
            await storage.setInt(LocalStorageManager.keyKidsCount, int.tryParse(_childrenCount) ?? 0);
          }

          notifyListeners();
        } else {
          setError(
            localizations.translate('profile_data_not_found'),
            errorKey: 'profile_data_not_found',
          );
        }
      } else {
        // Translate the error message from API response
        final errorMsg = response.message.isNotEmpty 
            ? localizations.translate(response.message) 
            : localizations.translate('profile_load_failed');
        setError(errorMsg,errorKey: response.message);
      }
      
    } catch (e) {
      setError(
        localizations.translate('profile_load_failed'),
        errorKey: 'profile_load_failed',
      );
      print('Error loading profile: $e');
    } finally {
      setLoading(false);
    }
  }

  // Update profile
  Future<void> updateProfile(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    if (_name.isEmpty) {
      setError(
        localizations.translate('name_required'),
        errorKey: 'name_required',
      );
      return;
    }

    setLoading(true);
    clearError();

    try {
      final storage = await LocalStorageManager.getInstance();
      final userId = storage.getString(LocalStorageManager.keyUserId);
      
      if (userId == null || userId.isEmpty) {
        setError(
          localizations.translate('user_id_not_found'),
          errorKey: 'user_id_not_found',
        );
        setLoading(false);
        return;
      }

      // Prepare form data fields
      final fields = <String, String>{
        'name': _name,
        'preferredLanguage':localizations.locale!.languageCode,
      };

      // Add customer profile fields
      if (_spouseName.isNotEmpty) {
        fields['spouseName'] = _spouseName;
      }
      
      if (_childrenCount.isNotEmpty) {
        fields['kidsCount'] = _childrenCount;
      }

      // Add address fields
      if (_area.isNotEmpty) {
        fields['area'] = _area;
      }
      
      if (_block.isNotEmpty) {
        fields['block'] = _block;
      }
      
      if (_street.isNotEmpty) {
        fields['street'] = _street;
      }
      
      if (_houseNumber.isNotEmpty) {
        fields['houseNumber'] = _houseNumber;
      }
      
      if (_governorate.isNotEmpty) {
        fields['governorate'] = _governorate;
      }

      // Call PUT API with multipart form data
      final response = await ApiUtils.putMultipart(
        endpoint: UrlManager.profileUpdate,
        fields: fields,
        filePath: _profileImage?.path,
        fileFieldName: 'profilePicture',
      );

      print(_profileImage?.path);
      if (response.isSuccess) {
        setSuccess(true);
        
        // Save updated data to local storage
        await storage.setString(LocalStorageManager.keyUserName, _name);
        await storage.setString(LocalStorageManager.keyUserPhone, _phoneNumber);
        
        if (_spouseName.isNotEmpty) {
          await storage.setString(LocalStorageManager.keySpouseName, _spouseName);
        }
        
        if (_childrenCount.isNotEmpty) {
          await storage.setInt(LocalStorageManager.keyKidsCount, int.tryParse(_childrenCount) ?? 0);
        }
        
      } else {
        // Translate the error message from API response
        final errorMsg = response.message.isNotEmpty 
            ? localizations.translate(response.message) 
            : localizations.translate('profile_update_failed');
        setError(errorMsg,errorKey: response.message);
      }
    } catch (e) {
      setError(
        localizations.translate('profile_update_failed'),
        errorKey: 'profile_update_failed',
      );
      print('Error updating profile: $e');
    } finally {
      setLoading(false);
    }
  }

  // Pick image from camera or gallery
  Future<void> pickImage(BuildContext context, XFile? pickedFile) async {
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setProfileImage(file, pickedFile.path);
      
      // TODO: Upload image to server
      // await uploadProfileImage(context, file);
    }
  }

  // Upload profile image
  Future<void> uploadProfileImage(BuildContext context, File imageFile) async {
    final localizations = AppLocalizations.of(context);
    
    setLoading(true);
    clearError();

    try {
      // TODO: Implement multipart file upload
      // final response = await ApiUtils.uploadFile(
      //   endpoint: '/api/profile/upload-image',
      //   file: imageFile,
      // );
      
      // if (response.isSuccess) {
      //   setSuccess(true);
      // }
      
    } catch (e) {
      setError(
        localizations.translate('profile_update_failed'),
        errorKey: 'profile_update_failed',
      );
    } finally {
      setLoading(false);
    }
  }

  // Delete profile image
  Future<bool> deleteProfileImage(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    setLoading(true);
    clearError();

    try {
      final storage = await LocalStorageManager.getInstance();
      final userId = storage.getString(LocalStorageManager.keyUserId);
      
      if (userId == null || userId.isEmpty) {
        setError(
          localizations.translate('user_id_not_found'),
          errorKey: 'user_id_not_found',
        );
        setLoading(false);
        return false;
      }

      // Replace {id} in the endpoint with actual userId
      final endpoint = UrlManager.deleteProfilePhoto.replaceAll('{id}', userId);
      
      // Call delete API
      final response = await ApiUtils.delete(endpoint: endpoint);

      if (response.isSuccess) {
        // Clear local profile image
        _profileImage = null;
        _profileImagePath = null;
        setSuccess(true);
        notifyListeners();
        return true;
      } else {
        // Translate the error message from API response
        final errorMsg = response.message.isNotEmpty
            ? localizations.translate(response.message)
            : localizations.translate('PROFILE_COULD_NOT_DELETE_PHOTO');
        setError(errorMsg, errorKey: response.message);
        return false;
      }
    } catch (e) {
      setError(
        localizations.translate('PROFILE_COULD_NOT_DELETE_PHOTO'),
        errorKey: 'PROFILE_COULD_NOT_DELETE_PHOTO',
      );
      print('Error deleting profile image: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Save session data after successful login
  Future<void> saveSessionData({
    required String userId,
    required String name,
    required String email,
    required String phone,
    String? spouseName,
    int? kidsCount,
    String? preferredLanguage,
    String? role,
  }) async {
    try {
      final storage = await LocalStorageManager.getInstance();
      await storage.saveUserData(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        spouseName: spouseName,
        kidsCount: kidsCount,
        preferredLanguage: preferredLanguage,
        role: role,
      );
    } catch (e) {
      print('Error saving session data: $e');
    }
  }

  // Reset state
  void reset() {
    _userProfile = null;
    _name = '';
    _spouseName = '';
    _childrenCount = '';
    _phoneNumber = '';
    _email = '';
    _profileImagePath = null;
    _profileImage = null;
    _area = '';
    _block = '';
    _street = '';
    _houseNumber = '';
    _governorate = '';
    _kids = [];
    _selectedTabIndex = 0;
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = '';
    _errorKey = '';
    _errorParams = {};
    notifyListeners();
  }
}

