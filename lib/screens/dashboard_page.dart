import 'package:flutter/material.dart';

import '../l10n/localization_extension.dart';
import '../widgets/empty_state.dart';
import '../widgets/quick_action_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
              onTap: () {},
            ),
            QuickActionCard(
              icon: Icons.attach_file,
              label: l10n.attachFile,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SummaryCards(
          vehiclesLabel: l10n.summaryRequests,
          expiringLabel: l10n.summaryPending,
          appointmentsLabel: l10n.summaryInProgress,
        ),
        const SizedBox(height: 24),
        EmptyState(message: l10n.comingSoon),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.vehiclesLabel,
    required this.expiringLabel,
    required this.appointmentsLabel,
  });

  final String vehiclesLabel;
  final String expiringLabel;
  final String appointmentsLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          title: '36',
          subtitle: vehiclesLabel,
          icon: Icons.directions_car,
        ),
        _SummaryCard(
          title: '5',
          subtitle: expiringLabel,
          icon: Icons.verified,
        ),
        _SummaryCard(
          title: '3',
          subtitle: appointmentsLabel,
          icon: Icons.event,
        ),
      ],
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
