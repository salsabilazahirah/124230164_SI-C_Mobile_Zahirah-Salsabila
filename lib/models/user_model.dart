class User {
  final int? id;
  final String username;
  final String email;
  final String passwordHash;
  final String? fullName;
  final String? phone;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.fullName,
    this.phone,
    this.profilePicture,
    DateTime? createdAt,
    this.lastLogin,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'full_name': fullName,
      'phone': phone,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      passwordHash: map['password_hash'],
      fullName: map['full_name'],
      phone: map['phone'],
      profilePicture: map['profile_picture'],
      createdAt: DateTime.parse(map['created_at']),
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'])
          : null,
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    String? fullName,
    String? phone,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
