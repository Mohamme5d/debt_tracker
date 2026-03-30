import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/renter_provider.dart';
import '../../providers/rent_payment_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/monthly_deposit_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rent_contract_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/backup/backup_service.dart';
import '../../services/security_service.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final lockEnabled = await SecurityService().isLockEnabled();
      if (lockEnabled && mounted) {
        context.go('/lock');
      }
    }
  }

  int _currentIndex() {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/apartments')) return 1;
    if (loc.startsWith('/renters'))    return 2;
    if (loc.startsWith('/contracts'))  return 3;
    if (loc.startsWith('/payments'))   return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final idx = _currentIndex();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _AppDrawer(scaffoldKey: _scaffoldKey),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface2,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) {
            if (i == 5) {
              _scaffoldKey.currentState!.openDrawer();
              return;
            }
            switch (i) {
              case 0: context.go('/dashboard');
              case 1: context.go('/apartments');
              case 2: context.go('/renters');
              case 3: context.go('/contracts');
              case 4: context.go('/payments');
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard_rounded),
              label: l.dashboard,
            ),
            NavigationDestination(
              icon: const Icon(Icons.apartment_outlined),
              selectedIcon: const Icon(Icons.apartment_rounded),
              label: l.apartments,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline_rounded),
              selectedIcon: const Icon(Icons.people_rounded),
              label: l.renters,
            ),
            NavigationDestination(
              icon: const Icon(Icons.description_outlined),
              selectedIcon: const Icon(Icons.description_rounded),
              label: 'عقود',
            ),
            NavigationDestination(
              icon: const Icon(Icons.payment_outlined),
              selectedIcon: const Icon(Icons.payment_rounded),
              label: l.payments,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_rounded),
              selectedIcon: const Icon(Icons.menu_open_rounded),
              label: l.more,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Side Drawer ─────────────────────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _AppDrawer({required this.scaffoldKey});

  void _go(BuildContext context, String path) {
    scaffoldKey.currentState!.closeDrawer();
    Future.microtask(() => context.go(path));
  }


  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    return Drawer(
      width: 290,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 24, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientPrimary,
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.home_work_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  auth.displayName.isNotEmpty ? auth.displayName : 'إيجاري',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  auth.displayEmail.isNotEmpty ? auth.displayEmail : 'Ijari — Rent Manager',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                if (auth.role != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      auth.isOwner ? 'مالك' : 'موظف',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Menu ─────────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.receipt_long_rounded,
                  label: l.expenses,
                  color: AppColors.danger,
                  onTap: () => _go(context, '/expenses'),
                ),
                _DrawerItem(
                  icon: Icons.savings_rounded,
                  label: l.deposits,
                  color: AppColors.secondary,
                  onTap: () => _go(context, '/deposits'),
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: l.reports,
                  color: AppColors.accent,
                  onTap: () => _go(context, '/reports'),
                ),
                _DrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: l.aboutApp,
                  color: AppColors.primaryLight,
                  onTap: () => _go(context, '/about'),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Divider(color: AppColors.border),
                ),

                // Language toggle
                _DrawerToggle(
                  icon: Icons.language_rounded,
                  label: l.language,
                  trailing: Text(
                    localeProvider.isArabic ? l.arabic : l.english,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  onTap: () => localeProvider.toggleLocale(),
                ),

                _DrawerItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'الأمان والخصوصية',
                  color: AppColors.secondary,
                  onTap: () {
                    scaffoldKey.currentState!.closeDrawer();
                    Future.microtask(() => context.push('/settings/security'));
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Divider(color: AppColors.border),
                ),

                _DrawerItem(
                  icon: Icons.upload_rounded,
                  label: l.exportData,
                  color: Colors.teal,
                  onTap: () {
                    scaffoldKey.currentState!.closeDrawer();
                    BackupService.exportDatabase(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.download_rounded,
                  label: l.importData,
                  color: Colors.indigo,
                  onTap: () async {
                    scaffoldKey.currentState!.closeDrawer();
                    final ok = await BackupService.importDatabase(context);
                    if (ok && context.mounted) {
                      await Future.wait([
                        context.read<ApartmentProvider>().load(),
                        context.read<RenterProvider>().load(),
                        context.read<RentContractProvider>().load(),
                        context.read<RentPaymentProvider>().load(),
                        context.read<ExpenseProvider>().load(),
                        context.read<MonthlyDepositProvider>().load(),
                        context.read<DashboardProvider>().load(),
                      ]);
                      if (context.mounted) context.go('/dashboard');
                    }
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Divider(color: AppColors.border),
                ),

                _DrawerItem(
                  icon: Icons.logout_rounded,
                  label: 'تسجيل الخروج',
                  color: AppColors.danger,
                  onTap: () async {
                    scaffoldKey.currentState!.closeDrawer();
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),

          // ── Footer ────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
            child: Text(
              '© 2026 محمد السياني',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25), fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      onTap: onTap,
    );
  }
}

class _DrawerToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  const _DrawerToggle({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: const Icon(Icons.language_rounded, color: AppColors.primary, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
