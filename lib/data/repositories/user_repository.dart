import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('users');

  Stream<AppUser?> watchById(String id) {
    return _collection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return AppUser.fromSnapshot(snapshot);
    });
  }

  Future<void> createIfMissing(AppUser user) async {
    final ref = _collection.doc(user.id);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return;
    }
    final data = user.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
  }

  Future<void> update(AppUser user) {
    if (user.id.isEmpty) {
      throw ArgumentError('User id is required for update.');
    }
    return _collection.doc(user.id).update(user.toMap());
  }
}
