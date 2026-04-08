class LoginUserModel {
  final String id;
  final String username;
  final String role;
  final bool isActive;

  const LoginUserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isUser => role.toLowerCase() == 'user';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'is_active': isActive,
    };
  }

  factory LoginUserModel.fromMap(Map<String, dynamic> map) {
    return LoginUserModel(
      id: (map['id'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      role: (map['role'] ?? 'user').toString(),
      isActive: map.containsKey('is_active') ? map['is_active'] == true : true,
    );
  }
}
