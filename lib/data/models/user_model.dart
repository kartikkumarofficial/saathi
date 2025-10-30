class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Support both naming conventions just in case (full_name vs name, profile_image vs avatar_url)
    final nameVal = json['full_name'] ?? json['name'] ?? '';
    final avatarVal = json['profile_image'] ?? json['avatar_url'];

    return UserModel(
      id: json['id'] as String,
      name: nameVal as String,
      email: json['email'] as String,
      avatarUrl: avatarVal != null ? avatarVal as String : null,
      role: json['role'] != null ? (json['role'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'profile_image': avatarUrl,
      'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }
}
