// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Debts & Loans';

  @override
  String get iOwe => 'I Owe';

  @override
  String get owedToMe => 'Owed to Me';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get debt => 'Debt';

  @override
  String get loan => 'Loan';

  @override
  String get amount => 'Amount';

  @override
  String get person => 'Person';

  @override
  String get date => 'Date';

  @override
  String get dueDate => 'Due Date';

  @override
  String get note => 'Note (optional)';

  @override
  String get save => 'Save';

  @override
  String get settled => 'Settled';

  @override
  String get active => 'Active';

  @override
  String get overdue => 'Overdue';

  @override
  String get payments => 'Payments';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get markSettled => 'Mark as Settled';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get remaining => 'Remaining';

  @override
  String get paid => 'Paid';

  @override
  String get total => 'Total';

  @override
  String get selectPerson => 'Select Person';

  @override
  String get searchContacts => 'Search contacts...';

  @override
  String get addManually => 'Add manually';

  @override
  String get enterName => 'Enter name';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get personRequired => 'Please select a person';

  @override
  String get invalidAmount => 'Enter a valid amount';

  @override
  String get paymentExceedsRemaining => 'Payment exceeds remaining amount';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get paymentAdded => 'Payment recorded';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get youOwe => 'You owe';

  @override
  String get owesYou => 'owes you';

  @override
  String get settled_status => 'Settled';

  @override
  String get noPaymentsYet => 'No payments yet';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteTransactionConfirm =>
      'Are you sure you want to delete this transaction?';

  @override
  String get deletePayment => 'Delete payment?';

  @override
  String get paymentNote => 'Payment note (optional)';

  @override
  String get today => 'Today';

  @override
  String get progress => 'Progress';

  @override
  String get people => 'People';

  @override
  String get tapToAdd => 'Tap + to add a transaction';

  @override
  String get noActiveDebts => 'No active debts or loans';

  @override
  String get transactionSaved => 'Transaction saved';

  @override
  String get debtIOwe => 'Debt (I Owe)';

  @override
  String get loanOwesMe => 'Loan (Owes Me)';

  @override
  String get transactionDate => 'Transaction date';

  @override
  String get setDueDate => 'Set due date';

  @override
  String get dueDateOptional => 'Due Date (optional)';

  @override
  String get addNote => 'Add a note...';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get type => 'Type';

  @override
  String get amountGreaterThanZero => 'Amount must be greater than zero';

  @override
  String get transaction => 'Transaction';

  @override
  String get notFound => 'Not found';

  @override
  String get created => 'Created';

  @override
  String get due => 'Due';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get enterAnAmount => 'Enter an amount';

  @override
  String get mustBeGreaterThanZero => 'Must be greater than zero';

  @override
  String get cannotExceedRemaining => 'Cannot exceed remaining';

  @override
  String get deletePaymentConfirm =>
      'This will reverse the payment amount. Continue?';

  @override
  String get errorLoading => 'Error loading data';

  @override
  String get recent => 'Recent';

  @override
  String get phoneContacts => 'Phone Contacts';

  @override
  String get couldNotLoadContacts =>
      'Could not load contacts. You can still add names manually.';

  @override
  String get searchOrType => 'Search contacts or type a name...';

  @override
  String addNameManually(String name) {
    return 'Add \"$name\" manually';
  }

  @override
  String get transactions => 'Transactions';

  @override
  String get allTransactions => 'All Transactions';

  @override
  String get goodStatus => 'You\'re in good shape';

  @override
  String get badStatus => 'You have outstanding debts';

  @override
  String get debtVsLoan => 'Debt vs Loan';

  @override
  String get monthlyOverview => 'Monthly Overview';

  @override
  String get balanceTrend => 'Balance Trend';

  @override
  String get thisMonth => 'This Month';

  @override
  String get all => 'All';

  @override
  String get security => 'Security';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get biometricSubtitle => 'Use fingerprint or Face ID to unlock';

  @override
  String get passcode => 'Passcode Lock';

  @override
  String get passcodeSubtitle => 'Set a 6-digit PIN code';

  @override
  String get autoLock => 'Auto-Lock';

  @override
  String get immediately => 'Immediately';

  @override
  String get after1Min => 'After 1 minute';

  @override
  String get after5Min => 'After 5 minutes';

  @override
  String get after1Hour => 'After 1 hour';

  @override
  String get never => 'Never';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get importBackupSubtitle => 'Restore data from a backup file';

  @override
  String get importFromGoogleDrive => 'Import from Google Drive';

  @override
  String get importFromLocalFile => 'Import from Local File';

  @override
  String get importSuccess => 'Data imported successfully';

  @override
  String get importFailed => 'Import failed';

  @override
  String get backupSync => 'Backup & Sync';

  @override
  String get icloudBackup => 'iCloud Backup';

  @override
  String get icloudSubtitle => 'Backup data to iCloud';

  @override
  String get googleDriveBackup => 'Google Drive Backup';

  @override
  String get googleDriveSubtitle => 'Backup data to Google Drive';

  @override
  String get localBackup => 'Local Backup';

  @override
  String get localBackupSubtitle => 'Save backup to device';

  @override
  String lastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String get neverBackedUp => 'Never backed up';

  @override
  String get dataExport => 'Data Export';

  @override
  String get exportPdf => 'Export to PDF';

  @override
  String get exportPdfSubtitle => 'Generate PDF report';

  @override
  String get exportByPerson => 'Export by Person';

  @override
  String get exportByDate => 'Export by Date Range';

  @override
  String get app => 'App';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get currency => 'Currency';

  @override
  String get appVersion => 'App Version';

  @override
  String get useBiometric => 'Use Biometric';

  @override
  String get enterPasscode => 'Enter Passcode';

  @override
  String get setPasscode => 'Set Passcode';

  @override
  String get confirmPasscode => 'Confirm Passcode';

  @override
  String get wrongPasscode => 'Wrong Passcode';

  @override
  String get passcodeMismatch => 'Passcodes do not match';

  @override
  String get passcodeSet => 'Passcode set successfully';

  @override
  String get passcodeRemoved => 'Passcode removed';

  @override
  String get biometricEnabled => 'Biometric authentication enabled';

  @override
  String get biometricDisabled => 'Biometric authentication disabled';

  @override
  String get biometricNotAvailable => 'Biometric authentication not available';

  @override
  String get unlockApp => 'Unlock App';

  @override
  String get backupSuccess => 'Backup completed successfully';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get restoreSuccess => 'Restore completed successfully';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get exportAll => 'Export All';

  @override
  String get exportActiveOnly => 'Export Active Only';

  @override
  String get filterByPerson => 'Filter by Person';

  @override
  String get dateRange => 'Date Range';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get reportTitle => 'Debts & Loans Report';

  @override
  String get noData => 'No data available';

  @override
  String get greeting => 'Hello!';

  @override
  String get summary => 'Summary';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get status => 'Status';

  @override
  String get allPersons => 'All Persons';

  @override
  String transactionsFor(String name) {
    return 'Transactions for $name';
  }

  @override
  String get aboutApp => 'About';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get edit => 'Edit';
}
