export type Lang = 'en' | 'ar';

export type TranslationKey =
  // Navigation
  | 'dashboard' | 'apartments' | 'renters' | 'contracts' | 'payments'
  | 'expenses' | 'deposits' | 'approvals' | 'employees' | 'reports'
  | 'logout' | 'notifications' | 'noNotifications'
  // Common
  | 'name' | 'phone' | 'email' | 'notes' | 'save' | 'cancel' | 'add' | 'edit' | 'delete'
  | 'address' | 'description' | 'password' | 'loading' | 'yes' | 'no'
  | 'saved' | 'actions' | 'createdAt' | 'status' | 'active' | 'inactive'
  | 'pending' | 'approved' | 'rejected'
  // Apartments
  | 'addApartment' | 'editApartment' | 'noApartmentsYet'
  // Renters
  | 'renter' | 'addRenter' | 'editRenter' | 'noRentersYet'
  // Contracts
  | 'contract' | 'addContract' | 'editContract' | 'noContractsYet'
  | 'apartment' | 'monthlyRent' | 'startDate' | 'endDate' | 'isActive'
  | 'period' | 'selectRenter' | 'selectApartment' | 'searchRenter' | 'searchApartment'
  // Payments
  | 'addPayment' | 'editPayment' | 'noPaymentsYet' | 'selectContract'
  | 'month' | 'year' | 'rentAmount' | 'outstandingBefore' | 'amountPaid'
  | 'rent' | 'paid' | 'outstanding' | 'generateThisMonth'
  // Expenses
  | 'category' | 'amount' | 'noExpensesYet'
  // Deposits
  | 'monthlyDeposits' | 'noDepositsYet'
  // Approvals
  | 'showPending' | 'showAll' | 'submittedBy' | 'type' | 'action' | 'date'
  | 'approve' | 'reject' | 'noPendingApprovals'
  // Employees
  | 'inviteEmployee' | 'noEmployeesYet' | 'invite'
  // Dashboard stat labels
  | 'totalApartments' | 'activeRenters' | 'collectedThisMonth' | 'totalOutstanding'
  | 'expensesThisMonth' | 'pendingApprovalsCount' | 'unreadNotifications'
  // Login
  | 'signIn' | 'rentManagement' | 'newAccount'
  // Shell labels
  | 'navigation' | 'management' | 'owner' | 'employee';

type Translations = Record<TranslationKey, string>;

