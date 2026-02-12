import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehicles_warranty_manager/l10n/app_localizations.dart';

import '../config/google_drive_config.dart';
import '../data/models/app_user.dart';
import '../data/models/dealer.dart';
import '../data/models/upgrade_category.dart';
import '../data/models/vehicle_model.dart';
import '../data/models/warranty_request.dart';
import '../data/repositories/dealer_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/vehicle_model_repository.dart';
import '../data/repositories/warranty_request_repository.dart';
import '../l10n/localization_extension.dart';
import '../utils/date_format.dart';
import '../widgets/empty_state.dart';

Future<void>? _googleSignInInit;

Future<void> _ensureGoogleSignInInitialized() {
  return _googleSignInInit ??= GoogleSignIn.instance.initialize(
    clientId: kIsWeb ? googleDriveWebClientId : null,
  );
}

class WarrantiesPage extends StatelessWidget {
  const WarrantiesPage({
    super.key,
    this.repository,
    this.modelRepository,
    this.dealerRepository,
  });

  final WarrantyRequestRepository? repository;
  final VehicleModelRepository? modelRepository;
  final DealerRepository? dealerRepository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo =
        repository ?? WarrantyRequestRepository(FirebaseFirestore.instance);
    final modelRepo =
        modelRepository ?? VehicleModelRepository(FirebaseFirestore.instance);
    final dealerRepo =
        dealerRepository ?? DealerRepository(FirebaseFirestore.instance);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FilledButton.icon(
          onPressed: () => _showRequestForm(
            context,
            repo,
            modelRepo,
            dealerRepo,
          ),
          icon: const Icon(Icons.verified),
          label: Text(l10n.addRequest),
        ),
        const SizedBox(height: 24),
        StreamBuilder<List<WarrantyRequest>>(
          stream: repo.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final requests = snapshot.data ?? [];
            if (requests.isEmpty) {
              return EmptyState(message: l10n.emptyState);
            }
            return Column(
              children: requests
                  .map((request) => _RequestCard(request: request))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showRequestForm(
    BuildContext context,
    WarrantyRequestRepository repo,
    VehicleModelRepository modelRepo,
    DealerRepository dealerRepo,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => RequestFormDialog(
        repository: repo,
        modelRepository: modelRepo,
        dealerRepository: dealerRepo,
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final WarrantyRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final warrantyText = _buildWarrantyText(l10n, request);
    final dealerText =
        request.dealerName.isNotEmpty ? ' • ${l10n.dealer}: ${request.dealerName}' : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.verified,
          color: _statusColor(context, request.status),
        ),
        title: Text('${request.model} • ${request.vin}'),
        subtitle: Text(
          '${l10n.upgradeCategory}: ${request.upgradeCategory}'
          ' • ${l10n.upgradeDate}: ${formatDate(request.upgradeDate)}'
          '$dealerText',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_statusLabel(l10n, request.status)),
            const SizedBox(height: 4),
            Text(
              warrantyText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: () => _showDetails(context, request),
      ),
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    WarrantyRequest request,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _RequestDetailsSheet(request: request),
    );
  }
}

class _RequestDetailsSheet extends StatelessWidget {
  const _RequestDetailsSheet({required this.request});

