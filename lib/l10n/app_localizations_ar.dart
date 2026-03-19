// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الديون والقروض';

  @override
  String get iOwe => 'أنا مدين';

  @override
  String get owedToMe => 'مستحق لي';

  @override
  String get noTransactions => 'لا توجد معاملات بعد';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get debt => 'دين';

  @override
  String get loan => 'قرض';

  @override
  String get amount => 'المبلغ';

  @override
  String get person => 'الشخص';

  @override
  String get date => 'التاريخ';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get note => 'ملاحظة (اختياري)';

  @override
  String get save => 'حفظ';

  @override
  String get settled => 'مسوّى';

  @override
  String get active => 'نشط';

  @override
  String get overdue => 'متأخر';

  @override
  String get payments => 'المدفوعات';

  @override
  String get addPayment => 'إضافة دفعة';

  @override
  String get markSettled => 'تحديد كمسوّى';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get remaining => 'المتبقي';

  @override
  String get paid => 'المدفوع';

  @override
  String get total => 'الإجمالي';

  @override
  String get selectPerson => 'اختر شخصاً';

  @override
  String get searchContacts => 'بحث في جهات الاتصال...';

  @override
  String get addManually => 'إضافة يدوياً';

  @override
  String get enterName => 'أدخل الاسم';

  @override
  String get amountRequired => 'المبلغ مطلوب';

  @override
  String get personRequired => 'الرجاء اختيار شخص';

  @override
  String get invalidAmount => 'أدخل مبلغاً صحيحاً';

  @override
  String get paymentExceedsRemaining => 'الدفعة تتجاوز المبلغ المتبقي';

  @override
  String get transactionDeleted => 'تم حذف المعاملة';

  @override
  String get paymentAdded => 'تم تسجيل الدفعة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get netBalance => 'الرصيد الصافي';

  @override
  String get youOwe => 'أنت مدين لـ';

  @override
  String get owesYou => 'مدين لك';

  @override
  String get settled_status => 'مسوّى';

  @override
  String get noPaymentsYet => 'لا توجد مدفوعات بعد';

  @override
  String get deleteTransaction => 'حذف المعاملة';

  @override
  String get deleteTransactionConfirm => 'هل أنت متأكد من حذف هذه المعاملة؟';

  @override
  String get deletePayment => 'حذف الدفعة؟';

  @override
  String get paymentNote => 'ملاحظة الدفعة (اختياري)';

  @override
  String get today => 'اليوم';

  @override
  String get progress => 'التقدم';

  @override
  String get people => 'الأشخاص';

  @override
  String get tapToAdd => 'اضغط + لإضافة معاملة';

  @override
  String get noActiveDebts => 'لا توجد ديون أو قروض نشطة';

  @override
  String get transactionSaved => 'تم حفظ المعاملة';

  @override
  String get debtIOwe => 'دين (أنا مدين)';

  @override
  String get loanOwesMe => 'قرض (مدين لي)';

  @override
  String get transactionDate => 'تاريخ المعاملة';

  @override
  String get setDueDate => 'تحديد تاريخ الاستحقاق';

  @override
  String get dueDateOptional => 'تاريخ الاستحقاق (اختياري)';

  @override
  String get addNote => 'أضف ملاحظة...';

  @override
  String get saveTransaction => 'حفظ المعاملة';

  @override
  String get type => 'النوع';

  @override
  String get amountGreaterThanZero => 'يجب أن يكون المبلغ أكبر من صفر';

  @override
  String get transaction => 'المعاملة';

  @override
  String get notFound => 'غير موجود';

  @override
  String get created => 'تم الإنشاء';

  @override
  String get due => 'الاستحقاق';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String get enterAnAmount => 'أدخل المبلغ';

  @override
  String get mustBeGreaterThanZero => 'يجب أن يكون أكبر من صفر';

  @override
  String get cannotExceedRemaining => 'لا يمكن تجاوز المتبقي';

  @override
  String get deletePaymentConfirm => 'سيتم عكس مبلغ الدفعة. هل تريد المتابعة؟';

  @override
  String get errorLoading => 'خطأ في تحميل البيانات';

  @override
  String get recent => 'الأخيرة';

  @override
  String get phoneContacts => 'جهات اتصال الهاتف';

  @override
  String get couldNotLoadContacts =>
      'تعذر تحميل جهات الاتصال. يمكنك إضافة الأسماء يدوياً.';

  @override
  String get searchOrType => 'بحث في جهات الاتصال أو اكتب اسماً...';

  @override
  String addNameManually(String name) {
    return 'إضافة \"$name\" يدوياً';
  }
}
