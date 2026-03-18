# Debt Tracker — ديون وقروض

A personal debts and loans tracker built with Flutter. Track who owes you money and who you owe, record partial payments over time, and get a clear picture of your financial relationships — in Arabic or English.

---

## Features

### Core
- **Record debts** (you owe someone) and **loans** (someone owes you)
- **Pick a person** from your phone contacts or type a name manually
- **Partial payments** — record multiple payments against a single transaction over time
- **Auto-settle** — transaction is automatically marked as settled when fully paid
- **Due dates** — set optional due dates with overdue detection
- **Notes** — add optional notes to transactions and individual payments

### Dashboard
- **Summary cards** — total amount you owe (red) vs total owed to you (green)
- **Per-person net balance** — see your overall balance with each person at a glance
- **Reactive updates** — dashboard recalculates instantly using Isar reactive queries (`watchLazy`)

### Animations & UI
- Staggered list entrance animations on every screen
- Animated number counters that count up from zero on load
- Glassmorphism summary cards with backdrop blur
- Animated progress bar fill on transaction detail
- Type selector (Debt / Loan) with smooth color transition
- Save button → loading spinner → success checkmark sequence
- Overdue badge pulse animation
- Settled celebration scale animation
- Page transitions: bottom-up slide for forms, side-slide for detail views
- Hero animations on person avatars across screens

### Localization
- **Arabic by default** with full RTL layout
- **Switch to English** from the Settings screen
- Language preference persisted across app restarts
- Flag animation (🇸🇦 ↔ 🇬🇧) on language toggle
- Cairo font (Google Fonts) for clean Arabic/Latin rendering

### Filtering
- Active transactions
- Settled transactions
- Overdue transactions (past due date and not yet settled)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x, Dart 3 |
| State Management | Riverpod 2 (`riverpod_annotation` + code generation) |
| Local Database | Isar DB 3 (embedded NoSQL, reactive queries) |
| Navigation | GoRouter 13 |
| Localization | flutter_gen ARB files (`flutter_localizations`) |
| Font | Cairo via Google Fonts |
| Contacts | flutter_contacts |
| Persistence | shared_preferences (locale setting) |
| Code Generation | build_runner, isar_generator, riverpod_generator |

---

## Project Structure

