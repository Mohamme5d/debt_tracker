# Raseed — رصيد

**Raseed** (رصيد) is a personal debt & loan tracker for iOS and Android, built with Flutter. It helps you keep track of money you've lent or borrowed — who owes you, who you owe, due dates, partial payments, and more.

> All data is stored **locally on your device only**. Raseed never reads, transmits, or uploads your financial data to any server.

---

## Features

- **Track debts & loans** — record transactions as either "debt" (money owed to you) or "loan" (money you owe)
- **Edit transactions** — update any field on an existing transaction at any time
- **Contacts integration** — pick contacts from your phone or add people manually
- **Partial payments** — record incremental payments with custom date and optional notes; progress bar shows how much is remaining
- **Payment date picker** — set the exact date a payment was made (supports backdating)
- **Attachments** — attach photos (camera or gallery) to transactions and payments; full-screen image viewer built in
- **Due dates & overdue detection** — transactions past their due date are automatically marked overdue
- **Delete transactions** — delete any transaction (including settled ones) with confirmation dialog
- **Dashboard** — summary cards, balance charts (line, bar, pie), and per-person balances
- **PDF export** — generate and share a full transaction report as a PDF (all or active-only, per person or all)
- **Encrypted backup** — AES-256-CBC encrypted backup files (`.rsd`) to local storage or Google Drive; backup includes all attachments (images embedded as base64)
- **Restore from backup** — import from a local `.rsd` file or Google Drive; images are fully restored
- **Biometric authentication** — Face ID (iOS) / Fingerprint (Android), requires passcode as a prerequisite
- **6-digit passcode** — app lock with animated inline numpad (always LTR, works correctly in Arabic mode)
- **Auto-lock** — choose from: Immediately, 1 minute, 5 minutes, 1 hour, or Never
- **Arabic & English** — fully bilingual UI with RTL support; language toggle in settings
- **Dark theme** — deep navy dark theme with blue accents throughout
- **About page** — developer contact info + privacy statement

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.41.5 / Dart 3 |
| State management | Riverpod 2 (`flutter_riverpod`, `riverpod_annotation`) |
| Database | Isar 3.1.0+1 (embedded NoSQL, reactive streams) |
| Routing | GoRouter 13 |
| Biometrics | `local_auth` 2.2.0 |
| Secure storage | `flutter_secure_storage` 9.0.0 |
| Contacts | `flutter_contacts` 1.1.9+2 |
| Image picker | `image_picker` 1.0.7 |
| PDF generation | `pdf` + `printing` |
| Encryption | `encrypt` 5.0.3 (AES-256-CBC) |
| Charts | `fl_chart` 0.68.0 |
| Google auth | `google_sign_in` 6.2.1 |
| Google Drive | `googleapis` 13.1.0 + `extension_google_sign_in_as_googleapis_auth` |
| File picker | `file_picker` 8.0.0 |
| Fonts | Google Fonts (Cairo) |
| Localization | Flutter `intl` + ARB files |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, lifecycle hooks, lock overlay
├── l10n.dart                          # Localization barrel
├── l10n/
│   ├── app_ar.arb                     # Arabic strings
│   ├── app_en.arb                     # English strings
│   ├── app_localizations.dart         # Generated delegate
│   ├── app_localizations_ar.dart
│   └── app_localizations_en.dart
│
├── app/
│   ├── router.dart                    # GoRouter config, ShellRoute for bottom nav
│   └── theme.dart                     # AppTheme (dark palette, colors, card styles)
│
├── core/
│   ├── db/
│   │   ├── isar_service.dart          # Isar init + isarProvider
│   │   ├── transaction_utils.dart     # syncOverdueStatus() helper
│   │   └── models/
│   │       ├── person.dart            # Person Isar model
│   │       ├── debt_transaction.dart  # DebtTransaction Isar model (+ attachmentPaths)
│   │       ├── payment.dart           # Payment Isar model (+ attachmentPaths)
│   │       └── enums.dart             # TransactionType, TransactionStatus
│   ├── providers/
│   │   └── locale_provider.dart       # LocaleNotifier (AR/EN toggle, persisted)
│   └── widgets/
│       ├── amount_display.dart        # Currency formatter widget
│       ├── animated_list_item.dart    # Staggered fade+slide animation
│       ├── attachment_section.dart    # Reusable image attachment picker + thumbnail row
│       ├── glass_card.dart            # Glass-morphism card
│       ├── raseed_logo.dart           # App logo (PNG asset)
│       ├── raseed_wordmark.dart       # "رصيد / Raseed" text logo
│       └── status_badge.dart          # Colored status pill
│
├── shared/
│   └── widgets/
│       ├── app_shell.dart             # Bottom navigation shell
│       ├── gradient_card.dart         # Reusable gradient card
│       └── person_avatar.dart         # Circular avatar with initials
│
└── features/
    ├── splash/
    │   └── splash_screen.dart         # Animated splash with logo + tagline
    │
    ├── dashboard/
    │   ├── providers/
    │   │   └── dashboard_provider.dart  # Reactive summary data + overdue sync
    │   └── presentation/
    │       ├── dashboard_screen.dart
    │       └── widgets/
    │           ├── summary_card.dart
    │           ├── person_balance_card.dart
    │           ├── balance_line_chart.dart
    │           ├── debt_loan_chart.dart
    │           └── monthly_bar_chart.dart
    │
    ├── transactions/
    │   ├── usecases/
    │   │   ├── add_transaction.dart   # AddTransactionUseCase (+ attachments)
    │   │   ├── edit_transaction.dart  # EditTransactionUseCase
    │   │   └── record_payment.dart    # RecordPaymentUseCase + deletePayment (+ attachments)
    │   ├── providers/
    │   │   └── transaction_provider.dart  # Riverpod providers (stream-based reactive)
    │   └── presentation/
    │       ├── add_transaction_screen.dart
    │       ├── edit_transaction_screen.dart   # Edit existing transaction
    │       ├── all_transactions_screen.dart
    │       ├── person_transactions_screen.dart  # Per-person list + PDF export button
    │       └── transaction_detail_screen.dart   # Detail, payments, attachments, edit, delete
    │
    ├── contacts/
    │   ├── providers/
    │   │   └── contact_provider.dart  # Flutter Contacts v1 API
    │   └── presentation/
    │       └── contact_picker_widget.dart
    │
    ├── security/
    │   ├── providers/
    │   │   └── security_provider.dart # SecurityNotifier (passcode + biometric + auto-lock)
    │   └── presentation/
    │       ├── lock_screen.dart       # Full-screen lock overlay (biometric + numpad inline)
    │       └── passcode_screen.dart   # Set/change passcode flow
    │
    ├── settings/
    │   └── presentation/
    │       └── settings_screen.dart   # All app settings
    │
    ├── backup/
    │   └── services/
    │       └── backup_service.dart    # AES-256 encrypt/decrypt, local & Google Drive backup
    │
    ├── export/
    │   └── pdf_export_service.dart    # PDF report generation + share
    │
    └── about/
        └── presentation/
            └── about_screen.dart      # App info, developer contacts, privacy statement
