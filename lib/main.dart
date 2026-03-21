import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:isar/isar.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/db/isar_service.dart';
import 'core/db/models/debt_transaction.dart';
import 'core/db/models/enums.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/notification_service.dart';
import 'features/security/presentation/lock_screen.dart';
import 'features/security/providers/security_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = await IsarService.init();

  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
      ],
      child: const DebtTrackerApp(),
    ),
  );

  // Initialize notifications in the background after UI is shown
  _initNotifications(isarService);
}

void _initNotifications(IsarService isarService) async {
  try {
    await NotificationService.initialize();
    final transactions =
        isarService.isar.debtTransactions.where().findAllSync();
    for (final tx in transactions) {
      tx.person.loadSync();
    }
    final pending = transactions
        .where((tx) =>
            tx.dueDate != null && tx.status != TransactionStatus.settled)
        .toList();
    await NotificationService.syncAll(pending);
  } catch (_) {
    // Notification errors must never crash the app
  }
}

class DebtTrackerApp extends ConsumerStatefulWidget {
  const DebtTrackerApp({super.key});

  @override
  ConsumerState<DebtTrackerApp> createState() => _DebtTrackerAppState();
}

class _DebtTrackerAppState extends ConsumerState<DebtTrackerApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onResume,
      onPause: _onPause,
      onInactive: _onInactive,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _onPause() {
    final security = ref.read(securityNotifierProvider);
    // -1 = never lock
    if (security.hasAnySecurity && security.autoLockSeconds != -1) {
      if (security.autoLockSeconds == 0) {
        ref.read(securityNotifierProvider.notifier).lock();
      }
    }
  }

  void _onInactive() {
    final security = ref.read(securityNotifierProvider);
    if (security.hasAnySecurity && security.autoLockSeconds == 0) {
      ref.read(securityNotifierProvider.notifier).lock();
    }
  }

  void _onResume() {
    // Lock screen is handled by the overlay below
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeNotifierProvider);
    final security = ref.watch(securityNotifierProvider);

    return MaterialApp.router(
      title: 'Raseed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (security.isLocked)
              const Positioned.fill(
                child: LockScreen(),
              ),
          ],
        );
      },
    );
  }
}