```
debt_tracker/
├── codemagic.yaml                          # CI/CD pipeline (see Deployment section)
├── l10n.yaml                               # Localization generation config
├── pubspec.yaml
└── lib/
    ├── main.dart                           # App entry point, Isar init, ProviderScope
    ├── l10n.dart                           # Re-export of generated AppLocalizations
    ├── l10n/
    │   ├── app_ar.arb                      # Arabic translations (default)
    │   └── app_en.arb                      # English translations
    │
    ├── app/
    │   ├── router.dart                     # GoRouter: /, /add-transaction, /transaction/:id, /settings
    │   └── theme.dart                      # Material 3 theme, color constants, Cairo font
    │
    ├── core/
    │   ├── db/
    │   │   ├── isar_service.dart           # Isar singleton, isarServiceProvider, isarProvider
    │   │   └── models/
    │   │       ├── enums.dart              # TransactionType (debt/loan), TransactionStatus (active/settled/overdue)
    │   │       ├── person.dart             # @collection: name, phoneNumber, avatarPath, isFromContacts
    │   │       ├── debt_transaction.dart   # @collection: IsarLink<Person>, amount, amountPaid, dueDate, status
    │   │       └── payment.dart            # @collection: IsarLink<DebtTransaction>, amount, date, note
    │   ├── providers/
    │   │   └── locale_provider.dart        # LocaleNotifier — defaults to 'ar', persists to SharedPreferences
    │   └── widgets/
    │       ├── amount_display.dart         # Formatted currency widget (NumberFormat '#,##0.00')
    │       ├── animated_list_item.dart     # Reusable staggered slide+fade for list items
    │       ├── glass_card.dart             # BackdropFilter blur + gradient overlay card
    │       └── status_badge.dart           # Colored badge: Active (blue) / Settled (green) / Overdue (red)
    │
    └── features/
        ├── dashboard/
        │   ├── providers/
        │   │   └── dashboard_provider.dart # Computes totals + per-person balances reactively
        │   └── presentation/
        │       ├── dashboard_screen.dart   # Main screen with summary cards + person list
        │       └── widgets/
        │           ├── summary_card.dart   # Glassmorphism card with animated counter
        │           └── person_balance_card.dart  # Gradient avatar, Hero tag, animated amount
        │
        ├── transactions/
        │   ├── usecases/
        │   │   ├── add_transaction.dart    # Validate → save DebtTransaction → link Person
        │   │   └── record_payment.dart     # Validate ≤ remaining → save Payment → update amountPaid → auto-settle
        │   ├── providers/
        │   │   └── transaction_provider.dart  # transactionById, paymentsForTransaction, CRUD providers
        │   └── presentation/
        │       ├── add_transaction_screen.dart     # Form: person picker, type toggle, amount, dates, note
        │       └── transaction_detail_screen.dart  # Progress bar, payment list, swipe-delete, settle button
        │
        ├── contacts/
        │   ├── providers/
        │   │   └── contact_provider.dart   # phoneContacts (flutter_contacts), savedPersons, getOrCreatePerson
        │   └── presentation/
        │       └── contact_picker_widget.dart  # Search, phone contacts list, "Add manually" fallback
        │
        └── settings/
            └── presentation/
                └── settings_screen.dart    # Language toggle with animated custom switch + flag swap
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
  String? avatarPath;
  bool isFromContacts;       // true = imported from phone, false = typed manually
}
```

### DebtTransaction
```dart
@collection
class DebtTransaction {
  Id id = Isar.autoIncrement;
  final person = IsarLink<Person>();
  TransactionType type;      // debt (I owe) | loan (they owe me)
  double amount;
  double amountPaid;         // maintained by RecordPayment use case
  DateTime date;
  DateTime? dueDate;
  String? note;
  TransactionStatus status;  // active | settled | overdue

  double get remaining => amount - amountPaid;
  bool get isSettled => remaining <= 0;
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
}
```

### Enums
```dart
enum TransactionType { debt, loan }
enum TransactionStatus { active, settled, overdue }
```

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.10.0` (stable channel)
- Dart SDK `>=3.0.0`
- Xcode (for iOS builds)
- Android Studio / Android SDK (for Android builds)

### Local Setup

```bash
# 1. Clone
git clone https://github.com/Mohamme5d/debt_tracker.git
cd debt_tracker

# 2. Install dependencies
flutter pub get

# 3. Generate localization files (AppLocalizations)
flutter gen-l10n

# 4. Generate Isar schemas + Riverpod providers
dart run build_runner build --delete-conflicting-outputs

# 5. Run
flutter run
```

> **Note:** Steps 3 and 4 must be run after every `git pull` that includes changes to `.arb` files or any `@riverpod`/`@collection` annotated classes.

---

## Localization

The app ships with **Arabic (default)** and **English**. Translation strings live in:

- `lib/l10n/app_ar.arb` — Arabic
- `lib/l10n/app_en.arb` — English

To add a new language:

1. Create `lib/l10n/app_<code>.arb` with the same keys
2. Add the locale to `supportedLocales` in `main.dart`
3. Run `flutter gen-l10n`

The user can toggle language at any time from the **Settings screen**. The choice is saved to `SharedPreferences` and persists across restarts.

---

## CI/CD — Codemagic

Automated builds and store deployments are handled by Codemagic using `codemagic.yaml`.

### Branch → Deployment mapping

| Branch | iOS | Android |
|---|---|---|
| `staging` | TestFlight (beta) | Google Play Internal track |
| `main` | App Store (manual release) | Google Play Production track |

### Build pipeline (both workflows)

```
push to branch
    │
    ├── Decode Android keystore → write key.properties
    ├── flutter pub get
    ├── flutter gen-l10n
    ├── dart run build_runner build --delete-conflicting-outputs
    ├── flutter test
    ├── flutter build appbundle --release   (Android AAB)
    ├── fetch iOS signing via App Store Connect API
    ├── flutter build ipa --release         (iOS IPA)
    │
    ├── [staging]  → TestFlight + Google Play Internal
    └── [main]     → App Store + Google Play Production
