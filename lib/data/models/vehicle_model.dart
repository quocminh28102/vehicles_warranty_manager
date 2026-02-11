import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_helpers.dart';

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.name,
    required this.vinPrefixes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final List<String> vinPrefixes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory VehicleModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return VehicleModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      vinPrefixes: (data['vinPrefixes'] as List?)
              ?.whereType<String>()
              .map((prefix) => prefix.toUpperCase())
              .toList() ??
          const [],
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'vinPrefixes': vinPrefixes,
      'createdAt': writeDate(createdAt),
      'updatedAt': writeDate(updatedAt),
    };
  }
}