  final WarrantyRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = WarrantyRequestRepository(FirebaseFirestore.instance);
    final user = FirebaseAuth.instance.currentUser;
    final userRepo = UserRepository(FirebaseFirestore.instance);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.requestWarranty,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _InfoRow(label: l10n.vin, value: request.vin),
          _InfoRow(label: l10n.model, value: request.model),
          if (request.dealerName.isNotEmpty)
            _InfoRow(label: l10n.dealer, value: request.dealerName),
          _InfoRow(label: l10n.upgradeCategory, value: request.upgradeCategory),
          _InfoRow(
            label: l10n.upgradeDate,
            value: formatDate(request.upgradeDate),
          ),
          _InfoRow(label: l10n.issue, value: request.issue),
          _InfoRow(label: l10n.description, value: request.description),
          if (request.attachments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.attachments,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _AttachmentsSection(attachments: request.attachments),
          ],
          if ((request.requestedByEmail ?? '').isNotEmpty)
            _InfoRow(
              label: l10n.requester,
              value: request.requestedByEmail ?? '',
            ),
          const SizedBox(height: 16),
          if (user == null)
            Text(l10n.viewOnly)
          else
            StreamBuilder<AppUser?>(
              stream: userRepo.watchById(user.uid),
              builder: (context, snapshot) {
                final role = snapshot.data?.role ?? UserRole.viewer;
                final canUpdate =
                    role == UserRole.admin || role == UserRole.staff;
                if (!canUpdate) {
                  return Text(l10n.viewOnly);
                }
                return Wrap(
                  spacing: 8,
                  children: [
                    _StatusButton(
                      label: l10n.pending,
                      onPressed: () => _updateStatus(
                        context,
                        repo,
                        WarrantyRequestStatus.pending,
                      ),
                    ),
                    _StatusButton(
                      label: l10n.approved,
                      onPressed: () => _updateStatus(
                        context,
                        repo,
                        WarrantyRequestStatus.approved,
                      ),
                    ),
                    _StatusButton(
                      label: l10n.inProgress,
                      onPressed: () => _updateStatus(
                        context,
                        repo,
                        WarrantyRequestStatus.inProgress,
                      ),
                    ),
                    _StatusButton(
                      label: l10n.done,
                      onPressed: () => _updateStatus(
                        context,
                        repo,
                        WarrantyRequestStatus.done,
                      ),
                    ),
                    _StatusButton(
                      label: l10n.rejected,
                      onPressed: () => _updateStatus(
                        context,
                        repo,
                        WarrantyRequestStatus.rejected,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WarrantyRequestRepository repo,
    WarrantyRequestStatus status,
  ) async {
    await repo.updateStatus(id: request.id, status: status);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _AttachmentsSection extends StatelessWidget {
  const _AttachmentsSection({required this.attachments});

  final List<WarrantyAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final images = attachments
        .where((attachment) => attachment.type == WarrantyAttachmentType.image)
        .toList();
    final videos = attachments
        .where((attachment) => attachment.type == WarrantyAttachmentType.video)
        .toList();
    final others = attachments
        .where(
          (attachment) =>
              attachment.type == WarrantyAttachmentType.file ||
              attachment.type == WarrantyAttachmentType.link,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images
                .map((attachment) => _AttachmentThumbnail(attachment: attachment))
                .toList(),
          ),
        if (videos.isNotEmpty) ...[
          if (images.isNotEmpty) const SizedBox(height: 12),
          Column(
            children: videos
                .map(
                  (attachment) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.play_circle_outline),
                    title: Text(
                      attachment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      attachment.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openAttachmentUrl(context, attachment.url),
                  ),
                )
                .toList(),
          ),
        ],
        if (others.isNotEmpty) ...[
          if (images.isNotEmpty || videos.isNotEmpty)
            const SizedBox(height: 12),
          Column(
            children: others
                .map(
                  (attachment) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      attachment.type == WarrantyAttachmentType.link
                          ? Icons.link
                          : Icons.insert_drive_file_outlined,
                    ),
                    title: Text(
                      attachment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      attachment.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openAttachmentUrl(context, attachment.url),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _AttachmentThumbnail extends StatelessWidget {
  const _AttachmentThumbnail({required this.attachment});

  final WarrantyAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imagePreviewUrl(attachment);
    return InkWell(
      onTap: () => _showImagePreview(context, attachment),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 96,
          height: 96,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.broken_image_outlined),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child;
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

class RequestFormDialog extends StatefulWidget {
  const RequestFormDialog({
    super.key,
    required this.repository,
    required this.modelRepository,
    required this.dealerRepository,
    this.focusAttachment = false,
  });

  final WarrantyRequestRepository repository;
  final VehicleModelRepository modelRepository;
  final DealerRepository dealerRepository;
  final bool focusAttachment;

  @override
  State<RequestFormDialog> createState() => _RequestFormDialogState();
}

class _RequestFormDialogState extends State<RequestFormDialog> {
  static const int _maxAttachmentSizeBytes = 50 * 1024 * 1024;
  static const List<String> _allowedExtensions = [
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
    'bmp',
    'heic',
    'heif',
    'mp4',
    'mov',
    'm4v',
    'avi',
    'mkv',
    'webm',
  ];

  final _formKey = GlobalKey<FormState>();
  final _vinController = TextEditingController();
  final _modelController = TextEditingController();
  final _issueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _attachmentLinksController = TextEditingController();
  final List<_LocalAttachment> _pendingAttachments = [];
  final FocusNode _attachmentFocus = FocusNode();
  DateTime _upgradeDate = DateTime.now();
  bool _busy = false;
  String? _selectedModelId;
  String? _selectedCategoryId;
  String? _selectedDealerId;
  List<VehicleModel> _modelsCache = const [];
  List<UpgradeCategory> _categoriesCache = const [];
  List<Dealer> _dealersCache = const [];

  @override
  void initState() {
    super.initState();
    _ensureGoogleSignInInitialized();
    if (widget.focusAttachment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_attachmentFocus);
        }
      });
    }
  }

  @override
  void dispose() {
    _vinController.dispose();
    _modelController.dispose();
    _issueController.dispose();
    _descriptionController.dispose();
    _attachmentLinksController.dispose();
    _attachmentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.requestWarranty),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: StreamBuilder<List<VehicleModel>>(
          stream: widget.modelRepository.watchAll(),
          builder: (context, modelSnapshot) {
            final models = modelSnapshot.data ?? [];
            _modelsCache = models;

            if (_vinController.text.isNotEmpty &&
                _selectedModelId == null &&
                models.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _handleVinChanged(_vinController.text);
                }
              });
            }

            final selectedModel = _findModelById(_selectedModelId);
            final modelName = selectedModel?.name ?? '';
            if (_modelController.text != modelName) {
              _modelController.text = modelName;
            }

            return StreamBuilder<List<Dealer>>(
              stream: widget.dealerRepository.watchAll(),
              builder: (context, dealerSnapshot) {
                final dealers = dealerSnapshot.data ?? [];
                _dealersCache = dealers;
                final categoryStream = _selectedModelId == null
                    ? Stream<List<UpgradeCategory>>.empty()
                    : widget.modelRepository
                        .watchCategories(_selectedModelId!);

                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (models.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              l10n.noModels,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        TextFormField(
                          controller: _vinController,
                          decoration: InputDecoration(labelText: l10n.vin),
                          textCapitalization: TextCapitalization.characters,
                          onChanged: _handleVinChanged,
                          validator: (value) => value == null || value.trim().isEmpty
                              ? l10n.vin
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _modelController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: l10n.model,
                            helperText: l10n.modelAutoDetected,
                          ),
                          validator: (_) =>
                              _selectedModelId == null ? l10n.modelNotFound : null,
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<List<UpgradeCategory>>(
                          stream: categoryStream,
                          builder: (context, categorySnapshot) {
                            final categories = categorySnapshot.data ?? [];
                            _categoriesCache = categories;
                            final categoryValue = categories.any(
                              (category) => category.id == _selectedCategoryId,
                            )
                                ? _selectedCategoryId
                                : null;

                            return DropdownButtonFormField<String>(
                              initialValue: categoryValue,
                              items: categories
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category.id,
                                      child: Text(
                                        '${category.name} (${category.warrantyMonths} ${l10n.months})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _selectedModelId == null
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedCategoryId = value;
                                      });
                                    },
                              decoration: InputDecoration(
                                labelText: l10n.upgradeCategory,
                                helperText: _selectedModelId == null
                                    ? l10n.selectModelForCategory
                                    : categories.isEmpty
                                        ? l10n.noCategories
                                        : l10n.upgradeCategoryHint,
                              ),
                              validator: (_) => _selectedCategoryId == null
                                  ? l10n.selectCategory
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.upgradeDate),
                          subtitle: Text(formatDate(_upgradeDate)),
                          trailing: TextButton(
                            onPressed: _pickUpgradeDate,
                            child: Text(l10n.change),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: dealers.any(
                            (dealer) => dealer.id == _selectedDealerId,
                          )
                              ? _selectedDealerId
                              : null,
                          items: dealers
                              .map(
                                (dealer) => DropdownMenuItem(
                                  value: dealer.id,
                                  child: Text(dealer.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDealerId = value;
                            });
                          },
                          decoration: InputDecoration(labelText: l10n.dealer),
                          validator: (_) => _selectedDealerId == null
                              ? l10n.selectDealer
                              : null,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _busy ? null : _addDealer,
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addDealer),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _issueController,
                          decoration: InputDecoration(labelText: l10n.issue),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? l10n.issue
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: l10n.description),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.attachments,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _busy
                                  ? null
                                  : () => _pickAttachments(
                                        _AttachmentDestination.firebaseStorage,
                                      ),
                              icon: const Icon(Icons.upload),
                              label: Text(l10n.addAttachments),
                            ),
                            OutlinedButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () => _pickAttachments(
                                        _AttachmentDestination.googleDrive,
                                      ),
                              icon: const Icon(Icons.cloud_upload_outlined),
                              label: Text(l10n.addAttachmentsDrive),
                            ),
                            if (_pendingAttachments.isNotEmpty)
                              Text(
                                l10n.attachmentsSelected(
                                  _pendingAttachments.length,
                                ),
                              ),
                          ],
                        ),
                        if (_pendingAttachments.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Column(
                            children: _pendingAttachments
                                .map(
                                  (attachment) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading:
                                        Icon(_iconForAttachmentType(attachment.type)),
                                    title: Text(
                                      attachment.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${_formatBytes(attachment.size)} • '
                                      '${attachment.destination == _AttachmentDestination.googleDrive ? l10n.googleDrive : l10n.firebaseStorage}',
                                    ),
                                    trailing: IconButton(
                                      tooltip: l10n.removeAttachment,
                                      icon: const Icon(Icons.close),
                                      onPressed: _busy
                                          ? null
                                          : () => _removeAttachment(attachment),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _attachmentLinksController,
                          decoration: InputDecoration(labelText: l10n.attachmentLinks),
                          maxLines: 2,
                          focusNode: _attachmentFocus,
                          autofocus: widget.focusAttachment,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  void _handleVinChanged(String value) {
    final model = _detectModel(value);
    final modelId = model?.id;
    if (modelId != _selectedModelId) {
      setState(() {
        _selectedModelId = modelId;
        _selectedCategoryId = null;
      });
    }
    final modelName = model?.name ?? '';
    if (_modelController.text != modelName) {
      _modelController.text = modelName;
    }
  }

  VehicleModel? _detectModel(String vin) {
    final normalized = vin.trim().toUpperCase();
    if (normalized.isEmpty) {
      return null;
    }
    VehicleModel? match;
    var bestLength = -1;
    for (final model in _modelsCache) {
      for (final prefix in model.vinPrefixes) {
        final normalizedPrefix = prefix.trim().toUpperCase();
        if (normalizedPrefix.isEmpty) {
          continue;
        }
        if (normalized.startsWith(normalizedPrefix) &&
            normalizedPrefix.length > bestLength) {
          match = model;
          bestLength = normalizedPrefix.length;
        }
      }
    }
    return match;
  }

  VehicleModel? _findModelById(String? id) {
    if (id == null) {
      return null;
    }
    for (final model in _modelsCache) {
      if (model.id == id) {
        return model;
      }
    }
    return null;
  }

  UpgradeCategory? _findCategoryById(String? id) {
    if (id == null) {
      return null;
    }
    for (final category in _categoriesCache) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  Dealer? _findDealerById(String? id) {
    if (id == null) {
      return null;
    }
    for (final dealer in _dealersCache) {
      if (dealer.id == id) {
        return dealer;
      }
    }
    return null;
  }

  Future<void> _addDealer() async {
    final newDealerId = await _showAddDealerDialog();
    if (newDealerId != null && mounted) {
      setState(() {
        _selectedDealerId = newDealerId;
      });
    }
  }

  Future<String?> _showAddDealerDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool busy = false;
    final l10n = context.l10n;

    final dealerId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.addDealer),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(labelText: l10n.dealer),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.dealer
                        : null,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          setState(() => busy = true);
                          try {
                            final id = await widget.dealerRepository
                                .addDealer(controller.text.trim());
                            if (context.mounted) {
                              Navigator.of(dialogContext).pop(id);
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() => busy = false);
                            }
                          }
                        },
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return dealerId;
  }

  Future<void> _pickUpgradeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _upgradeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && mounted) {
      setState(() {
        _upgradeDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    final user = _currentUserOrNull();
    final selectedModel = _findModelById(_selectedModelId);
    final selectedCategory = _findCategoryById(_selectedCategoryId);
    final selectedDealer = _findDealerById(_selectedDealerId);
    if (selectedModel == null ||
        selectedCategory == null ||
        selectedDealer == null) {
      if (mounted) {
        setState(() => _busy = false);
      }
      return;
    }
    final requestId = widget.repository.generateId();
    final attachments = _linkAttachmentsFromText(
      _attachmentLinksController.text,
    );
    final firebasePending = _pendingAttachments
        .where(
          (attachment) =>
              attachment.destination == _AttachmentDestination.firebaseStorage,
        )
        .toList();
    final drivePending = _pendingAttachments
        .where(
          (attachment) =>
              attachment.destination == _AttachmentDestination.googleDrive,
        )
        .toList();
    if (drivePending.isNotEmpty) {
      try {
        final uploadedDrive = await _uploadAttachmentsToDrive(drivePending);
        attachments.addAll(uploadedDrive);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
          setState(() => _busy = false);
        }
        return;
      }
    }
    if (firebasePending.isNotEmpty) {
      try {
        final uploadedFirebase =
            await _uploadAttachmentsToFirebase(requestId, firebasePending);
        attachments.addAll(uploadedFirebase);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
          setState(() => _busy = false);
        }
        return;
      }
    }
    final request = WarrantyRequest(
      id: requestId,
      vin: _vinController.text.trim().toUpperCase(),
      modelId: selectedModel.id,
      model: selectedModel.name,
      upgradeDate: _upgradeDate,
      upgradeCategoryId: selectedCategory.id,
      upgradeCategory: selectedCategory.name,
      warrantyMonths: selectedCategory.warrantyMonths,
      issue: _issueController.text.trim(),
      description: _descriptionController.text.trim(),
      status: WarrantyRequestStatus.pending,
      dealerId: selectedDealer.id,
      dealerName: selectedDealer.name,
      attachments: attachments,
      requestedById: user?.uid,
      requestedByEmail: user?.email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    try {
      await widget.repository.add(request, id: requestId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _pickAttachments(_AttachmentDestination destination) async {
    final l10n = context.l10n;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        withData: true,
        allowedExtensions: _allowedExtensions,
      );
      if (result == null) {
        return;
      }
      final maxSizeMb = (_maxAttachmentSizeBytes / (1024 * 1024)).round();
      final newAttachments = <_LocalAttachment>[];
      for (final file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) {
          _showSnack(l10n.attachmentLoadFailed);
          continue;
        }
        if (file.size > _maxAttachmentSizeBytes) {
          _showSnack(l10n.attachmentTooLarge(maxSizeMb));
          continue;
        }
        newAttachments.add(
          _LocalAttachment(
            name: file.name,
            bytes: bytes,
            size: file.size,
            type: _attachmentTypeForName(file.name),
            destination: destination,
          ),
        );
      }
      if (newAttachments.isEmpty) {
        return;
      }
      setState(() {
        _pendingAttachments.addAll(newAttachments);
      });
    } catch (_) {
      _showSnack(l10n.attachmentLoadFailed);
    }
  }

  void _removeAttachment(_LocalAttachment attachment) {
    setState(() {
      _pendingAttachments.remove(attachment);
    });
  }

  List<WarrantyAttachment> _linkAttachmentsFromText(String raw) {
    final links = raw
        .split(RegExp(r'[\n,]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return links
        .map(
          (link) => WarrantyAttachment(
            url: link,
            name: Uri.tryParse(link)?.pathSegments.last ?? link,
            type: _attachmentTypeFromUrl(link),
          ),
        )
        .toList();
  }

  Future<List<WarrantyAttachment>> _uploadAttachmentsToFirebase(
    String requestId,
    List<_LocalAttachment> attachments,
  ) async {
    if (attachments.isEmpty) {
      return const [];
    }
    final storage = FirebaseStorage.instance;
    final uploaded = <WarrantyAttachment>[];
    for (final attachment in attachments) {
      final safeName = attachment.name.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      final objectPath =
        'warranty_requests/$requestId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      final ref = storage.ref().child(objectPath);
      final metadata = SettableMetadata(
        contentType: _contentTypeForAttachment(attachment),
      );
      await ref.putData(attachment.bytes, metadata);
      final url = await ref.getDownloadURL();
      uploaded.add(
        WarrantyAttachment(
          url: url,
          name: attachment.name,
          type: attachment.type,
        ),
      );
    }
    return uploaded;
  }

  Future<List<WarrantyAttachment>> _uploadAttachmentsToDrive(
    List<_LocalAttachment> attachments,
  ) async {
    if (attachments.isEmpty) {
      return const [];
    }
    final l10n = context.l10n;
    final accessToken = kIsWeb
        ? await _authorizeDriveAccessWeb()
        : await _authorizeDriveAccessMobile();
    final client = _GoogleAuthClient(accessToken);
    final api = drive.DriveApi(client);
    final uploaded = <WarrantyAttachment>[];
    try {
      for (final attachment in attachments) {
        final driveFile = drive.File()..name = attachment.name;
        final media = drive.Media(
          Stream<Uint8List>.value(attachment.bytes),
          attachment.size,
          contentType:
              _contentTypeForAttachment(attachment) ?? 'application/octet-stream',
        );
        final created = await api.files.create(
          driveFile,
          uploadMedia: media,
          $fields: 'id, webViewLink',
        );
        final id = created.id;
        if (id == null || id.isEmpty) {
          throw StateError(l10n.googleDriveUploadFailed);
        }
        try {
          await api.permissions.create(
            drive.Permission(type: 'anyone', role: 'reader'),
            id,
          );
        } catch (_) {
          _showSnack(l10n.googleDriveShareFailed);
        }
        final url =
            created.webViewLink ?? 'https://drive.google.com/file/d/$id/view';
        uploaded.add(
          WarrantyAttachment(
            url: url,
            name: attachment.name,
            type: attachment.type,
          ),
        );
      }
    } on Exception {
      throw StateError(l10n.googleDriveUploadFailed);
    } finally {
      client.close();
    }
    return uploaded;
  }

  Future<GoogleSignInAccount?> _ensureGoogleSignIn() async {
    final l10n = context.l10n;
    if (kIsWeb) {
      return null;
    }
    if (kIsWeb && googleDriveWebClientId.isEmpty) {
      _showSnack(l10n.googleDriveMissingClientId);
      return null;
    }
    await _ensureGoogleSignInInitialized();
    try {
      GoogleSignInAccount? account;
      final attempt =
          GoogleSignIn.instance.attemptLightweightAuthentication();
      if (attempt != null) {
        account = await attempt;
      }
      account ??= await GoogleSignIn.instance.authenticate(
        scopeHint: const [drive.DriveApi.driveFileScope],
      );
      return account;
    } on GoogleSignInException {
      return null;
    }
  }

  Future<String> _authorizeDriveAccessMobile() async {
    final l10n = context.l10n;
    final account = await _ensureGoogleSignIn();
    if (account == null) {
      throw StateError(l10n.googleDriveSignInFailed);
    }
    final client = account.authorizationClient;
    final scopes = const [drive.DriveApi.driveFileScope];
    final existing = await client.authorizationForScopes(scopes);
    final authz = existing ?? await client.authorizeScopes(scopes);
    return authz.accessToken;
  }

  Future<String> _authorizeDriveAccessWeb() async {
    final l10n = context.l10n;
    await _ensureGoogleSignInInitialized();
    final tokenData = await GoogleSignInPlatform.instance
        .clientAuthorizationTokensForScopes(
      ClientAuthorizationTokensForScopesParameters(
        request: AuthorizationRequestDetails(
          scopes: const [drive.DriveApi.driveFileScope],
          userId: null,
          email: null,
          promptIfUnauthorized: true,
        ),
      ),
    );
    final accessToken = tokenData?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError(l10n.googleDriveSignInFailed);
    }
    return accessToken;
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatBytes(int size) {
    if (size >= 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (size >= 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }
    return '$size B';
  }

  IconData _iconForAttachmentType(WarrantyAttachmentType type) {
    switch (type) {
      case WarrantyAttachmentType.image:
        return Icons.photo;
      case WarrantyAttachmentType.video:
        return Icons.play_circle_outline;
      case WarrantyAttachmentType.link:
        return Icons.link;
      case WarrantyAttachmentType.file:
        return Icons.insert_drive_file_outlined;
    }
  }

  String? _contentTypeForAttachment(_LocalAttachment attachment) {
    final lower = attachment.name.toLowerCase();
    if (_isImageExtension(lower)) {
      if (lower.endsWith('.png')) {
        return 'image/png';
      }
      if (lower.endsWith('.gif')) {
        return 'image/gif';
      }
      if (lower.endsWith('.webp')) {
        return 'image/webp';
      }
      return 'image/jpeg';
    }
    if (_isVideoExtension(lower)) {
      if (lower.endsWith('.mov')) {
        return 'video/quicktime';
      }
      return 'video/mp4';
    }
    return null;
  }

  User? _currentUserOrNull() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }
}

String _statusLabel(AppLocalizations l10n, WarrantyRequestStatus status) {
  switch (status) {
    case WarrantyRequestStatus.approved:
      return l10n.approved;
    case WarrantyRequestStatus.rejected:
      return l10n.rejected;
    case WarrantyRequestStatus.inProgress:
      return l10n.inProgress;
    case WarrantyRequestStatus.done:
      return l10n.done;
    case WarrantyRequestStatus.pending:
      return l10n.pending;
  }
}

Color _statusColor(BuildContext context, WarrantyRequestStatus status) {
  switch (status) {
    case WarrantyRequestStatus.approved:
      return Colors.teal;
    case WarrantyRequestStatus.rejected:
      return Theme.of(context).colorScheme.error;
    case WarrantyRequestStatus.inProgress:
      return Colors.orange;
    case WarrantyRequestStatus.done:
      return Colors.blueGrey;
    case WarrantyRequestStatus.pending:
      return Theme.of(context).colorScheme.primary;
  }
}

String _buildWarrantyText(AppLocalizations l10n, WarrantyRequest request) {
  final months = request.warrantyMonths;
  if (months == null || months <= 0) {
    return request.upgradeCategory;
  }
  final endDate = _addMonths(request.upgradeDate, months);
  final remaining = endDate.difference(DateTime.now()).inDays;
  if (remaining == 0) {
    return l10n.daysLeftZero;
  }
  if (remaining > 0) {
    return l10n.daysLeft(remaining);
  }
  return l10n.daysExpired(remaining.abs());
}

DateTime _addMonths(DateTime date, int months) {
  final totalMonths = date.month - 1 + months;
  final year = date.year + (totalMonths ~/ 12);
  final month = totalMonths % 12 + 1;
  final lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : date.day;
  return DateTime(year, month, day);
}

Future<void> _openAttachmentUrl(BuildContext context, String url) async {
  final l10n = context.l10n;
  final uri = Uri.tryParse(url);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.attachmentOpenFailed)),
    );
    return;
  }
  final launched =
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.attachmentOpenFailed)),
    );
  }
}