export const TRANSLATIONS: Record<Lang, Translations> = {
  en: {
    dashboard: 'Dashboard', apartments: 'Apartments', renters: 'Renters',
    contracts: 'Contracts', payments: 'Payments', expenses: 'Expenses',
    deposits: 'Deposits', approvals: 'Approvals', employees: 'Employees',
    reports: 'Reports', logout: 'Logout', notifications: 'Notifications',
    noNotifications: 'No notifications',
    name: 'Name', phone: 'Phone', email: 'Email', notes: 'Notes',
    save: 'Save', cancel: 'Cancel', add: 'Add', edit: 'Edit', delete: 'Delete',
    address: 'Address', description: 'Description', password: 'Password',
    loading: 'Loading...', yes: 'Yes', no: 'No', saved: 'Saved',
    actions: 'Actions', createdAt: 'Created', status: 'Status',
    active: 'Active', inactive: 'Inactive',
    pending: 'Pending', approved: 'Approved', rejected: 'Rejected',
    addApartment: 'Add Apartment', editApartment: 'Edit Apartment', noApartmentsYet: 'No apartments yet.',
    renter: 'Renter', addRenter: 'Add Renter', editRenter: 'Edit Renter', noRentersYet: 'No renters yet.',
    contract: 'Contract', addContract: 'Add Contract', editContract: 'Edit Contract', noContractsYet: 'No contracts yet.',
    apartment: 'Apartment', monthlyRent: 'Monthly Rent', startDate: 'Start Date', endDate: 'End Date', isActive: 'Active',
    period: 'Period', selectRenter: 'Select renter...', selectApartment: 'Select apartment...',
    searchRenter: 'Search renter', searchApartment: 'Search apartment',
    addPayment: 'Add Payment', editPayment: 'Edit Payment', noPaymentsYet: 'No payments yet.', selectContract: 'Select contract...',
    month: 'Month', year: 'Year', rentAmount: 'Rent Amount',
    outstandingBefore: 'Outstanding Before', amountPaid: 'Amount Paid',
    rent: 'Rent', paid: 'Paid', outstanding: 'Outstanding', generateThisMonth: 'Generate This Month',
    category: 'Category', amount: 'Amount', noExpensesYet: 'No expenses yet.',
    monthlyDeposits: 'Monthly Deposits', noDepositsYet: 'No deposits yet.',
    showPending: 'Show Pending', showAll: 'Show All',
    submittedBy: 'Submitted By', type: 'Type', action: 'Action', date: 'Date',
    approve: 'Approve', reject: 'Reject', noPendingApprovals: 'No pending approvals.',
    inviteEmployee: 'Invite Employee', noEmployeesYet: 'No employees yet.', invite: 'Invite',
    totalApartments: 'Apartments', activeRenters: 'Active Renters',
    collectedThisMonth: 'Collected This Month', totalOutstanding: 'Total Outstanding',
    expensesThisMonth: 'Expenses This Month', pendingApprovalsCount: 'Pending Approvals',
    unreadNotifications: 'Unread Notifications',
    signIn: 'Sign In', rentManagement: 'Rent Management Platform', newAccount: 'New account? Register here',
    navigation: 'Navigation', management: 'Management', owner: 'Owner', employee: 'Employee',
  },
  ar: {
    dashboard: 'لوحة التحكم', apartments: 'الشقق', renters: 'المستأجرون',
    contracts: 'العقود', payments: 'المدفوعات', expenses: 'المصروفات',
    deposits: 'الودائع', approvals: 'الموافقات', employees: 'الموظفون',
    reports: 'التقارير', logout: 'تسجيل الخروج', notifications: 'الإشعارات',
    noNotifications: 'لا توجد إشعارات',
    name: 'الاسم', phone: 'الهاتف', email: 'البريد الإلكتروني', notes: 'ملاحظات',
    save: 'حفظ', cancel: 'إلغاء', add: 'إضافة', edit: 'تعديل', delete: 'حذف',
    address: 'العنوان', description: 'الوصف', password: 'كلمة المرور',
    loading: 'جارٍ التحميل...', yes: 'نعم', no: 'لا', saved: 'تم الحفظ',
    actions: 'إجراءات', createdAt: 'تاريخ الإنشاء', status: 'الحالة',
    active: 'نشط', inactive: 'غير نشط',
    pending: 'معلق', approved: 'موافق عليه', rejected: 'مرفوض',
    addApartment: 'إضافة شقة', editApartment: 'تعديل شقة', noApartmentsYet: 'لا توجد شقق حتى الآن.',
    renter: 'المستأجر', addRenter: 'إضافة مستأجر', editRenter: 'تعديل مستأجر', noRentersYet: 'لا يوجد مستأجرون حتى الآن.',
    contract: 'العقد', addContract: 'إضافة عقد', editContract: 'تعديل عقد', noContractsYet: 'لا توجد عقود حتى الآن.',
    apartment: 'الشقة', monthlyRent: 'الإيجار الشهري', startDate: 'تاريخ البداية', endDate: 'تاريخ الانتهاء', isActive: 'نشط',
    period: 'الفترة', selectRenter: 'اختر مستأجراً...', selectApartment: 'اختر شقة...',
    searchRenter: 'بحث عن مستأجر', searchApartment: 'بحث عن شقة',
    addPayment: 'إضافة دفعة', editPayment: 'تعديل الدفعة', noPaymentsYet: 'لا توجد مدفوعات حتى الآن.', selectContract: 'اختر عقداً...',
    month: 'الشهر', year: 'السنة', rentAmount: 'مبلغ الإيجار',
    outstandingBefore: 'المتبقي السابق', amountPaid: 'المبلغ المدفوع',
    rent: 'الإيجار', paid: 'المدفوع', outstanding: 'المتبقي', generateThisMonth: 'توليد هذا الشهر',
    category: 'الفئة', amount: 'المبلغ', noExpensesYet: 'لا توجد مصروفات حتى الآن.',
    monthlyDeposits: 'الودائع الشهرية', noDepositsYet: 'لا توجد ودائع حتى الآن.',
    showPending: 'عرض المعلقة', showAll: 'عرض الكل',
    submittedBy: 'مُقدَّم من', type: 'النوع', action: 'الإجراء', date: 'التاريخ',
    approve: 'موافقة', reject: 'رفض', noPendingApprovals: 'لا توجد موافقات معلقة.',
    inviteEmployee: 'دعوة موظف', noEmployeesYet: 'لا يوجد موظفون حتى الآن.', invite: 'دعوة',
    totalApartments: 'الشقق', activeRenters: 'المستأجرون النشطون',
    collectedThisMonth: 'المحصّل هذا الشهر', totalOutstanding: 'إجمالي المتبقي',
    expensesThisMonth: 'مصروفات هذا الشهر', pendingApprovalsCount: 'الموافقات المعلقة',
    unreadNotifications: 'إشعارات غير مقروءة',
    signIn: 'تسجيل الدخول', rentManagement: 'منصة إدارة الإيجار', newAccount: 'حساب جديد؟ سجّل هنا',
    navigation: 'التنقل', management: 'الإدارة', owner: 'المالك', employee: 'موظف',
  }
};
