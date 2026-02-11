import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_helpers.dart';

enum WarrantyRequestStatus {
  pending,
  approved,
  rejected,
  inProgress,
  done,
}

class WarrantyRequest {
  const WarrantyRequest({
    required this.id,
    required this.vin,
    required this.modelId,
    required this.model,
    required this.upgradeDate,
    required this.upgradeCategoryId,
    required this.upgradeCategory,
    required this.warrantyMonths,
    required this.issue,
    required this.description,
    required this.status,
    required this.dealerId,
    required this.dealerName,
    this.attachmentLinks,
    this.requestedById,
    this.requestedByEmail,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String vin;
  final String modelId;
  final String model;
  final DateTime upgradeDate;
  final String upgradeCategoryId;
  final String upgradeCategory;
  final int? warrantyMonths;
  final String issue;
  final String description;
  final WarrantyRequestStatus status;
  final String dealerId;
  final String dealerName;
  final List<String>? attachmentLinks;
  final String? requestedById;
  final String? requestedByEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory WarrantyRequest.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final warrantyValue = data['warrantyMonths'];
    return WarrantyRequest(
      id: doc.id,
      vin: data['vin'] as String? ?? '',
      modelId: data['modelId'] as String? ?? '',
      model: data['model'] as String? ?? '',
      upgradeDate: readDate(data['upgradeDate']) ?? DateTime.now(),
      upgradeCategoryId: data['upgradeCategoryId'] as String? ?? '',
      upgradeCategory: data['upgradeCategory'] as String? ?? '',
      warrantyMonths: warrantyValue is num ? warrantyValue.toInt() : null,
      issue: data['issue'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      dealerId: data['dealerId'] as String? ?? '',
      dealerName: data['dealerName'] as String? ?? '',
      attachmentLinks: (data['attachmentLinks'] as List?)
          ?.whereType<String>()
          .toList(),
      requestedById: data['requestedById'] as String?,
      requestedByEmail: data['requestedByEmail'] as String?,
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vin': vin,
      'modelId': modelId,
      'model': model,
      'upgradeDate': writeDate(upgradeDate),
      'upgradeCategoryId': upgradeCategoryId,
      'upgradeCategory': upgradeCategory,
      'warrantyMonths': warrantyMonths,
      'issue': issue,
      'description': description,
      'status': status.name,
      'dealerId': dealerId,
      'dealerName': dealerName,
      'attachmentLinks': attachmentLinks,
      'requestedById': requestedById,
      'requestedByEmail': requestedByEmail,
      'createdAt': writeDate(createdAt),
      'updatedAt': writeDate(updatedAt),
    };
  }
}

WarrantyRequestStatus _statusFromString(String? value) {
  switch (value) {
    case 'approved':
      return WarrantyRequestStatus.approved;
    case 'rejected':
      return WarrantyRequestStatus.rejected;
    case 'inProgress':
      return WarrantyRequestStatus.inProgress;
    case 'done':
      return WarrantyRequestStatus.done;
    case 'pending':
    default:
      return WarrantyRequestStatus.pending;
  }
}
