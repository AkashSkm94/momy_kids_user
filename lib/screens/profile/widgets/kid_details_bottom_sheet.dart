import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:momy_kids/core/components/image_widgets.dart';
import '../../../core/constants/color_palette.dart';
import '../../../core/constants/images_utils.dart';
import '../../../core/localization/appLocalization.dart';
import '../../../core/components/primary-button.dart';
import '../model/kid_model.dart';

class KidDetailsBottomSheet {
  static Future<Kid?> show(
    BuildContext context, {
    Kid? existingKid,
  }) async {
    return await showModalBottomSheet<Kid?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _KidDetailsContent(existingKid: existingKid);
      },
    );
  }
}

class _KidDetailsContent extends StatefulWidget {
  final Kid? existingKid;

  const _KidDetailsContent({this.existingKid});

  @override
  State<_KidDetailsContent> createState() => _KidDetailsContentState();
}

class _KidDetailsContentState extends State<_KidDetailsContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedGender; // Optional - can be null
  DateTime? _selectedDate;
  String _originalName = '';
  String? _originalGender;
  DateTime? _originalDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingKid != null) {
      _nameController.text = widget.existingKid!.name;
      _selectedGender = widget.existingKid!.gender.isNotEmpty 
          ? widget.existingKid!.gender 
          : null;
      _selectedDate = widget.existingKid!.dateOfBirth;
      _originalName = _nameController.text.trim();
      _originalGender = _selectedGender;
      _originalDate = _selectedDate;
    }

    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top indicator bar
                BaseImage(
                  source: ImageSource.asset,
                  assetPath: ImageUtilsPath.bottomSheetTop,
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  localizations.translate('kids_details'),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette.textPrimary,
                  ),
                ),

                const SizedBox(height: 24),

                // Name Field
                _buildTextField(
                  controller: _nameController,
                  image: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icUser,iconColors: ColorPalette.primary,),
                  labelText: localizations.translate('kid_name'),
                  hintText: localizations.translate('enter_kid_name'),
                ),

                const SizedBox(height: 16),

                // Gender Field
                _buildGenderField(localizations),

                const SizedBox(height: 16),

                // DOB Field
                _buildDOBField(localizations),

                const SizedBox(height: 24),

                // Add/Update Button
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: widget.existingKid == null
                        ? localizations.translate('add_child')
                        : localizations.translate('update_child'),
                    enabled: widget.existingKid == null || _hasChanges(),
                    onClick: widget.existingKid == null || _hasChanges()
                        ? _handleSaveKid
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasChanges() {
    final currentName = _nameController.text.trim();
    final currentGender = _selectedGender;
    final currentDate = _selectedDate;

    final normalizedCurrentDate = currentDate != null
        ? DateTime(currentDate.year, currentDate.month, currentDate.day)
        : null;
    final normalizedOriginalDate = _originalDate != null
        ? DateTime(_originalDate!.year, _originalDate!.month, _originalDate!.day)
        : null;

    return currentName != _originalName ||
        currentGender != _originalGender ||
        normalizedCurrentDate != normalizedOriginalDate;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required Widget image,
    required String labelText,
    required String hintText,
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
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: ColorPalette.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: image,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            color: ColorPalette.textSecondary,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            color: ColorPalette.textSecondary.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context).translate('kid_name_required');
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderField(AppLocalizations localizations) {
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
      child: InkWell(
        onTap: () => _showGenderPicker(localizations),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: localizations.translate('gender_label'),
            prefixIcon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icGender,iconColors: ColorPalette.primary,),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          child: Text(
            _selectedGender != null
                ? localizations.translate(_selectedGender!.toLowerCase())
                : localizations.translate('select_gender'),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: _selectedGender != null
                  ? ColorPalette.textPrimary
                  : ColorPalette.textSecondary.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDOBField(AppLocalizations localizations) {
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
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: localizations.translate('dob'),
            prefixIcon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icKids,iconColors: ColorPalette.primary,),
            suffixIcon: BaseImage(source: ImageSource.assetIcons,assetPath: ImageUtilsPath.icCalender,iconColors: ColorPalette.primary,),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          child: Text(
            _selectedDate != null
                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                : localizations.translate('select_dob'),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color: _selectedDate != null
                  ? ColorPalette.textPrimary
                  : ColorPalette.textSecondary.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  void _showGenderPicker(AppLocalizations localizations) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 230,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                localizations.translate('select_gender'),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                title: Text(localizations.translate('male')),
                onTap: () {
                  setState(() => _selectedGender = 'Male');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(localizations.translate('female')),
                onTap: () {
                  setState(() => _selectedGender = 'Female');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  localizations.translate('cancel'),
                  style: TextStyle(color: ColorPalette.textSecondary),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorPalette.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSaveKid() {
    // Only validate name field - other fields are optional
    if (_formKey.currentState!.validate()) {
      final kid = Kid(
        id: widget.existingKid?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        gender: _selectedGender ?? '', // Optional - use empty string if not selected
        dateOfBirth: _selectedDate, // Optional - can be null
      );

      Navigator.pop(context, kid);
    }
  }
}







