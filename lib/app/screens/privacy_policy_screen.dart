import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_studio/core/constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 12),
                  _PolicySection(
                    title: 'Information We Collect',
                    items: const [
                      'QR Code Content: Data you enter to generate QR codes.',
                      'Scan History: A log of QR codes you scan.',
                      'App Preferences: Theme, color, and scanner settings.',
                    ],
                    note: 'No account, email, or personal info is required.',
                  ),
                  _PolicySection(
                    title: 'How We Use Your Data',
                    items: const [
                      'Display, share, save, and export your QR codes.',
                      'Review previously scanned codes.',
                      'Personalize your experience.',
                    ],
                  ),
                  _PolicySection(
                    title: 'Data Storage & Security',
                    items: const [
                      'All data is stored locally on your device.',
                      'No data is sent to any server or third party.',
                      'You can delete all data anytime from Settings.',
                    ],
                  ),
                  _PolicySection(
                    title: 'Permissions',
                    items: const [
                      'Camera: Used only for real-time QR scanning.',
                      'Internet: Loads fonts and opens URLs you tap.',
                    ],
                    note: 'We do not access contacts, location, SMS, mic, or photos without your action.',
                  ),
                  _PolicySection(
                    title: 'Third-Party Services',
                    items: const [
                      'google_fonts — loads Poppins font from Google CDN.',
                      'url_launcher — opens links in your browser or email.',
                      'share_plus — shares QR codes via system share sheet.',
                    ],
                    note: 'No analytics, ads, or tracking SDKs are used.',
                  ),
                  _PolicySection(
                    title: 'Children\'s Privacy',
                    items: const [
                      'The app does not target children under 13.',
                      'We do not knowingly collect data from children.',
                    ],
                  ),
                  _PolicySection(
                    title: 'Data Deletion',
                    items: const [
                      'Settings \u2192 Data \u2192 Clear All QR Codes',
                      'Settings \u2192 Data \u2192 Clear Scan History',
                      'Uninstall the app to remove all local data.',
                    ],
                  ),
                  _PolicySection(
                    title: 'Changes to This Policy',
                    items: const [
                      'We may update this policy. Changes will be posted here.',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ContactCard(primary: primary),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final List<String> items;
  final String? note;

  const _PolicySection({
    required this.title,
    required this.items,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u2022 ',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withAlpha(180),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (note != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        note!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Color primary;

  const _ContactCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mail_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Have questions about your privacy? Reach out anytime.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: AppConstants.developerEmail,
                queryParameters: {
                  'subject': '${AppConstants.appName} Privacy Policy',
                },
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.email_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.developerEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
