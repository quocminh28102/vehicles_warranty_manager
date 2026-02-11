import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/app_user.dart';
import '../data/repositories/user_repository.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<UserCredential> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('User registration failed.');
    }
    await _ensureUserRecord(
      user,
      displayName: displayName,
      emailOverride: email,
      preferAdminIfFirst: true,
    );
    return credential;
  }

  Future<void> ensureUserRecord(User user) async {
    await _ensureUserRecord(user, preferAdminIfFirst: false);
  }

  Future<void> _ensureUserRecord(
    User user, {
    String? displayName,
    String? emailOverride,
    required bool preferAdminIfFirst,
  }) async {
    final repository = UserRepository(_firestore);
    final email = emailOverride ?? user.email ?? '';
    final name = displayName ?? user.displayName ?? _defaultName(email);
    UserRole role = UserRole.viewer;

    if (preferAdminIfFirst) {
      final snapshot = await _firestore.collection('users').limit(1).get();
      role = snapshot.docs.isEmpty ? UserRole.admin : UserRole.viewer;
    }

    await repository.createIfMissing(
      AppUser(
        id: user.uid,
        email: email,
        displayName: name,
        role: role,
        status: 'active',
        createdAt: DateTime.now(),
      ),
    );
  }

  String _defaultName(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) {
      return 'User';
    }
    return email.substring(0, atIndex);
  }
}
