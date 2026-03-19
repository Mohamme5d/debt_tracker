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
}
