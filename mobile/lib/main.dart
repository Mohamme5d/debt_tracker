import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/apartment_provider.dart';
import 'providers/renter_provider.dart';
import 'providers/rent_payment_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/monthly_deposit_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/rent_contract_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ApartmentProvider()),
        ChangeNotifierProvider(create: (_) => RenterProvider()),
        ChangeNotifierProvider(create: (_) => RentPaymentProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyDepositProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => RentContractProvider()),
      ],
      child: const RentManagerApp(),
    ),
  );
}
