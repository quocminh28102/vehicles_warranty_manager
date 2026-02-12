import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/warranty_request.dart';

class WarrantyRequestRepository {
  WarrantyRequestRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('warranty_requests');

  Stream<List<WarrantyRequest>> watchAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(WarrantyRequest.fromSnapshot).toList());
  }

  String generateId() {
    return _collection.doc().id;
  }

  Future<String> add(WarrantyRequest request, {String? id}) async {
    final data = request.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (id == null || id.isEmpty) {
      final ref = await _collection.add(data);
      return ref.id;
    }
    await _collection.doc(id).set(data);
    return id;
  }

  Future<void> updateStatus({
    required String id,
    required WarrantyRequestStatus status,
  }) async {
    await _collection.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
