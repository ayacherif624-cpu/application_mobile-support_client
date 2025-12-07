class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // client, support, admin

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  // Convertir Firestore DocumentSnapshot en UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'client',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
