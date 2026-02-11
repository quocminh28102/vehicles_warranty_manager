import 'package:flutter/material.dart';

import '../l10n/localization_extension.dart';
import '../widgets/empty_state.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.comingSoon,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        EmptyState(message: l10n.emptyState),
      ],
    );
  }
}
