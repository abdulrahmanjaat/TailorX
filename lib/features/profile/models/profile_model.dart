class ProfileModel {
  const ProfileModel({
    required this.name,
    required this.shopName,
    required this.phone,
    required this.email,
    required this.uid,
    this.profileImagePath,
  });

  final String name;
  final String shopName;
  final String phone;
  final String email;
  final String uid;
  final String? profileImagePath;

  ProfileModel copyWith({
    String? name,
    String? shopName,
    String? phone,
    String? email,
    String? uid,
    String? profileImagePath,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shopName': shopName,
      'phone': phone,
      'email': email,
      'uid': uid,
      'profileImagePath': profileImagePath,
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] as String,
      shopName: json['shopName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      uid: json['uid'] as String,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  static ProfileModel defaultProfile(String email, String uid) =>
      ProfileModel(name: '', shopName: '', phone: '', email: email, uid: uid);
}