Future<void> _showImagePreview(
  BuildContext context,
  WarrantyAttachment attachment,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: InteractiveViewer(
        child: Image.network(
          _imagePreviewUrl(attachment),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => SizedBox(
            height: 240,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }
            return const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    ),
  );
}

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._accessToken);

  final String _accessToken;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class _LocalAttachment {
  const _LocalAttachment({
    required this.name,
    required this.bytes,
    required this.size,
    required this.type,
    required this.destination,
  });

  final String name;
  final Uint8List bytes;
  final int size;
  final WarrantyAttachmentType type;
  final _AttachmentDestination destination;
}

enum _AttachmentDestination {
  firebaseStorage,
  googleDrive,
}

WarrantyAttachmentType _attachmentTypeForName(String name) {
  final lower = name.toLowerCase();
  if (_isImageExtension(lower)) {
    return WarrantyAttachmentType.image;
  }
  if (_isVideoExtension(lower)) {
    return WarrantyAttachmentType.video;
  }
  return WarrantyAttachmentType.file;
}

String _imagePreviewUrl(WarrantyAttachment attachment) {
  if (attachment.type != WarrantyAttachmentType.image) {
    return attachment.url;
  }
  final driveId = _driveFileIdFromUrl(attachment.url);
  if (driveId == null) {
    return attachment.url;
  }
  return 'https://drive.google.com/uc?export=view&id=$driveId';
}

String? _driveFileIdFromUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return null;
  }
  if (uri.host.contains('drive.google.com')) {
    final segments = uri.pathSegments;
    final fileIndex = segments.indexOf('d');
    if (fileIndex != -1 && segments.length > fileIndex + 1) {
      return segments[fileIndex + 1];
    }
    final fileId = uri.queryParameters['id'];
    if (fileId != null && fileId.isNotEmpty) {
      return fileId;
    }
  }
  return null;
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








