import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/transactions/presentation/add_transaction_screen.dart';
import '../features/transactions/presentation/all_transactions_screen.dart';
import '../features/transactions/presentation/person_transactions_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/security/presentation/lock_screen.dart';
import '../shared/widgets/app_shell.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Full-screen splash route (outside shell)
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      // Shell route for bottom nav (Dashboard, Transactions, Settings)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AllTransactionsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      // Full-screen routes outside shell
      GoRoute(
        path: '/person/:id',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CustomTransitionPage(
            key: state.pageKey,
            child: PersonTransactionsScreen(personId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/transaction/:id',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CustomTransitionPage(
            key: state.pageKey,
            child: TransactionDetailScreen(transactionId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/add-transaction',
        pageBuilder: (context, state) {
          final personIdStr = state.uri.queryParameters['personId'];
          final personId =
              personIdStr != null ? int.tryParse(personIdStr) : null;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddTransactionScreen(personId: personId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return SlideTransition(
                position: slideAnimation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/lock',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LockScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('Not Found')),
      body: const Center(
        child: Text('Page not found',
            style: TextStyle(color: Colors.white)),
      ),
    ),
  );
}
