import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/models/warranty_request.dart';
import '../data/repositories/dealer_repository.dart';
import '../data/repositories/vehicle_model_repository.dart';
import '../data/repositories/warranty_request_repository.dart';
import '../l10n/localization_extension.dart';
import '../widgets/empty_state.dart';
import '../widgets/quick_action_card.dart';
import 'warranties_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
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
        Text(
          l10n.quickActions,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            QuickActionCard(
              icon: Icons.verified,
              label: l10n.addRequest,
              onTap: () => _showRequestForm(context, repo, modelRepo, dealerRepo),
            ),
            QuickActionCard(
              icon: Icons.attach_file,
              label: l10n.attachFile,
              onTap: () => _showRequestForm(
                context,
                repo,
                modelRepo,
                dealerRepo,
                focusAttachment: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        StreamBuilder<List<WarrantyRequest>>(
          stream: repo.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final requests = snapshot.data ?? [];
            final summary = _SummaryData.fromRequests(requests);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCards(
                  summary: summary,
                  totalLabel: l10n.summaryRequests,
                  pendingLabel: l10n.summaryPending,
                  inProgressLabel: l10n.summaryInProgress,
                  approvedLabel: l10n.approved,
                  doneLabel: l10n.done,
                  rejectedLabel: l10n.rejected,
                ),
                if (requests.isEmpty) ...[
                  const SizedBox(height: 24),
                  EmptyState(message: l10n.emptyState),
                ],
              ],
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
    DealerRepository dealerRepo, {
    bool focusAttachment = false,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => RequestFormDialog(
        repository: repo,
        modelRepository: modelRepo,
        dealerRepository: dealerRepo,
        focusAttachment: focusAttachment,
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.summary,
    required this.totalLabel,
    required this.pendingLabel,
    required this.inProgressLabel,
    required this.approvedLabel,
    required this.doneLabel,
    required this.rejectedLabel,
  });

  final _SummaryData summary;
  final String totalLabel;
  final String pendingLabel;
  final String inProgressLabel;
  final String approvedLabel;
  final String doneLabel;
  final String rejectedLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          title: summary.total.toString(),
          subtitle: totalLabel,
          icon: Icons.directions_car,
        ),
        _SummaryCard(
          title: summary.pending.toString(),
          subtitle: pendingLabel,
          icon: Icons.verified,
        ),
        _SummaryCard(
          title: summary.inProgress.toString(),
          subtitle: inProgressLabel,
          icon: Icons.event,
        ),
        _SummaryCard(
          title: summary.approved.toString(),
          subtitle: approvedLabel,
          icon: Icons.check_circle_outline,
        ),
        _SummaryCard(
          title: summary.done.toString(),
          subtitle: doneLabel,
          icon: Icons.done_all,
        ),
        _SummaryCard(
          title: summary.rejected.toString(),
          subtitle: rejectedLabel,
          icon: Icons.block,
        ),
      ],
    );
  }
}

class _SummaryData {
  const _SummaryData({
    required this.total,
    required this.pending,
    required this.approved,
    required this.inProgress,
    required this.done,
    required this.rejected,
  });

  final int total;
  final int pending;
  final int approved;
  final int inProgress;
  final int done;
  final int rejected;

  factory _SummaryData.fromRequests(List<WarrantyRequest> requests) {
    var pending = 0;
    var approved = 0;
    var inProgress = 0;
    var done = 0;
    var rejected = 0;

    for (final request in requests) {
      switch (request.status) {
        case WarrantyRequestStatus.pending:
          pending++;
          break;
        case WarrantyRequestStatus.approved:
          approved++;
          break;
        case WarrantyRequestStatus.inProgress:
          inProgress++;
          break;
        case WarrantyRequestStatus.done:
          done++;
          break;
        case WarrantyRequestStatus.rejected:
          rejected++;
          break;
      }
    }

    return _SummaryData(
      total: requests.length,
      pending: pending,
      approved: approved,
      inProgress: inProgress,
      done: done,
      rejected: rejected,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
