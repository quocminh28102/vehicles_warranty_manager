import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/dealer.dart';
import '../data/models/upgrade_category.dart';
import '../data/models/vehicle_model.dart';
import '../data/repositories/dealer_repository.dart';
import '../data/repositories/vehicle_model_repository.dart';
import '../l10n/localization_extension.dart';
import '../widgets/empty_state.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({
    super.key,
    this.modelRepository,
    this.dealerRepository,
  });

  final VehicleModelRepository? modelRepository;
  final DealerRepository? dealerRepository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo =
        modelRepository ?? VehicleModelRepository(FirebaseFirestore.instance);
    final dealerRepo =
        dealerRepository ?? DealerRepository(FirebaseFirestore.instance);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.catalogTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showAddModelDialog(context, repo),
              icon: const Icon(Icons.add),
              label: Text(l10n.addModel),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<VehicleModel>>(
          stream: repo.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final models = snapshot.data ?? [];
            if (models.isEmpty) {
              return EmptyState(message: l10n.noModels);
            }
            return Column(
              children: models
                  .map(
                    (model) => _ModelCard(
                      model: model,
                      repository: repo,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.dealersTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showAddDealerDialog(context, dealerRepo),
              icon: const Icon(Icons.add),
              label: Text(l10n.addDealer),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Dealer>>(
          stream: dealerRepo.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final dealers = snapshot.data ?? [];
            if (dealers.isEmpty) {
              return EmptyState(message: l10n.noDealers);
            }
            return Card(
              child: Column(
                children: dealers
                    .map(
                      (dealer) => ListTile(
                        title: Text(dealer.name),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: l10n.editDealer,
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDealerDialog(
                                context,
                                dealerRepo,
                                dealer,
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.deleteDealer,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDeleteDealer(
                                context,
                                dealerRepo,
                                dealer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.model,
    required this.repository,
  });

  final VehicleModel model;
  final VehicleModelRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prefixText = model.vinPrefixes.isEmpty
        ? l10n.vinPrefixesEmpty
        : '${l10n.vinPrefixes}: ${model.vinPrefixes.join(', ')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(model.name)),
            IconButton(
              tooltip: l10n.editModel,
              icon: const Icon(Icons.edit),
              visualDensity: VisualDensity.compact,
              onPressed: () => _showEditModelDialog(
                context,
                repository,
                model,
              ),
            ),
            IconButton(
              tooltip: l10n.deleteModel,
              icon: const Icon(Icons.delete_outline),
              visualDensity: VisualDensity.compact,
              onPressed: () => _confirmDeleteModel(
                context,
                repository,
                model,
              ),
            ),
          ],
        ),
        subtitle: Text(prefixText),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.upgradeCategory,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddCategoryDialog(
                  context,
                  repository,
                  model,
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.addCategory),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<UpgradeCategory>>(
            stream: repository.watchCategories(model.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return Text(l10n.noCategories);
              }
              return Column(
                children: categories
                    .map(
                      (category) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(category.name),
                        subtitle: Text(
                          '${l10n.warrantyMonths}: ${category.warrantyMonths}',
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: l10n.editCategory,
                              icon: const Icon(Icons.edit),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _showEditCategoryDialog(
                                context,
                                repository,
                                model,
                                category,
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.deleteCategory,
                              icon: const Icon(Icons.delete_outline),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _confirmDeleteCategory(
                                context,
                                repository,
                                model,
                                category,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _showAddModelDialog(
  BuildContext context,
  VehicleModelRepository repository,
) async {
  final l10n = context.l10n;

  await showDialog<void>(
    context: context,
    builder: (_) => _ModelFormDialog(
      title: l10n.addModel,
      initialName: '',
      initialPrefixes: const [],
      onSave: (name, prefixes) => repository.addModel(
        name: name,
        vinPrefixes: prefixes,
      ),
    ),
  );
}

Future<void> _showEditModelDialog(
  BuildContext context,
  VehicleModelRepository repository,
  VehicleModel model,
) async {
  final l10n = context.l10n;

  await showDialog<void>(
    context: context,
    builder: (_) => _ModelFormDialog(
      title: l10n.editModel,
      initialName: model.name,
      initialPrefixes: model.vinPrefixes,
      onSave: (name, prefixes) => repository.updateModel(
        id: model.id,
        name: name,
        vinPrefixes: prefixes,
      ),
    ),
  );
}

Future<void> _confirmDeleteModel(
  BuildContext context,
  VehicleModelRepository repository,
  VehicleModel model,
) async {
  final l10n = context.l10n;
  final inUse = await repository.hasWarrantyRequestsForModel(model.id);
  if (!context.mounted) {
    return;
  }
  if (inUse) {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteModel),
        content: Text(l10n.modelInUse),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    return;
  }

  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteModel),
      content: Text(l10n.deleteModelConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.deleteModel),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    await repository.deleteModel(model.id);
  }
}

Future<void> _showAddCategoryDialog(
  BuildContext context,
  VehicleModelRepository repository,
  VehicleModel model,
) async {
  final l10n = context.l10n;

  await showDialog<void>(
    context: context,
    builder: (_) => _CategoryFormDialog(
      title: l10n.addCategory,
      initialName: '',
      initialWarrantyMonths: '',
      onSave: (name, months) => repository.addCategory(
        modelId: model.id,
        name: name,
        warrantyMonths: months,
      ),
    ),
  );
}

Future<void> _showEditCategoryDialog(
  BuildContext context,
  VehicleModelRepository repository,
  VehicleModel model,
  UpgradeCategory category,
) async {
  final l10n = context.l10n;

  await showDialog<void>(
    context: context,
    builder: (_) => _CategoryFormDialog(
      title: l10n.editCategory,
      initialName: category.name,
      initialWarrantyMonths: category.warrantyMonths.toString(),
      onSave: (name, months) => repository.updateCategory(
        modelId: model.id,
        categoryId: category.id,
        name: name,
        warrantyMonths: months,
      ),
    ),
  );
}

Future<void> _confirmDeleteCategory(
  BuildContext context,
  VehicleModelRepository repository,
  VehicleModel model,
  UpgradeCategory category,
) async {
  final l10n = context.l10n;
  final inUse = await repository.hasWarrantyRequestsForCategory(category.id);
  if (!context.mounted) {
    return;
  }
  if (inUse) {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.categoryInUse),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    return;
  }

  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteCategory),
      content: Text(l10n.deleteCategoryConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.deleteCategory),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    await repository.deleteCategory(
      modelId: model.id,
      categoryId: category.id,
    );
  }
}

Future<void> _showAddDealerDialog(
  BuildContext context,
  DealerRepository repository,
) async {
  final l10n = context.l10n;

  await showDialog<void>(
    context: context,
    builder: (_) => _DealerFormDialog(
      title: l10n.addDealer,
      initialName: '',
      onSave: (name) => repository.addDealer(name),
    ),
  );
}

Future<void> _showEditDealerDialog(
  BuildContext context,
  DealerRepository repository,
  Dealer dealer,
) async {
  final l10n = context.l10n;

  await showDialog<void>(
    context: context,
    builder: (_) => _DealerFormDialog(
      title: l10n.editDealer,
      initialName: dealer.name,
      onSave: (name) => repository.updateDealer(
        id: dealer.id,
        name: name,
      ),
    ),
  );
}

class _DealerFormDialog extends StatefulWidget {
  const _DealerFormDialog({
    required this.title,
    required this.initialName,
    required this.onSave,
  });

  final String title;
  final String initialName;
  final Future<void> Function(String name) onSave;

  @override
  State<_DealerFormDialog> createState() => _DealerFormDialogState();
}

class _ModelFormDialog extends StatefulWidget {
  const _ModelFormDialog({
    required this.title,
    required this.initialName,
    required this.initialPrefixes,
    required this.onSave,
  });

  final String title;
  final String initialName;
  final List<String> initialPrefixes;
  final Future<void> Function(String name, List<String> prefixes) onSave;

  @override
  State<_ModelFormDialog> createState() => _ModelFormDialogState();
}

class _ModelFormDialogState extends State<_ModelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _prefixController;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _prefixController =
        TextEditingController(text: widget.initialPrefixes.join('\n'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.model),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l10n.model : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prefixController,
                decoration: InputDecoration(
                  labelText: l10n.vinPrefixes,
                  helperText: l10n.vinPrefixesHint,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    try {
      final prefixes = _prefixController.text
          .split(RegExp(r'[\n,]'))
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      await widget.onSave(_nameController.text.trim(), prefixes);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({
    required this.title,
    required this.initialName,
    required this.initialWarrantyMonths,
    required this.onSave,
  });

  final String title;
  final String initialName;
  final String initialWarrantyMonths;
  final Future<void> Function(String name, int months) onSave;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _warrantyController;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _warrantyController =
        TextEditingController(text: widget.initialWarrantyMonths);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _warrantyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.upgradeCategory),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.upgradeCategory
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _warrantyController,
                decoration: InputDecoration(labelText: l10n.warrantyMonths),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.warrantyMonths;
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return l10n.warrantyMonths;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onSave(
        _nameController.text.trim(),
        int.parse(_warrantyController.text),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class _DealerFormDialogState extends State<_DealerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(labelText: l10n.dealer),
            validator: (value) =>
                value == null || value.trim().isEmpty ? l10n.dealer : null,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onSave(_controller.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

Future<void> _confirmDeleteDealer(
  BuildContext context,
  DealerRepository repository,
  Dealer dealer,
) async {
  final l10n = context.l10n;
  final inUse = await repository.hasWarrantyRequests(dealer.id);
  if (!context.mounted) {
    return;
  }
  if (inUse) {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteDealer),
        content: Text(l10n.dealerInUse),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    return;
  }

  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteDealer),
      content: Text(l10n.deleteDealerConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.deleteDealer),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    await repository.deleteDealer(dealer.id);
  }
}
