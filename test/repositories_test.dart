import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vehicles_warranty_manager/data/repositories/dealer_repository.dart';
import 'package:vehicles_warranty_manager/data/repositories/vehicle_model_repository.dart';

void main() {
  group('DealerRepository', () {
    test('add/update/delete and in-use checks', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = DealerRepository(firestore);

      final dealerId = await repo.addDealer('Dealer A');
      var snapshot = await firestore.collection('dealers').doc(dealerId).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['name'], 'Dealer A');

      expect(await repo.hasWarrantyRequests(dealerId), isFalse);

      await firestore.collection('warranty_requests').add({
        'dealerId': dealerId,
        'modelId': 'model-1',
        'upgradeCategoryId': 'cat-1',
        'createdAt': DateTime.now(),
      });
      expect(await repo.hasWarrantyRequests(dealerId), isTrue);

      await repo.updateDealer(id: dealerId, name: 'Dealer B');
      snapshot = await firestore.collection('dealers').doc(dealerId).get();
      expect(snapshot.data()?['name'], 'Dealer B');

      await repo.deleteDealer(dealerId);
      snapshot = await firestore.collection('dealers').doc(dealerId).get();
      expect(snapshot.exists, isFalse);
    });
  });

  group('VehicleModelRepository', () {
    test('model + category lifecycle and usage checks', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = VehicleModelRepository(firestore);

      final modelId = await repo.addModel(
        name: 'Teramont',
        vinPrefixes: [' wvgzzzca ', '', 'LSVSH'],
      );
      var modelSnapshot =
          await firestore.collection('vehicle_models').doc(modelId).get();
      expect(modelSnapshot.exists, isTrue);
      expect(modelSnapshot.data()?['name'], 'Teramont');
      expect(modelSnapshot.data()?['vinPrefixes'], ['WVGZZZCA', 'LSVSH']);

      final categoryId = await repo.addCategory(
        modelId: modelId,
        name: 'Camera 360',
        warrantyMonths: 24,
      );
      var categorySnapshot = await firestore
          .collection('vehicle_models')
          .doc(modelId)
          .collection('upgrade_categories')
          .doc(categoryId)
          .get();
      expect(categorySnapshot.exists, isTrue);
      expect(categorySnapshot.data()?['warrantyMonths'], 24);

      await repo.updateCategory(
        modelId: modelId,
        categoryId: categoryId,
        name: 'Camera 360 Pro',
        warrantyMonths: 36,
      );
      categorySnapshot = await firestore
          .collection('vehicle_models')
          .doc(modelId)
          .collection('upgrade_categories')
          .doc(categoryId)
          .get();
      expect(categorySnapshot.data()?['name'], 'Camera 360 Pro');
      expect(categorySnapshot.data()?['warrantyMonths'], 36);

      expect(await repo.hasWarrantyRequestsForModel(modelId), isFalse);
      expect(await repo.hasWarrantyRequestsForCategory(categoryId), isFalse);

      await firestore.collection('warranty_requests').add({
        'modelId': modelId,
        'upgradeCategoryId': categoryId,
        'dealerId': 'dealer-1',
        'createdAt': DateTime.now(),
      });
      expect(await repo.hasWarrantyRequestsForModel(modelId), isTrue);
      expect(await repo.hasWarrantyRequestsForCategory(categoryId), isTrue);

      await repo.deleteCategory(modelId: modelId, categoryId: categoryId);
      categorySnapshot = await firestore
          .collection('vehicle_models')
          .doc(modelId)
          .collection('upgrade_categories')
          .doc(categoryId)
          .get();
      expect(categorySnapshot.exists, isFalse);

      await repo.deleteModel(modelId);
      modelSnapshot =
          await firestore.collection('vehicle_models').doc(modelId).get();
      expect(modelSnapshot.exists, isFalse);
      final remainingCategories = await firestore
          .collection('vehicle_models')
          .doc(modelId)
          .collection('upgrade_categories')
          .get();
      expect(remainingCategories.docs, isEmpty);
    });
  });
}