```

---

## Data Models

### Person
```dart
@collection
class Person {
  Id id = Isar.autoIncrement;
  String name;
  String? phoneNumber;
  bool isFromContacts;  // true = imported from phone contacts
}
```

### DebtTransaction
```dart
@collection
class DebtTransaction {
  Id id = Isar.autoIncrement;
  final person = IsarLink<Person>();
  TransactionType type;    // debt | loan
  double amount;
  double amountPaid;
  DateTime date;
  DateTime? dueDate;
  String? note;
  List<String> attachmentPaths;  // absolute paths to local image files
  TransactionStatus status;      // active | overdue | settled

  double get remaining => amount - amountPaid;
}
```

### Payment
```dart
@collection
class Payment {
  Id id = Isar.autoIncrement;
  final transaction = IsarLink<DebtTransaction>();
  double amount;
  DateTime date;
  String? note;
  List<String> attachmentPaths;  // absolute paths to local image files
}
```

### Enums
```dart
enum TransactionType { debt, loan }
enum TransactionStatus { active, overdue, settled }
```

---

## Security

| Feature | Detail |
|---|---|
| Passcode | 6-digit PIN stored in `flutter_secure_storage` (encrypted keychain/keystore) |
| Biometrics | Face ID on iOS, Fingerprint on Android; **requires passcode to be set first** |
| Auto-lock | Immediate / 1 min / 5 min / 1 hour / Never |
| Lock overlay | `BackdropFilter` blur overlay rendered above the entire app via `Stack` in `main.dart` |
| Backup encryption | AES-256-CBC; 256-bit key in secure storage; format: `base64(IV):base64(ciphertext)` |

> **Passcode is required before biometrics.** If the user tries to enable biometrics without a passcode, the app prompts them to set one first. Disabling the passcode also automatically disables biometrics.

---

## Backup & Restore

Backup files use the `.rsd` extension and are AES-256-CBC encrypted.

**File naming:** `Raseed_Backup-YYYY-MM-DD_HH-MM-SS.rsd`

**What's included in a backup:**
- All persons, transactions, and payments
- All attachment images (embedded as base64 inside the backup file)

**Export targets:**
- Local file (via directory picker)
- Google Drive (OAuth via `google_sign_in`, uploaded via Drive API v3)
- iCloud Documents directory (iOS only)

**Import sources:**
- Local `.rsd` file (via file picker)
- Google Drive (lists the most recent `Raseed_Backup-*` file)

On restore, attachment images are written back to `{documentsDir}/attachments/` and paths are remapped automatically — backups are fully portable across devices and reinstalls.

Legacy plain-JSON backups are supported via a transparent fallback in `_tryDecryptOrRaw()`.

---

## Attachments

Photos can be attached to both transactions and payments:

- Pick from **camera** or **photo gallery**
- Images are copied to `{documentsDir}/attachments/` on save
- Thumbnails shown inline; tap to view full-screen with pinch-to-zoom
- Attachments are included in encrypted backups and fully restored

**Android permissions required:** `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE` (≤ API 32)
**iOS permissions required:** `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`

---

## Localization

The app supports Arabic (RTL) and English (LTR). Strings live in:

- `lib/l10n/app_ar.arb`
- `lib/l10n/app_en.arb`

Generated via `flutter gen-l10n`. The passcode numpad is always forced to `TextDirection.ltr` so digit order is consistent regardless of locale.

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0
- Android SDK (for Android builds)
- Xcode (for iOS builds)

### Setup

```bash
git clone <repo-url>
cd debt_tracker