```

### Artifacts collected
- `build/app/outputs/bundle/release/*.aab` — Android App Bundle
- `build/ios/ipa/*.ipa` — iOS IPA
- `build/app/outputs/mapping/release/mapping.txt` — ProGuard mapping
- `build/*.dSYM.zip` — iOS debug symbols

### Required Codemagic environment variable groups

Configure these in **Codemagic UI → Teams → Global variables & secrets**:

#### `android_credentials`
| Variable | Description |
|---|---|
| `CM_KEYSTORE` | Base64-encoded `.jks` / `.keystore` file |
| `CM_KEYSTORE_PASSWORD` | Keystore password |
| `CM_KEY_ALIAS` | Key alias |
| `CM_KEY_PASSWORD` | Key password |

To encode your keystore:
```bash
base64 -i your-keystore.jks | pbcopy   # macOS — copies to clipboard
```

#### `ios_credentials`
| Variable | Description |
|---|---|
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID from App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from App Store Connect |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Contents of the `.p8` API key file |
| `CERTIFICATE_PRIVATE_KEY` | RSA private key for code signing certificate |

#### `google_play_credentials`
| Variable | Description |
|---|---|
| `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | JSON key for Google Play service account |

### Android `build.gradle` signing setup

The pipeline writes a `key.properties` file during the build. Make sure your `android/app/build.gradle` reads from it:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias     keystoreProperties['keyAlias']
            keyPassword  keystoreProperties['keyPassword']
            storeFile    keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Notification

Build results (success + failure) are emailed to `mohammed.alsayani@gmail.com`.

---

## App Identifiers

| Platform | Identifier |
|---|---|
| iOS Bundle ID | `com.mohamme5d.debttracker` |
| Android Package | `com.mohamme5d.debt_tracker` |

---

## Dependencies

### Runtime

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management |
| `riverpod_annotation` | ^2.3.5 | Riverpod code generation annotations |
| `isar` | ^3.1.0+1 | Embedded local database |
| `isar_flutter_libs` | ^3.1.0+1 | Isar native libraries |
| `go_router` | ^13.2.0 | Declarative navigation |
| `flutter_contacts` | ^1.1.7+1 | Phone contact picker |
| `intl` | ^0.20.2 | Date/number formatting |
| `permission_handler` | ^11.3.1 | Runtime permissions (contacts) |
| `path_provider` | ^2.1.3 | File system paths for Isar |
| `shared_preferences` | ^2.2.3 | Persist locale setting |
| `google_fonts` | ^6.2.1 | Cairo font (Arabic/Latin) |
| `flutter_localizations` | SDK | RTL support + localization delegates |

### Dev

| Package | Version | Purpose |
|---|---|---|
| `build_runner` | ^2.4.9 | Code generation runner |
| `isar_generator` | ^3.1.0+1 | Generates Isar collection adapters |
| `riverpod_generator` | ^2.3.11 | Generates Riverpod providers |
| `flutter_lints` | ^3.0.0 | Lint rules |

---

## Contributing

1. Fork the repository
2. Create a feature branch off `staging`: `git checkout -b feature/your-feature staging`
3. Commit your changes
4. Push to your fork and open a Pull Request targeting `staging`
5. Once tested via TestFlight / Google Play Internal, it gets merged to `main` for store release

---

## License

MIT License — see [LICENSE](LICENSE) for details.
