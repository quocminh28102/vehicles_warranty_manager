import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vehicles_warranty_manager/data/repositories/dealer_repository.dart';
import 'package:vehicles_warranty_manager/data/repositories/vehicle_model_repository.dart';
import 'package:vehicles_warranty_manager/data/repositories/warranty_request_repository.dart';
import 'package:vehicles_warranty_manager/l10n/app_localizations.dart';
import 'package:vehicles_warranty_manager/screens/catalog_page.dart';
import 'package:vehicles_warranty_manager/screens/warranties_page.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

class _WarrantyHarness {
  _WarrantyHarness(this.firestore)
      : requestRepo = WarrantyRequestRepository(firestore),
        modelRepo = VehicleModelRepository(firestore),
        dealerRepo = DealerRepository(firestore);

  final FakeFirebaseFirestore firestore;
  final WarrantyRequestRepository requestRepo;
  final VehicleModelRepository modelRepo;
  final DealerRepository dealerRepo;

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      _wrapWithApp(
        WarrantiesPage(
          repository: requestRepo,
          modelRepository: modelRepo,
          dealerRepository: dealerRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openForm(WidgetTester tester) async {
    await tester.tap(find.text('New request'));
    await tester.pumpAndSettle();
  }

  Finder textField(int index) => find.byType(TextFormField).at(index);
  Finder dropdown(int index) =>
      find.byType(DropdownButtonFormField<String>).at(index);

  List<TextFormField> fields(WidgetTester tester) =>
      tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();

  Future<void> enterVin(WidgetTester tester, String vin) async {
    await tester.enterText(textField(0), vin);
    await tester.pumpAndSettle();
  }

  Future<void> enterIssue(WidgetTester tester, String issue) async {
    await tester.enterText(textField(2), issue);
    await tester.pumpAndSettle();
  }

  Future<void> selectCategory(WidgetTester tester, String label) async {
    await tester.tap(dropdown(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectDealer(WidgetTester tester, String label) async {
    await tester.tap(dropdown(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CatalogPage', () {
    testWidgets('shows empty states when no data', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final modelRepo = VehicleModelRepository(firestore);
      final dealerRepo = DealerRepository(firestore);

      await tester.pumpWidget(
        _wrapWithApp(
          CatalogPage(
            modelRepository: modelRepo,
            dealerRepository: dealerRepo,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No models yet.'), findsOneWidget);
      expect(find.text('No dealers yet.'), findsOneWidget);
    });

    testWidgets('renders model, category, and dealer', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final modelRepo = VehicleModelRepository(firestore);
      final dealerRepo = DealerRepository(firestore);

      final modelId = await modelRepo.addModel(
        name: 'Teramont',
        vinPrefixes: ['WVGZZZCA'],
      );
      await modelRepo.addCategory(
        modelId: modelId,
        name: 'Camera 360',
        warrantyMonths: 24,
      );
      await dealerRepo.addDealer('Dealer A');

      await tester.pumpWidget(
        _wrapWithApp(
          CatalogPage(
            modelRepository: modelRepo,
            dealerRepository: dealerRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Teramont'), findsOneWidget);
      expect(find.text('Dealer A'), findsOneWidget);

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.text('Camera 360'), findsOneWidget);
    });
  });

  group('WarrantiesPage', () {
    testWidgets('renders warranty request card', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final harness = _WarrantyHarness(firestore);

      await firestore.collection('warranty_requests').add({
        'vin': 'WVGZZZCA123456789',
        'modelId': 'model-1',
        'model': 'Teramont Limited',
        'upgradeDate': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'upgradeCategoryId': 'cat-1',
        'upgradeCategory': 'Camera 360',
        'warrantyMonths': 24,
        'issue': 'Test',
        'description': 'Desc',
        'status': 'pending',
        'dealerId': 'dealer-1',
        'dealerName': 'Dealer A',
        'createdAt': Timestamp.fromDate(DateTime(2024, 2, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2024, 2, 1)),
      });

      await harness.pumpPage(tester);

      expect(find.textContaining('Teramont Limited'), findsOneWidget);
      expect(find.textContaining('WVGZZZCA123456789'), findsOneWidget);
      expect(find.textContaining('Camera 360'), findsOneWidget);
      expect(find.textContaining('Dealer A'), findsOneWidget);
    });

    testWidgets('shows validation errors for missing selections', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final harness = _WarrantyHarness(firestore);

      final modelId = await harness.modelRepo.addModel(
        name: 'Teramont',
        vinPrefixes: ['WVGZZZCA'],
      );
      await harness.modelRepo.addCategory(
        modelId: modelId,
        name: 'Camera 360',
        warrantyMonths: 24,
      );
      await harness.dealerRepo.addDealer('Dealer A');

      await harness.pumpPage(tester);
      await harness.openForm(tester);
      await harness.enterVin(tester, 'WVGZZZCA123456789');
      await harness.enterIssue(tester, 'Noise');
      await harness.save(tester);

      expect(find.text('Select an upgrade item'), findsOneWidget);
      expect(find.text('Select a dealer'), findsOneWidget);

      final snapshot =
          await firestore.collection('warranty_requests').get();
      expect(snapshot.docs, isEmpty);
    });

    testWidgets('shows error when VIN does not match model', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final harness = _WarrantyHarness(firestore);

      await harness.modelRepo.addModel(
        name: 'Teramont',
        vinPrefixes: ['WVGZZZCA'],
      );

      await harness.pumpPage(tester);
      await harness.openForm(tester);
      await harness.enterVin(tester, 'INVALIDVIN');
      await harness.save(tester);

      expect(find.text('Model not found for this VIN'), findsOneWidget);

      final snapshot =
          await firestore.collection('warranty_requests').get();
      expect(snapshot.docs, isEmpty);
    });

    testWidgets('shows error when issue is missing', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final harness = _WarrantyHarness(firestore);

      final modelId = await harness.modelRepo.addModel(
        name: 'Teramont',
        vinPrefixes: ['WVGZZZCA'],
      );
      await harness.modelRepo.addCategory(
        modelId: modelId,
        name: 'Camera 360',
        warrantyMonths: 24,
      );
      await harness.dealerRepo.addDealer('Dealer A');

      await harness.pumpPage(tester);
      await harness.openForm(tester);
      await harness.enterVin(tester, 'WVGZZZCA123456789');
      await harness.selectCategory(tester, 'Camera 360 (24 months)');
      await harness.selectDealer(tester, 'Dealer A');
      await harness.save(tester);

      expect(find.text('Issue'), findsAtLeastNWidgets(2));

      final snapshot =
          await firestore.collection('warranty_requests').get();
      expect(snapshot.docs, isEmpty);
    });

    testWidgets('auto-detects model from longest VIN prefix', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final harness = _WarrantyHarness(firestore);

      await harness.modelRepo.addModel(
        name: 'Model Short',
        vinPrefixes: ['WVG'],
      );
      await harness.modelRepo.addModel(
        name: 'Model Long',
        vinPrefixes: ['WVGZZZCA'],
      );

      await harness.pumpPage(tester);
      await harness.openForm(tester);
      await harness.enterVin(tester, 'WVGZZZCA123456789');

      final fields = harness.fields(tester);
      expect(fields.length >= 2, isTrue);
      expect(fields[1].controller?.text, 'Model Long');
    });

    testWidgets('shows warranty remaining text', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final harness = _WarrantyHarness(firestore);

      final now = DateTime.now();
      final upgradeDate = DateTime(now.year, now.month, now.day);
      final endDate = _addMonthsForTest(upgradeDate, 1);
      final remaining = endDate.difference(DateTime.now()).inDays;
      final expected = remaining == 0
          ? 'Expires today'
          : remaining > 0
              ? '$remaining days left'
              : 'Expired ${remaining.abs()} days';

      await firestore.collection('warranty_requests').add({
        'vin': 'WVGZZZCA123456789',
        'modelId': 'model-1',
        'model': 'Teramont Limited',
        'upgradeDate': Timestamp.fromDate(upgradeDate),
        'upgradeCategoryId': 'cat-1',
        'upgradeCategory': 'Camera 360',
        'warrantyMonths': 1,
        'issue': 'Test',
        'description': 'Desc',
        'status': 'pending',
        'dealerId': 'dealer-1',
        'dealerName': 'Dealer A',
        'createdAt': Timestamp.fromDate(DateTime(2024, 2, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2024, 2, 1)),
      });

      await harness.pumpPage(tester);

      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('creates request from form inputs', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final harness = _WarrantyHarness(firestore);

      final modelId = await harness.modelRepo.addModel(
        name: 'Teramont',
        vinPrefixes: ['WVGZZZCA'],
      );
      final categoryId = await harness.modelRepo.addCategory(
        modelId: modelId,
        name: 'Camera 360',
        warrantyMonths: 24,
      );
      final dealerId = await harness.dealerRepo.addDealer('Dealer A');

      await harness.pumpPage(tester);
      await harness.openForm(tester);
      await harness.enterVin(tester, 'WVGZZZCA123456789');

      final fields = harness.fields(tester);
      expect(fields.length >= 2, isTrue);
      expect(fields[1].controller?.text, 'Teramont');

      await harness.selectCategory(tester, 'Camera 360 (24 months)');
      await harness.selectDealer(tester, 'Dealer A');
      await harness.enterIssue(tester, 'Noise');
      await harness.save(tester);

      final snapshot =
          await firestore.collection('warranty_requests').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['vin'], 'WVGZZZCA123456789');
      expect(data['modelId'], modelId);
      expect(data['upgradeCategoryId'], categoryId);
      expect(data['dealerId'], dealerId);
    });
  });
}

DateTime _addMonthsForTest(DateTime date, int months) {
  final totalMonths = date.month - 1 + months;
  final year = date.year + (totalMonths ~/ 12);
  final month = totalMonths % 12 + 1;
  final lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : date.day;
  return DateTime(year, month, day);
}