# Install dependencies
flutter pub get

# Generate localization + Isar schemas + Riverpod code
dart run build_runner build --delete-conflicting-outputs

flutter run
```

### Build release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Install on connected Android device

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## Platform Notes

### Android
- `MainActivity` extends `FlutterFragmentActivity` (required for `local_auth` biometrics)
- Permissions declared in `AndroidManifest.xml`:
  - `android.permission.USE_BIOMETRIC`
  - `android.permission.USE_FINGERPRINT`
  - `android.permission.READ_CONTACTS`
  - `android.permission.CAMERA`
  - `android.permission.READ_MEDIA_IMAGES`
  - `android.permission.READ_EXTERNAL_STORAGE` (max SDK 32)

### iOS
- `NSFaceIDUsageDescription` in `Info.plist` (required for Face ID)
- `NSContactsUsageDescription` in `Info.plist`
- `NSCameraUsageDescription` in `Info.plist`
- `NSPhotoLibraryUsageDescription` in `Info.plist`

---

## App Identifiers

| Platform | Identifier |
|---|---|
| Android package | `com.mohamme5d.raseed` |
| iOS bundle ID | `com.mohamme5d.raseed` |

---

## Developer

**Mohammed Alsayani**
- Email: Mohammed.alsayani@gmail.com
- Phone / WhatsApp: +966 599 920 993
- X (Twitter): [@Alsayani_mohd](https://x.com/Alsayani_mohd)

---

## Privacy

Raseed does not collect, read, or transmit any of your data. All financial information is stored **locally on your device only** using the Isar embedded database. No analytics, no tracking, no cloud sync unless you explicitly choose to back up via Google Drive.

---

*Made with ❤️ in Saudi Arabia*
