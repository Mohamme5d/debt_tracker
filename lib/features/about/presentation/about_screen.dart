import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raseed/l10n/app_localizations.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/raseed_logo.dart';
import '../../../core/widgets/raseed_wordmark.dart';
import '../../../shared/widgets/gradient_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    final messenger = ScaffoldMessenger.of(context);
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(
      const SnackBar(content: Text('تم النسخ / Copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: Text(isAr ? 'عن التطبيق' : 'About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // A. App hero card
          GradientCard(
            child: Column(
              children: [
                const RaseedLogo(size: 80),
                const SizedBox(height: 12),
                const RaseedWordmark(size: 24),
                const SizedBox(height: 8),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تطبيق تتبع الديون والقروض الشخصية',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Personal debt & loan tracker',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // B. Developer section
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text(
              'المطور / Developer',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          GradientCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: AppTheme.primaryColor, size: 20),
                  ),
                  title: const Text('Mohammed Alsayani', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'مطور التطبيق / App Developer',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderDark),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.email_rounded, color: AppTheme.primaryColor, size: 20),
                  ),
                  title: const Text('Mohammed.alsayani@gmail.com', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'البريد الإلكتروني / Email',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.copy_rounded, color: Colors.white.withOpacity(0.4), size: 18),
                    onPressed: () => _copyToClipboard(context, 'Mohammed.alsayani@gmail.com'),
                  ),
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderDark),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_rounded, color: AppTheme.primaryColor, size: 20),
                  ),
                  title: const Text('+966 599 920 993', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'واتساب / WhatsApp',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.copy_rounded, color: Colors.white.withOpacity(0.4), size: 18),
                    onPressed: () => _copyToClipboard(context, '+966 599 920 993'),
                  ),
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderDark),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.alternate_email, color: AppTheme.primaryColor, size: 20),
                  ),
                  title: const Text('@Alsayani_mohd', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'تويتر / X (Twitter)',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.copy_rounded, color: Colors.white.withOpacity(0.4), size: 18),
                    onPressed: () => _copyToClipboard(context, 'https://x.com/Alsayani_mohd'),
                  ),
                ),
              ],
            ),
          ),

          // C. Privacy section
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text(
              'الخصوصية / Privacy',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          GradientCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_rounded, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'بياناتك تبقى على جهازك فقط',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رصيد لا يقرأ بياناتك ولا يرسلها لأي خادم. جميع بياناتك المالية محفوظة محلياً على جهازك فقط ولا يمكن لأحد الوصول إليها.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your data stays on your device only',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Raseed does not read or transmit your data to any server. All your financial data is stored locally on your device and is never accessible by anyone else.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // D. App info section
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text(
              'معلومات التطبيق / App Info',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          GradientCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _infoTile(
                  icon: Icons.code_rounded,
                  title: 'الإصدار / Version',
                  trailing: '1.0.0',
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderDark),
                _infoTile(
                  icon: Icons.build_rounded,
                  title: 'البناء / Build',
                  trailing: '1',
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.borderDark),
                _infoTile(
                  icon: Icons.phone_android_rounded,
                  title: 'المنصة / Platform',
                  trailing: 'iOS & Android',
                ),
              ],
            ),
          ),

          // D. Footer
          const SizedBox(height: 24),
          Text(
            'صُنع بـ \u2764\uFE0F في المملكة العربية السعودية',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
          Text(
            'Made with \u2764\uFE0F in Saudi Arabia',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(
        trailing,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
      ),
    );
  }
}
