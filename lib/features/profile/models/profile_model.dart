class ProfileModel {
  const ProfileModel({
    required this.name,
    required this.shopName,
    required this.phone,
    required this.email,
    required this.uid,
    this.profileImagePath,
    this.imageUrl,
  });

  final String name;
  final String shopName;
  final String phone;
  final String email;
  final String uid;
  final String? profileImagePath; // Deprecated: kept for backward compatibility
  final String? imageUrl; // Firebase Storage download URL (primary)

  ProfileModel copyWith({
    String? name,
    String? shopName,
    String? phone,
    String? email,
    String? uid,
    String? profileImagePath,
    String? imageUrl,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      imageUrl: imageUrl ?? this.imageUrl,
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
      'imageUrl': imageUrl,
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
      imageUrl: json['imageUrl'] as String?,
    );
  }

  static ProfileModel defaultProfile(String email, String uid) =>
      ProfileModel(name: '', shopName: '', phone: '', email: email, uid: uid);
}
