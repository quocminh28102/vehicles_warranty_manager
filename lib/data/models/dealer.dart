import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_helpers.dart';

class Dealer {
  const Dealer({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Dealer.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Dealer(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': writeDate(createdAt),
      'updatedAt': writeDate(updatedAt),
    };
  }
}
