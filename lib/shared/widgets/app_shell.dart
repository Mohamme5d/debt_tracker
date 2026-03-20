import 'package:flutter/material.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/settings')) return 2;
    if (location.startsWith('/transactions')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = _selectedIndex(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.borderDark, width: 0.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/transactions');
                break;
              case 2:
                context.go('/settings');
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_rounded),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.dashboard,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_rounded),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: l10n.transactions,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_rounded),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
