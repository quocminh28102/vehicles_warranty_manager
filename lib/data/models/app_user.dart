import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_helpers.dart';

enum UserRole {
  admin,
  staff,
  viewer,
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.status,
    this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? status;
  final DateTime? createdAt;

  factory AppUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: _roleFromString(data['role'] as String?),
      status: data['status'] as String?,
      createdAt: readDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'status': status,
      'createdAt': writeDate(createdAt),
    };
  }
}

UserRole _roleFromString(String? value) {
  switch (value) {
    case 'staff':
      return UserRole.staff;
    case 'viewer':
      return UserRole.viewer;
    case 'admin':
    default:
      return UserRole.admin;
  }
}
