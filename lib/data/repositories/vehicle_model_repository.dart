import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/upgrade_category.dart';
import '../models/vehicle_model.dart';

class VehicleModelRepository {
  VehicleModelRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('vehicle_models');

  Stream<List<VehicleModel>> watchAll() {
    return _collection.orderBy('name').snapshots().map(
          (snapshot) =>
              snapshot.docs.map(VehicleModel.fromSnapshot).toList(),
        );
  }

  Future<String> addModel({
    required String name,
    required List<String> vinPrefixes,
  }) async {
    final normalized = vinPrefixes
        .map((prefix) => prefix.trim().toUpperCase())
        .where((prefix) => prefix.isNotEmpty)
        .toList();
    final data = {
      'name': name.trim(),
      'vinPrefixes': normalized,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final ref = await _collection.add(data);
    return ref.id;
  }

  Future<void> updateModel({
    required String id,
    required String name,
    required List<String> vinPrefixes,
  }) async {
    final normalized = vinPrefixes
        .map((prefix) => prefix.trim().toUpperCase())
        .where((prefix) => prefix.isNotEmpty)
        .toList();
    await _collection.doc(id).update({
      'name': name.trim(),
      'vinPrefixes': normalized,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteModel(String id) async {
    final docRef = _collection.doc(id);
    final categoriesSnapshot = await docRef.collection('upgrade_categories').get();
    final batch = _db.batch();
    for (final doc in categoriesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(docRef);
    await batch.commit();
  }

  Future<bool> hasWarrantyRequestsForModel(String modelId) async {
    final snapshot = await _db
        .collection('warranty_requests')
        .where('modelId', isEqualTo: modelId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Stream<List<UpgradeCategory>> watchCategories(String modelId) {
    return _collection
        .doc(modelId)
        .collection('upgrade_categories')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(UpgradeCategory.fromSnapshot).toList(),
        );
  }

  Future<String> addCategory({
    required String modelId,
    required String name,
    required int warrantyMonths,
  }) async {
    final data = {
      'name': name.trim(),
      'warrantyMonths': warrantyMonths,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final ref = await _collection
        .doc(modelId)
        .collection('upgrade_categories')
        .add(data);
    return ref.id;
  }

  Future<void> updateCategory({
    required String modelId,
    required String categoryId,
    required String name,
    required int warrantyMonths,
  }) async {
    await _collection
        .doc(modelId)
        .collection('upgrade_categories')
        .doc(categoryId)
        .update({
      'name': name.trim(),
      'warrantyMonths': warrantyMonths,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory({
    required String modelId,
    required String categoryId,
  }) async {
    await _collection
        .doc(modelId)
        .collection('upgrade_categories')
        .doc(categoryId)
        .delete();
  }

  Future<bool> hasWarrantyRequestsForCategory(String categoryId) async {
    final snapshot = await _db
        .collection('warranty_requests')
        .where('upgradeCategoryId', isEqualTo: categoryId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
