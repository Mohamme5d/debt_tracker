import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rent Manager'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @apartments.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get apartments;

  /// No description provided for @renters.
  ///
  /// In en, this message translates to:
  /// **'Renters'**
  String get renters;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @deposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get deposits;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteConfirmMessage;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @monthlyRent.
  ///
  /// In en, this message translates to:
  /// **'Monthly Rent'**
  String get monthlyRent;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @isActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get isActive;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @renter.
  ///
  /// In en, this message translates to:
  /// **'Renter'**
  String get renter;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @rentAmount.
  ///
  /// In en, this message translates to:
  /// **'Rent Amount'**
  String get rentAmount;

  /// No description provided for @outstandingBefore.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Before'**
  String get outstandingBefore;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @outstandingAfter.
  ///
  /// In en, this message translates to:
  /// **'Outstanding After'**
  String get outstandingAfter;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Expense Date'**
  String get expenseDate;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @totalCollected.
  ///
  /// In en, this message translates to:
  /// **'Total Collected'**
  String get totalCollected;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission (10%)'**
  String get commission;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @netAmount.
  ///
  /// In en, this message translates to:
  /// **'Net Amount'**
  String get netAmount;

  /// No description provided for @depositedAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposited Amount'**
  String get depositedAmount;

  /// No description provided for @leftAmount.
  ///
  /// In en, this message translates to:
  /// **'Left Amount'**
  String get leftAmount;

  /// No description provided for @addApartment.
  ///
  /// In en, this message translates to:
  /// **'Add Apartment'**
  String get addApartment;

  /// No description provided for @editApartment.
  ///
  /// In en, this message translates to:
  /// **'Edit Apartment'**
  String get editApartment;

  /// No description provided for @addRenter.
  ///
  /// In en, this message translates to:
  /// **'Add Renter'**
  String get addRenter;

  /// No description provided for @editRenter.
  ///
  /// In en, this message translates to:
  /// **'Edit Renter'**
  String get editRenter;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @editPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment'**
  String get editPayment;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @addDeposit.
  ///
  /// In en, this message translates to:
  /// **'Add Deposit'**
  String get addDeposit;

  /// No description provided for @editDeposit.
  ///
  /// In en, this message translates to:
  /// **'Edit Deposit'**
  String get editDeposit;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get invalidNumber;

  /// No description provided for @duplicatePayment.
  ///
  /// In en, this message translates to:
  /// **'A payment for this renter and month already exists'**
  String get duplicatePayment;

  /// No description provided for @selectApartment.
  ///
  /// In en, this message translates to:
  /// **'Select Apartment'**
  String get selectApartment;

  /// No description provided for @selectRenter.
  ///
  /// In en, this message translates to:
  /// **'Select Renter'**
  String get selectRenter;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @monthlyRentsReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Rents Report'**
  String get monthlyRentsReport;

  /// No description provided for @renterHistoryReport.
  ///
  /// In en, this message translates to:
  /// **'Renter History Report'**
  String get renterHistoryReport;

  /// No description provided for @apartmentHistoryReport.
  ///
  /// In en, this message translates to:
  /// **'Apartment History Report'**
  String get apartmentHistoryReport;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @totalApartments.
  ///
  /// In en, this message translates to:
  /// **'Total Apartments'**
  String get totalApartments;

  /// No description provided for @totalRenters.
  ///
  /// In en, this message translates to:
  /// **'Total Renters'**
  String get totalRenters;

  /// No description provided for @totalPaymentsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Payments This Month'**
  String get totalPaymentsThisMonth;

  /// No description provided for @outstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Balance'**
  String get outstandingBalance;

  /// No description provided for @recentPayments.
  ///
  /// In en, this message translates to:
  /// **'Recent Payments'**
  String get recentPayments;

  /// No description provided for @depositMonth.
  ///
  /// In en, this message translates to:
  /// **'Deposit Month'**
  String get depositMonth;

  /// No description provided for @depositYear.
  ///
  /// In en, this message translates to:
  /// **'Deposit Year'**
  String get depositYear;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @renterName.
  ///
  /// In en, this message translates to:
  /// **'Renter Name'**
  String get renterName;

  /// No description provided for @apartmentName.
  ///
  /// In en, this message translates to:
  /// **'Apartment Name'**
  String get apartmentName;

  /// No description provided for @serialNo.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get serialNo;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @reportFor.
  ///
  /// In en, this message translates to:
  /// **'Report for'**
  String get reportFor;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @searchApartment.
  ///
  /// In en, this message translates to:
  /// **'Search apartment...'**
  String get searchApartment;

  /// No description provided for @searchRenter.
  ///
  /// In en, this message translates to:
  /// **'Search renter...'**
  String get searchRenter;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(String field);

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get appDescription;

  /// No description provided for @appDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Ijari is a rental management app. Track apartments, renters, monthly payments, expenses, deposits, and generate detailed PDF & Excel reports — all in one place.'**
  String get appDescriptionText;

  /// No description provided for @apartmentChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Changing the apartment does not affect previous payment records.'**
  String get apartmentChangeNote;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @featureApartments.
  ///
  /// In en, this message translates to:
  /// **'Apartment management'**
  String get featureApartments;

  /// No description provided for @featureRenters.
  ///
  /// In en, this message translates to:
  /// **'Renter tracking'**
  String get featureRenters;

  /// No description provided for @featurePayments.
  ///
  /// In en, this message translates to:
  /// **'Payment recording'**
  String get featurePayments;

  /// No description provided for @featureExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expense tracking'**
  String get featureExpenses;

  /// No description provided for @featureDeposits.
  ///
  /// In en, this message translates to:
  /// **'Deposit management'**
  String get featureDeposits;

  /// No description provided for @featureReports.
  ///
  /// In en, this message translates to:
  /// **'PDF report generation'**
  String get featureReports;

  /// No description provided for @featureBilingual.
  ///
  /// In en, this message translates to:
  /// **'Full Arabic / English support'**
  String get featureBilingual;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @excelExport.
  ///
  /// In en, this message translates to:
  /// **'Excel Export'**
  String get excelExport;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No description provided for @commissionReport.
  ///
  /// In en, this message translates to:
  /// **'Commission History'**
  String get commissionReport;

  /// No description provided for @generatePayments.
  ///
  /// In en, this message translates to:
  /// **'Generate Payments'**
  String get generatePayments;

  /// No description provided for @generatePaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Payments'**
  String get generatePaymentsTitle;

  /// No description provided for @generatePaymentsConfirm.
  ///
  /// In en, this message translates to:
  /// **'{month} {year} — {count} active renters'**
  String generatePaymentsConfirm(String month, String year, int count);

  /// No description provided for @recordsCreated.
  ///
  /// In en, this message translates to:
  /// **'{count} records created'**
  String recordsCreated(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
