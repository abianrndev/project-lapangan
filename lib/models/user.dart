class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone; // ← Make optional
  final String role;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone, // ← Optional parameter
    this.role = 'user',
    this.createdAt,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone, // ← Can be null
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String?, // ← Can be null
      role: map['role'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  // Create a copy with modified fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User{id:  $id, name: $name, email: $email, role: $role}';
  }
}
