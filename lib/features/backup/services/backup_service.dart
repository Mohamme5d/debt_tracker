import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
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
      // Generate a random 256-bit key and persist it
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
    // Store IV + ciphertext as base64, separated by ":"
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

    final data = {
      'version': 1,
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
              })
          .toList(),
      'payments': payments
          .map((p) => {
                'id': p.id,
                'transactionId': p.transaction.value?.id,
                'amount': p.amount,
                'date': p.date.toIso8601String(),
                'note': p.note,
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // ── Local backup ─────────────────────────────────────────────────────────

  Future<void> backupToiCloud() async {
    final json = await exportJson();
    final encrypted = await _encrypt(json);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/raseed_backup_$timestamp.rsd');
    await file.writeAsString(encrypted);
    await _saveBackupDate(_lastBackupKey);
  }

  Future<void> backupToLocalFile() async {
    final json = await exportJson();
    final encrypted = await _encrypt(json);
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('$result/raseed_backup_$timestamp.rsd');
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

  Future<GoogleSignInAccount?> _signInGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/drive.file',
      ],
    );
    // Sign out first to force account picker
    await googleSignIn.signOut();
    return googleSignIn.signIn();
  }

  Future<void> backupToGoogleDrive() async {
    final account = await _signInGoogle();
    if (account == null) return;

    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) throw Exception('Could not get access token');

    final json = await exportJson();
    final encrypted = await _encrypt(json);
    final bytes = utf8.encode(encrypted);
    final filename =
        'raseed_backup_${DateTime.now().millisecondsSinceEpoch}.rsd';

    // Multipart upload to Google Drive
    final boundary = '-------314159265358979323846';
    final body = '--$boundary\r\n'
        'Content-Type: application/json; charset=UTF-8\r\n\r\n'
        '{"name":"$filename","mimeType":"text/plain"}\r\n'
        '--$boundary\r\n'
        'Content-Type: text/plain\r\n\r\n'
        '${utf8.decode(bytes)}\r\n'
        '--$boundary--';

    final response = await http.post(
      Uri.parse(
          'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/related; boundary="$boundary"',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await _saveBackupDate(_lastGoogleBackupKey);
    } else {
      throw Exception(
          'Google Drive upload failed: ${response.statusCode}\n${response.body}');
    }
  }

  Future<void> restoreFromGoogleDrive() async {
    final account = await _signInGoogle();
    if (account == null) return;

    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) throw Exception('Could not get access token');

    // List raseed backup files, newest first
    final listResponse = await http.get(
      Uri.parse(
          "https://www.googleapis.com/drive/v3/files?q=name+contains+'raseed_backup'&orderBy=modifiedTime+desc&pageSize=1&fields=files(id,name)"),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (listResponse.statusCode != 200) {
      throw Exception('Failed to list Google Drive files: ${listResponse.body}');
    }

    final listData = jsonDecode(listResponse.body);
    final files = listData['files'] as List;
    if (files.isEmpty) {
      throw Exception('No backup files found on Google Drive');
    }

    final fileId = files.first['id'] as String;
    final downloadResponse = await http.get(
      Uri.parse(
          'https://www.googleapis.com/drive/v3/files/$fileId?alt=media'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (downloadResponse.statusCode != 200) {
      throw Exception('Failed to download backup from Google Drive');
    }

    final content = downloadResponse.body;
    final json = await _tryDecryptOrRaw(content);
    await _restoreFromJson(json);
  }

  // ── Restore helpers ───────────────────────────────────────────────────────

  /// Try to decrypt; if it fails, treat as plain JSON (legacy backup).
  Future<String> _tryDecryptOrRaw(String content) async {
    try {
      return await _decrypt(content);
    } catch (_) {
      return content; // plain JSON fallback
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
        final tx = DebtTransaction()
          ..type = TransactionType.values[td['type'] as int]
          ..amount = (td['amount'] as num).toDouble()
          ..amountPaid = (td['amountPaid'] as num).toDouble()
          ..date = DateTime.parse(td['date'] as String)
          ..dueDate = td['dueDate'] != null
              ? DateTime.parse(td['dueDate'] as String)
              : null
          ..note = td['note'] as String?
          ..status = TransactionStatus.values[td['status'] as int];

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
        final payment = Payment()
          ..amount = (pd['amount'] as num).toDouble()
          ..date = DateTime.parse(pd['date'] as String)
          ..note = pd['note'] as String?;

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
