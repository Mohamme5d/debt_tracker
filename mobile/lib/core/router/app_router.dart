import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/shell/main_shell.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/passcode_lock_screen.dart';
import '../../screens/settings/security_settings_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/apartments/apartment_list_screen.dart';
import '../../screens/apartments/apartment_form_screen.dart';
import '../../screens/renters/renter_list_screen.dart';
import '../../screens/renters/renter_form_screen.dart';
import '../../screens/contracts/rent_contract_list_screen.dart';
import '../../screens/contracts/rent_contract_form_screen.dart';
import '../../screens/rent_payments/rent_payment_list_screen.dart';
import '../../screens/rent_payments/rent_payment_form_screen.dart';
import '../../screens/expenses/expense_list_screen.dart';
import '../../screens/expenses/expense_form_screen.dart';
import '../../screens/deposits/deposit_list_screen.dart';
import '../../screens/deposits/deposit_form_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../screens/reports/pdf_preview_screen.dart';
import '../../screens/about/about_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/lock',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PasscodeLockScreen(isAppLock: true),
      ),
      GoRoute(
        path: '/settings/security',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/pdf-preview',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PdfPreviewScreen(
            bytes: extra['bytes'] as Uint8List,
            filename: extra['filename'] as String,
          );
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/apartments',
            builder: (context, state) => const ApartmentListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const ApartmentFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => ApartmentFormScreen(
                  apartmentId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/renters',
            builder: (context, state) => const RenterListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const RenterFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => RenterFormScreen(
                  renterId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/contracts',
            builder: (context, state) => const RentContractListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const RentContractFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => RentContractFormScreen(
                  contractId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const RentPaymentListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const RentPaymentFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => RentPaymentFormScreen(
                  paymentId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpenseListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const ExpenseFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => ExpenseFormScreen(
                  expenseId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/deposits',
            builder: (context, state) => const DepositListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const DepositFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => DepositFormScreen(
                  depositId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
  );
}
