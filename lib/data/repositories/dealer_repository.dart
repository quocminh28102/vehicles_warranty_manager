import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dealer.dart';

class DealerRepository {
  DealerRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('dealers');

  Stream<List<Dealer>> watchAll() {
    return _collection.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs.map(Dealer.fromSnapshot).toList(),
        );
  }

  Future<String> addDealer(String name) async {
    final data = {
      'name': name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final ref = await _collection.add(data);
    return ref.id;
  }

  Future<void> updateDealer({
    required String id,
    required String name,
  }) async {
    await _collection.doc(id).update({
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDealer(String id) async {
    await _collection.doc(id).delete();
  }

  Future<bool> hasWarrantyRequests(String dealerId) async {
    final snapshot = await _db
        .collection('warranty_requests')
        .where('dealerId', isEqualTo: dealerId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
