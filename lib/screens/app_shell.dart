import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/app_user.dart';
import '../data/repositories/user_repository.dart';
import '../l10n/localization_extension.dart';
import 'catalog_page.dart';
import 'dashboard_page.dart';
import 'reports_page.dart';
import 'warranties_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final userRepo = UserRepository(FirebaseFirestore.instance);

    return StreamBuilder<AppUser?>(
      stream: userRepo.watchById(user.uid),
      builder: (context, snapshot) {
        final role = snapshot.data?.role ?? UserRole.viewer;
        final isAdmin = role == UserRole.admin;

        final titles = <String>[
          l10n.dashboardTitle,
          l10n.warrantiesTitle,
          l10n.reportsTitle,
          if (isAdmin) l10n.catalogTitle,
        ];
        final destinations = <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.verified_outlined),
            selectedIcon: const Icon(Icons.verified),
            label: l10n.navWarranties,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navReports,
          ),
          if (isAdmin)
            NavigationDestination(
              icon: const Icon(Icons.category_outlined),
              selectedIcon: const Icon(Icons.category),
              label: l10n.navCatalog,
            ),
        ];
        final pages = <Widget>[
          const DashboardPage(),
          const WarrantiesPage(),
          const ReportsPage(),
          if (isAdmin) const CatalogPage(),
        ];

        final isWide = MediaQuery.of(context).size.width >= 900;
        final safeIndex = _index < pages.length ? _index : 0;
        final content = pages[safeIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(titles[safeIndex]),
            actions: [
              IconButton(
                tooltip: l10n.signOut,
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: safeIndex,
                      onDestinationSelected: _onDestinationSelected,
                      labelType: NavigationRailLabelType.all,
                      destinations: destinations
                          .map(
                            (destination) => NavigationRailDestination(
                              icon: destination.icon,
                              selectedIcon: destination.selectedIcon,
                              label: Text(destination.label),
                            ),
                          )
                          .toList(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ],
                )
              : content,
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: safeIndex,
                  onDestinationSelected: _onDestinationSelected,
                  destinations: destinations,
                ),
        );
      },
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _index = index;
    });
  }
}
