class ProfileModel {
  const ProfileModel({
    required this.name,
    required this.shopName,
    required this.phone,
    this.profileImagePath,
  });

  final String name;
  final String shopName;
  final String phone;
  final String? profileImagePath;

  ProfileModel copyWith({
    String? name,
    String? shopName,
    String? phone,
    String? profileImagePath,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shopName': shopName,
      'phone': phone,
      'profileImagePath': profileImagePath,
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] as String,
      shopName: json['shopName'] as String,
      phone: json['phone'] as String,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  static ProfileModel get defaultProfile => const ProfileModel(
    name: 'Ahsan Qureshi',
    shopName: 'TailorX Atelier',
    phone: '+92 300 1234567',
  );
}
