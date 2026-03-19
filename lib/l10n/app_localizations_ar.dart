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

  @override
  String get transactions => 'المعاملات';

  @override
  String get allTransactions => 'جميع المعاملات';

  @override
  String get goodStatus => 'أنت في وضع جيد';

  @override
  String get badStatus => 'لديك ديون متأخرة';

  @override
  String get debtVsLoan => 'الديون مقابل القروض';

  @override
  String get monthlyOverview => 'نظرة شهرية';

  @override
  String get balanceTrend => 'اتجاه الرصيد';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get all => 'الكل';

  @override
  String get security => 'الأمان';

  @override
  String get biometricAuth => 'المصادقة البيومترية';

  @override
  String get biometricSubtitle => 'استخدم بصمة الإصبع أو بصمة الوجه للفتح';

  @override
  String get passcode => 'رمز القفل';

  @override
  String get passcodeSubtitle => 'تعيين رمز PIN مكون من 6 أرقام';

  @override
  String get autoLock => 'القفل التلقائي';

  @override
  String get immediately => 'فوراً';

  @override
  String get after1Min => 'بعد دقيقة واحدة';

  @override
  String get after5Min => 'بعد 5 دقائق';

  @override
  String get backupSync => 'النسخ الاحتياطي والمزامنة';

  @override
  String get icloudBackup => 'نسخ احتياطي على iCloud';

  @override
  String get icloudSubtitle => 'حفظ البيانات على iCloud';

  @override
  String get googleDriveBackup => 'نسخ احتياطي على Google Drive';

  @override
  String get googleDriveSubtitle => 'حفظ البيانات على Google Drive';

  @override
  String get localBackup => 'نسخ احتياطي محلي';

  @override
  String get localBackupSubtitle => 'حفظ النسخة الاحتياطية على الجهاز';

  @override
  String lastBackup(String date) {
    return 'آخر نسخ احتياطي: $date';
  }

  @override
  String get neverBackedUp => 'لم يتم النسخ الاحتياطي بعد';

  @override
  String get dataExport => 'تصدير البيانات';

  @override
  String get exportPdf => 'تصدير إلى PDF';

  @override
  String get exportPdfSubtitle => 'إنشاء تقرير PDF';

  @override
  String get exportByPerson => 'تصدير حسب الشخص';

  @override
  String get exportByDate => 'تصدير حسب الفترة';

  @override
  String get app => 'التطبيق';

  @override
  String get theme => 'المظهر';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get darkTheme => 'داكن';

  @override
  String get systemTheme => 'النظام';

  @override
  String get currency => 'العملة';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get useBiometric => 'استخدم بصمة الإصبع';

  @override
  String get enterPasscode => 'أدخل الرمز السري';

  @override
  String get setPasscode => 'تعيين الرمز السري';

  @override
  String get confirmPasscode => 'تأكيد الرمز السري';

  @override
  String get wrongPasscode => 'رمز سري خاطئ';

  @override
  String get passcodeMismatch => 'الرموز السرية غير متطابقة';

  @override
  String get passcodeSet => 'تم تعيين الرمز السري بنجاح';

  @override
  String get passcodeRemoved => 'تم إزالة الرمز السري';

  @override
  String get biometricEnabled => 'تم تفعيل المصادقة البيومترية';

  @override
  String get biometricDisabled => 'تم تعطيل المصادقة البيومترية';

  @override
  String get biometricNotAvailable => 'المصادقة البيومترية غير متاحة';

  @override
  String get unlockApp => 'فتح التطبيق';

  @override
  String get backupSuccess => 'تم النسخ الاحتياطي بنجاح';

  @override
  String get backupFailed => 'فشل النسخ الاحتياطي';

  @override
  String get restoreSuccess => 'تم الاستعادة بنجاح';

  @override
  String get restoreFailed => 'فشل الاستعادة';

  @override
  String get exportAll => 'تصدير الكل';

  @override
  String get exportActiveOnly => 'تصدير النشطة فقط';

  @override
  String get filterByPerson => 'تصفية حسب الشخص';

  @override
  String get dateRange => 'نطاق التاريخ';

  @override
  String get generateReport => 'إنشاء التقرير';

  @override
  String get reportTitle => 'تقرير الديون والقروض';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get greeting => 'مرحباً!';

  @override
  String get summary => 'الملخص';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get status => 'الحالة';

  @override
  String get allPersons => 'جميع الأشخاص';

  @override
  String transactionsFor(String name) {
    return 'معاملات $name';
  }
}
