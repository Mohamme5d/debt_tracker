import 'package:flutter/material.dart';

/// Backup/restore is not available in the cloud-connected version.
/// Data is stored on the server and synced automatically.
class BackupService {
  static Future<void> exportDatabase(BuildContext context) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('النسخ الاحتياطي غير متاح — البيانات محفوظة على الخادم'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  static Future<bool> importDatabase(BuildContext context) async {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('الاستيراد غير متاح — يُدار حسابك عبر لوحة التحكم'),
        duration: Duration(seconds: 3),
      ),
    );
    return false;
  }
}
