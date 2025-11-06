/// Country codes data with mobile number lengths
/// Used across the app for phone number validation
class CountryCodes {
  static const List<Map<String, dynamic>> countryCodes = [
    {'code': '+973', 'country': 'BH', 'name': 'Bahrain', 'mobile_length': 8},
    {'code': '+20',  'country': 'EG', 'name': 'Egypt', 'mobile_length': 10},
    {'code': '+91',  'country': 'IN', 'name': 'India', 'mobile_length': 10},
    {'code': '+98',  'country': 'IR', 'name': 'Iran', 'mobile_length': 10},
    {'code': '+964', 'country': 'IQ', 'name': 'Iraq', 'mobile_length': 10},
    {'code': '+972', 'country': 'IL', 'name': 'Israel', 'mobile_length': 9},
    {'code': '+962', 'country': 'JO', 'name': 'Jordan', 'mobile_length': 9},
    {'code': '+965', 'country': 'KW', 'name': 'Kuwait', 'mobile_length': 8},
    {'code': '+961', 'country': 'LB', 'name': 'Lebanon', 'mobile_length': 8},
    {'code': '+968', 'country': 'OM', 'name': 'Oman', 'mobile_length': 8},
    {'code': '+970', 'country': 'PS', 'name': 'Palestine', 'mobile_length': 9},
    {'code': '+974', 'country': 'QA', 'name': 'Qatar', 'mobile_length': 8},
    {'code': '+966', 'country': 'SA', 'name': 'Saudi Arabia', 'mobile_length': 9},
    {'code': '+963', 'country': 'SY', 'name': 'Syria', 'mobile_length': 9},
    {'code': '+90',  'country': 'TR', 'name': 'Turkey', 'mobile_length': 10},
    {'code': '+971', 'country': 'AE', 'name': 'United Arab Emirates (UAE)', 'mobile_length': 9},
    {'code': '+967', 'country': 'YE', 'name': 'Yemen', 'mobile_length': 9}
  ];

  /// Get country code by country code string (e.g., 'KW')
  static Map<String, dynamic>? getCountryByCode(String countryCode) {
    try {
      return countryCodes.firstWhere(
        (c) => c['country'] == countryCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get country code by phone code (e.g., '+965')
  static Map<String, dynamic>? getCountryByPhoneCode(String phoneCode) {
    try {
      return countryCodes.firstWhere(
        (c) => c['code'] == phoneCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get expected mobile length for a country
  static int getMobileLength(String countryCode) {
    final country = getCountryByCode(countryCode);
    return country?['mobile_length'] as int? ?? 8;
  }

  /// Get country name for a country code
  static String getCountryName(String countryCode) {
    final country = getCountryByCode(countryCode);
    return country?['name'] as String? ?? 'Kuwait';
  }
}

