import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/payment.dart';
import '../../../core/db/models/person.dart';

class BackupService {
  final Isar _isar;

  BackupService(this._isar);

  static const _lastBackupKey = 'last_backup_date';
  static const _lastGoogleBackupKey = 'last_google_backup_date';
  static const _encKeyStorageKey = 'backup_encryption_key';

  final _secureStorage = const FlutterSecureStorage();

  // ── Encryption helpers ──────────────────────────────────────────────────

  Future<enc.Key> _getEncryptionKey() async {
    String? stored = await _secureStorage.read(key: _encKeyStorageKey);
    if (stored == null) {
      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      stored = base64Url.encode(bytes);
      await _secureStorage.write(key: _encKeyStorageKey, value: stored);
    }
    return enc.Key(base64Url.decode(stored));
  }

  Future<String> _encrypt(String plainText) async {
    final key = await _getEncryptionKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${base64Url.encode(iv.bytes)}:${encrypted.base64}';
  }

  Future<String> _decrypt(String payload) async {
    final parts = payload.split(':');
    if (parts.length != 2) throw Exception('Invalid backup format');
    final key = await _getEncryptionKey();
    final iv = enc.IV(base64Url.decode(parts[0]));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(parts[1], iv: iv);
  }

  // ── Date helpers ─────────────────────────────────────────────────────────

