class AppDateUtils {
  static String monthName(int month, {bool arabic = false}) {
    const enMonths = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const arMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    if (month < 1 || month > 12) return '';
    return arabic ? arMonths[month - 1] : enMonths[month - 1];
  }

  static String formatMonthYear(int month, int year, {bool arabic = false}) {
    return '${monthName(month, arabic: arabic)} $year';
  }

  static String toIso(DateTime dt) => dt.toIso8601String().split('T').first;

  static DateTime fromIso(String s) => DateTime.parse(s);

  static List<int> get currentMonthYear {
    final now = DateTime.now();
    return [now.month, now.year];
  }
}
