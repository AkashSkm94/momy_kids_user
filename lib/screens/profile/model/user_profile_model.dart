import 'kid_model.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePicture;
  final String role;
  final bool isActive;
  final bool isVerified;
  final String? status;
  final CustomerProfile? customerProfile;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    required this.role,
    required this.isActive,
    required this.isVerified,
    this.status,
    this.customerProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePicture: json['profilePicture'],
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      status: json['status'],
      customerProfile: json['customerProfile'] != null
          ? CustomerProfile.fromJson(json['customerProfile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'role': role,
      'isActive': isActive,
      'isVerified': isVerified,
      'status': status,
      'customerProfile': customerProfile?.toJson(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? role,
    bool? isActive,
    bool? isVerified,
    String? status,
    CustomerProfile? customerProfile,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      customerProfile: customerProfile ?? this.customerProfile,
    );
  }
}

class CustomerProfile {
  final String? spouseName;
  final int? kidsCount;
  final String? area;
  final String? block;
  final String? street;
  final String? houseNumber;
  final String? governorate;
  final List<Kid> children;

  CustomerProfile({
    this.spouseName,
    this.kidsCount,
    this.area,
    this.block,
    this.street,
    this.houseNumber,
    this.governorate,
    this.children = const [],
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      spouseName: json['spouseName'],
      kidsCount: json['kidsCount'],
      area: json['area'],
      block: json['block'],
      street: json['street'],
      houseNumber: json['houseNumber'],
      governorate: json['governorate'],
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => Kid.fromJson(child))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spouseName': spouseName,
      'kidsCount': kidsCount,
      'area': area,
      'block': block,
      'street': street,
      'houseNumber': houseNumber,
      'governorate': governorate,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  CustomerProfile copyWith({
    String? spouseName,
    int? kidsCount,
    String? area,
    String? block,
    String? street,
    String? houseNumber,
    String? governorate,
    List<Kid>? children,
  }) {
    return CustomerProfile(
      spouseName: spouseName ?? this.spouseName,
      kidsCount: kidsCount ?? this.kidsCount,
      area: area ?? this.area,
      block: block ?? this.block,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      governorate: governorate ?? this.governorate,
      children: children ?? this.children,
    );
  }
}




