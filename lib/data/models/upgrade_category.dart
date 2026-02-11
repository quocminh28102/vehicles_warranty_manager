import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_helpers.dart';

class UpgradeCategory {
  const UpgradeCategory({
    required this.id,
    required this.name,
    required this.warrantyMonths,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final int warrantyMonths;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UpgradeCategory.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final warrantyValue = data['warrantyMonths'];
    return UpgradeCategory(
      id: doc.id,
      name: data['name'] as String? ?? '',
      warrantyMonths: warrantyValue is num ? warrantyValue.toInt() : 0,
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'warrantyMonths': warrantyMonths,
      'createdAt': writeDate(createdAt),
      'updatedAt': writeDate(updatedAt),
    };
  }
}