  Future<String?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastBackupKey);
  }

  Future<String?> getLastGoogleBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastGoogleBackupKey);
  }

  Future<void> _saveBackupDate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, DateTime.now().toIso8601String());
  }

  // ── Export / Import JSON ─────────────────────────────────────────────────

  Future<String> exportJson() async {
    final persons = await _isar.persons.where().findAll();
    final transactions = await _isar.debtTransactions.where().findAll();
    final payments = await _isar.payments.where().findAll();

    for (final tx in transactions) {
      await tx.person.load();
    }
    for (final p in payments) {
      await p.transaction.load();
    }

    // Collect all attachment files and encode as base64
    final attachmentsMap = <String, String>{};
    final allPaths = [
      ...transactions.expand((tx) => tx.attachmentPaths),
      ...payments.expand((p) => p.attachmentPaths),
    ].toSet();

    for (final path in allPaths) {
      final file = File(path);
      if (file.existsSync()) {
        final filename = path.split('/').last;
        final bytes = await file.readAsBytes();
        attachmentsMap[filename] = base64.encode(bytes);
      }
    }

    final data = {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'persons': persons
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'phoneNumber': p.phoneNumber,
                'isFromContacts': p.isFromContacts,
              })
          .toList(),
      'transactions': transactions
          .map((tx) => {
                'id': tx.id,
                'personId': tx.person.value?.id,
                'type': tx.type.index,
                'amount': tx.amount,
                'amountPaid': tx.amountPaid,
                'date': tx.date.toIso8601String(),
                'dueDate': tx.dueDate?.toIso8601String(),
                'note': tx.note,
                'status': tx.status.index,
                'attachmentFilenames':
                    tx.attachmentPaths.map((p) => p.split('/').last).toList(),
              })
          .toList(),
      'payments': payments
          .map((p) => {
                'id': p.id,
                'transactionId': p.transaction.value?.id,
                'amount': p.amount,
                'date': p.date.toIso8601String(),
                'note': p.note,
                'attachmentFilenames':
                    p.attachmentPaths.map((p) => p.split('/').last).toList(),
              })
          .toList(),
      'attachments': attachmentsMap,
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // ── Local backup ─────────────────────────────────────────────────────────

  String _backupFilename() {
    final now = DateTime.now();
    final dt =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
    return 'Raseed_Backup-$dt.rsd';
  }

  Future<void> backupToiCloud() async {
    final json = await exportJson();
    final encrypted = await _encrypt(json);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${_backupFilename()}');
    await file.writeAsString(encrypted);
    await _saveBackupDate(_lastBackupKey);
  }

  Future<void> backupToLocalFile() async {
    final json = await exportJson();
    final encrypted = await _encrypt(json);
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;

    final file = File('$result/${_backupFilename()}');
    await file.writeAsString(encrypted);
    await _saveBackupDate(_lastBackupKey);
  }

  Future<void> restoreFromLocalFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.first.path;
    if (filePath == null) return;

    final content = await File(filePath).readAsString();
    final json = await _tryDecryptOrRaw(content);
    await _restoreFromJson(json);
  }

  // ── Google Drive ──────────────────────────────────────────────────────────

  Future<GoogleSignIn> _buildGoogleSignIn() async {
    return GoogleSignIn(
      scopes: [drive.DriveApi.driveFileScope],
    );
  }

  Future<drive.DriveApi?> _signInAndGetDriveApi() async {
    final googleSignIn = await _buildGoogleSignIn();
    await googleSignIn.signOut(); // force account picker
    final account = await googleSignIn.signIn();
    if (account == null) return null;

    final httpClient = await googleSignIn.authenticatedClient();
    if (httpClient == null) throw Exception('Could not get authenticated client');

    return drive.DriveApi(httpClient);
  }

  Future<void> backupToGoogleDrive() async {
    final driveApi = await _signInAndGetDriveApi();
    if (driveApi == null) return; // user cancelled

    final json = await exportJson();
    final encrypted = await _encrypt(json);
    final filename = _backupFilename();

    final contentBytes = utf8.encode(encrypted);
    final fileMetadata = drive.File()
      ..name = filename
      ..mimeType = 'text/plain';

    final media = drive.Media(
      Stream.value(contentBytes),
      contentBytes.length,
      contentType: 'text/plain',
    );

    await driveApi.files.create(
      fileMetadata,
      uploadMedia: media,
    );

    await _saveBackupDate(_lastGoogleBackupKey);
  }

  Future<void> restoreFromGoogleDrive() async {
    final driveApi = await _signInAndGetDriveApi();
    if (driveApi == null) return; // user cancelled

    // List most recent raseed backup file
    final fileList = await driveApi.files.list(
      q: "name contains 'Raseed_Backup'",
      orderBy: 'modifiedTime desc',
      pageSize: 1,
      $fields: 'files(id,name)',
    );

    final files = fileList.files;
    if (files == null || files.isEmpty) {
      throw Exception('No backup files found on Google Drive');
    }

    final fileId = files.first.id!;
    final response = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = <int>[];
    await response.stream.forEach(bytes.addAll);
    final content = utf8.decode(bytes);

    final jsonStr = await _tryDecryptOrRaw(content);
    await _restoreFromJson(jsonStr);
  }

  // ── Restore helpers ───────────────────────────────────────────────────────

  Future<String> _tryDecryptOrRaw(String content) async {
    try {
      return await _decrypt(content);
    } catch (_) {
      return content;
    }
  }

  Future<void> _restoreFromJson(String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    await _isar.writeTxn(() async {
      await _isar.payments.clear();
      await _isar.debtTransactions.clear();
      await _isar.persons.clear();
    });

    final personsData = data['persons'] as List;
    final transactionsData = data['transactions'] as List;
    final paymentsData = data['payments'] as List;

    // Restore attachment image files
    final attachmentsMap =
        (data['attachments'] as Map<String, dynamic>? ?? {})
            .cast<String, String>();

    final dir = await getApplicationDocumentsDirectory();
    final attachDir = Directory('${dir.path}/attachments');
    if (!attachDir.existsSync()) attachDir.createSync(recursive: true);

    // filename → restored absolute path
    final restoredPaths = <String, String>{};
    for (final entry in attachmentsMap.entries) {
      final filename = entry.key;
      final destPath = '${attachDir.path}/$filename';
      await File(destPath).writeAsBytes(base64.decode(entry.value));
      restoredPaths[filename] = destPath;
    }

    final personIdMap = <int, Person>{};

    await _isar.writeTxn(() async {
      for (final pd in personsData) {
        final person = Person()
          ..name = pd['name'] as String
          ..phoneNumber = pd['phoneNumber'] as String?
          ..isFromContacts = pd['isFromContacts'] as bool? ?? false;
        await _isar.persons.put(person);
        personIdMap[pd['id'] as int] = person;
      }
    });

    final txIdMap = <int, DebtTransaction>{};

    await _isar.writeTxn(() async {
      for (final td in transactionsData) {
        final filenames = (td['attachmentFilenames'] as List?)
                ?.cast<String>() ??
            [];
        final paths =
            filenames.map((f) => restoredPaths[f] ?? '').where((p) => p.isNotEmpty).toList();

        final tx = DebtTransaction()
          ..type = TransactionType.values[td['type'] as int]
          ..amount = (td['amount'] as num).toDouble()
          ..amountPaid = (td['amountPaid'] as num).toDouble()
          ..date = DateTime.parse(td['date'] as String)
          ..dueDate = td['dueDate'] != null
              ? DateTime.parse(td['dueDate'] as String)
              : null
          ..note = td['note'] as String?
          ..status = TransactionStatus.values[td['status'] as int]
          ..attachmentPaths = paths;

        await _isar.debtTransactions.put(tx);

        final personId = td['personId'] as int?;
        if (personId != null && personIdMap.containsKey(personId)) {
          tx.person.value = personIdMap[personId];
          await tx.person.save();
        }

        txIdMap[td['id'] as int] = tx;
      }
    });

    await _isar.writeTxn(() async {
      for (final pd in paymentsData) {
        final filenames = (pd['attachmentFilenames'] as List?)
                ?.cast<String>() ??
            [];
        final paths =
            filenames.map((f) => restoredPaths[f] ?? '').where((p) => p.isNotEmpty).toList();

        final payment = Payment()
          ..amount = (pd['amount'] as num).toDouble()
          ..date = DateTime.parse(pd['date'] as String)
          ..note = pd['note'] as String?
          ..attachmentPaths = paths;

        await _isar.payments.put(payment);

        final txId = pd['transactionId'] as int?;
        if (txId != null && txIdMap.containsKey(txId)) {
          payment.transaction.value = txIdMap[txId];
          await payment.transaction.save();
        }
      }
    });
  }
}
