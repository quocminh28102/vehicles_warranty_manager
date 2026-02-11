import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_warranty_manager/l10n/app_localizations.dart';

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
      builder: (_) => _RequestFormDialog(
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
          if (request.attachmentLinks?.isNotEmpty ?? false)
            _InfoRow(
              label: l10n.attachmentLinks,
              value: request.attachmentLinks!.join(', '),
            ),
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

class _RequestFormDialog extends StatefulWidget {
  const _RequestFormDialog({
    required this.repository,
    required this.modelRepository,
    required this.dealerRepository,
  });

  final WarrantyRequestRepository repository;
  final VehicleModelRepository modelRepository;
  final DealerRepository dealerRepository;

  @override
  State<_RequestFormDialog> createState() => _RequestFormDialogState();
}

class _RequestFormDialogState extends State<_RequestFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vinController = TextEditingController();
  final _modelController = TextEditingController();
  final _issueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _attachmentLinksController = TextEditingController();
  DateTime _upgradeDate = DateTime.now();
  bool _busy = false;
  String? _selectedModelId;
  String? _selectedCategoryId;
  String? _selectedDealerId;
  List<VehicleModel> _modelsCache = const [];
  List<UpgradeCategory> _categoriesCache = const [];
  List<Dealer> _dealersCache = const [];

  @override
  void dispose() {
    _vinController.dispose();
    _modelController.dispose();
    _issueController.dispose();
    _descriptionController.dispose();
    _attachmentLinksController.dispose();
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
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _attachmentLinksController,
                          decoration: InputDecoration(labelText: l10n.attachmentLinks),
                          maxLines: 2,
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
    final links = _attachmentLinksController.text
        .split(RegExp(r'[\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final request = WarrantyRequest(
      id: '',
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
      attachmentLinks: links.isEmpty ? null : links,
      requestedById: user?.uid,
      requestedByEmail: user?.email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    try {
      await widget.repository.add(request);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
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


