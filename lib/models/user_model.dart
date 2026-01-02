class AppUser {
  final String uid;
  final String email;
  final String role; // 'farmer' or 'customer'
  final String? name;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      name: map['name'],
    );
  }
}
