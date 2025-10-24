import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/apiutils.dart';
import '../../../core/network/url_manager.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/storage/local_storage_manager.dart';
import '../model/kid_model.dart';

class ProfileViewModel extends ChangeNotifier {
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
  
  // Kids list
  List<Kid> _kids = [];
  
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';
  String _errorKey = '';
  Map<String, String> _errorParams = {};

  // Getters
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

  // Kids methods
  void addKid(Kid kid) {
    _kids.add(kid);
    notifyListeners();
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
  
  // Called when language changes to refresh error messages
  void onLanguageChanged() {
    if (_errorKey.isNotEmpty) {
      notifyListeners();
    }
  }

  // Load profile data from local storage or API
  Future<void> loadProfile(BuildContext context) async {
    setLoading(true);
    clearError();

    try {
      final storage = await LocalStorageManager.getInstance();
      
      // Load from local storage first
      _name = storage.getString(LocalStorageManager.keyUserEmail) ?? '';
      _email = storage.getString(LocalStorageManager.keyUserEmail) ?? '';
      
      // TODO: Load from API
      // final response = await ApiUtils.get(
      //   endpoint: UrlManager.profile,
      // );
      
      // if (response.isSuccess && response.hasData) {
      //   final data = response.data['data'];
      //   _name = data['name'] ?? '';
      //   _spouseName = data['spouse_name'] ?? '';
      //   _childrenCount = data['children_count']?.toString() ?? '';
      //   _phoneNumber = data['phone'] ?? '';
      //   _email = data['email'] ?? '';
      //   _profileImagePath = data['profile_image'] ?? '';
      //   notifyListeners();
      // }
      
    } catch (e) {
      // Handle error silently or show message
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
      // TODO: Implement actual API call
      final response = await ApiUtils.post(
        endpoint: '/api/profile/update',
        body: {
          'name': _name,
          'spouse_name': _spouseName,
          'children_count': _childrenCount,
          'phone': _phoneNumber,
          'email': _email,
        },
      );

      if (response.isSuccess) {
        setSuccess(true);
        
        // Save to local storage
        final storage = await LocalStorageManager.getInstance();
        await storage.setString(LocalStorageManager.keyUserEmail, _email);
        
      } else {
        final errorMsg = response.message.isNotEmpty 
            ? response.message 
            : localizations.translate('profile_update_failed');
        setError(
          errorMsg,
          errorKey: response.message.isEmpty ? 'profile_update_failed' : '',
        );
      }
    } catch (e) {
      setError(
        localizations.translate('profile_update_failed'),
        errorKey: 'profile_update_failed',
      );
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

  // Reset state
  void reset() {
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

