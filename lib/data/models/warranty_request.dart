import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_helpers.dart';

enum WarrantyRequestStatus {
  pending,
  approved,
  rejected,
  inProgress,
  done,
}

enum WarrantyAttachmentType {
  image,
  video,
  file,
  link,
}

class WarrantyAttachment {
  const WarrantyAttachment({
    required this.url,
    required this.name,
    required this.type,
  });

  final String url;
  final String name;
  final WarrantyAttachmentType type;

  factory WarrantyAttachment.fromMap(Map<String, dynamic> data) {
    return WarrantyAttachment(
      url: data['url'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: _attachmentTypeFromString(data['type'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'name': name,
      'type': type.name,
    };
  }
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
    this.attachments = const [],
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
  final List<WarrantyAttachment> attachments;
  final String? requestedById;
  final String? requestedByEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory WarrantyRequest.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final warrantyValue = data['warrantyMonths'];
    final attachments = _attachmentsFromData(data);
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
      attachments: attachments,
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
      'attachments': attachments.map((attachment) => attachment.toMap()).toList(),
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

List<WarrantyAttachment> _attachmentsFromData(Map<String, dynamic> data) {
  final attachmentsRaw = data['attachments'];
  if (attachmentsRaw is List) {
    return attachmentsRaw
        .whereType<Map>()
        .map((item) => WarrantyAttachment.fromMap(
              item.cast<String, dynamic>(),
            ))
        .toList();
  }

  final links = data['attachmentLinks'] as List?;
  if (links == null) {
    return const [];
  }
  return links.whereType<String>().map(_attachmentFromLegacyLink).toList();
}

WarrantyAttachment _attachmentFromLegacyLink(String url) {
  final name = Uri.tryParse(url)?.pathSegments.last;
  final type = _attachmentTypeFromUrl(url);
  return WarrantyAttachment(
    url: url,
    name: name?.isNotEmpty == true ? name! : url,
    type: type,
  );
}

WarrantyAttachmentType _attachmentTypeFromUrl(String url) {
  final lower = url.toLowerCase();
  if (_isImageExtension(lower)) {
    return WarrantyAttachmentType.image;
  }
  if (_isVideoExtension(lower)) {
    return WarrantyAttachmentType.video;
  }
  return WarrantyAttachmentType.link;
}

WarrantyAttachmentType _attachmentTypeFromString(String? value) {
  switch (value) {
    case 'image':
      return WarrantyAttachmentType.image;
    case 'video':
      return WarrantyAttachmentType.video;
    case 'file':
      return WarrantyAttachmentType.file;
    case 'link':
      return WarrantyAttachmentType.link;
    default:
      return WarrantyAttachmentType.file;
  }
}

bool _isImageExtension(String value) {
  return value.endsWith('.png') ||
      value.endsWith('.jpg') ||
      value.endsWith('.jpeg') ||
      value.endsWith('.webp') ||
      value.endsWith('.gif') ||
      value.endsWith('.bmp') ||
      value.endsWith('.heic') ||
      value.endsWith('.heif');
}

bool _isVideoExtension(String value) {
  return value.endsWith('.mp4') ||
      value.endsWith('.mov') ||
      value.endsWith('.m4v') ||
      value.endsWith('.avi') ||
      value.endsWith('.mkv') ||
      value.endsWith('.webm');
}
