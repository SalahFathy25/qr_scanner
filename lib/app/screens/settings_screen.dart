import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_studio/app/data/export_import_cubit.dart';
import 'package:qr_studio/app/data/qr_cubit.dart';
import 'package:qr_studio/app/data/qr_state.dart';
import 'package:qr_studio/app/data/scan_history_cubit.dart';
import 'package:qr_studio/app/screens/privacy_policy_screen.dart';
import 'package:qr_studio/core/constants/app_constants.dart';
import 'package:qr_studio/core/extensions/context_extensions.dart';
import 'package:qr_studio/core/services/storage_service.dart';
import 'package:qr_studio/core/utils/theme/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  bool _autoLaunchScanner = false;
  bool _vibrateOnScan = true;
  int _defaultColorIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = StorageService(
      await SharedPreferences.getInstance(),
    );
    setState(() {
      _autoLaunchScanner =
          storage.getBool(AppConstants.autoLaunchScannerKey);
      _vibrateOnScan =
          storage.getBool(AppConstants.vibrateOnScanKey, defaultValue: true);
      _defaultColorIndex = storage.getInt(AppConstants.defaultColorKey, defaultValue: 1);
    });

    final info = await PackageInfo.fromPlatform();
    setState(() => _appVersion = info.version);
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final storage = StorageService(
      await SharedPreferences.getInstance(),
    );
    if (value is bool) {
      await storage.setBool(key, value);
    } else if (value is int) {
      await storage.setInt(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SettingsHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _SectionHeader(context, 'Appearance', Icons.palette_outlined),
                  const SizedBox(height: 12),
                  _ThemeSelector(),
                  const SizedBox(height: 16),
                  _DefaultColorPicker(
                    defaultColorIndex: _defaultColorIndex,
                    onChanged: (i) {
                      setState(() => _defaultColorIndex = i);
                      _saveSetting(AppConstants.defaultColorKey, i);
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(context, 'Scanning', Icons.qr_code_scanner_outlined),
                  const SizedBox(height: 12),
                  _SettingsSwitchTile(
                    icon: Icons.camera_alt_outlined,
                    title: 'Auto-open Scanner',
                    subtitle: 'Open camera immediately on app start',
                    value: _autoLaunchScanner,
                    onChanged: (v) {
                      setState(() => _autoLaunchScanner = v);
                      _saveSetting(AppConstants.autoLaunchScannerKey, v);
                    },
                  ),
                  _SettingsSwitchTile(
                    icon: Icons.vibration_rounded,
                    title: 'Vibrate on Scan',
                    subtitle: 'Haptic feedback when QR is detected',
                    value: _vibrateOnScan,
                    onChanged: (v) {
                      setState(() => _vibrateOnScan = v);
                      _saveSetting(AppConstants.vibrateOnScanKey, v);
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(context, 'Data', Icons.storage_outlined),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.delete_sweep_rounded,
                    iconColor: Colors.redAccent,
                    title: 'Clear All QR Codes',
                    subtitle: 'Remove every QR code from your collection',
                    onTap: () => _confirmClearAll(context),
                  ),
                  _ActionTile(
                    icon: Icons.history_rounded,
                    iconColor: Colors.orangeAccent,
                    title: 'Clear Scan History',
                    subtitle: 'Remove all scanned QR records',
                    onTap: () => _confirmClearHistory(context),
                  ),
                  _ActionTile(
                    icon: Icons.refresh_rounded,
                    iconColor: Colors.blueAccent,
                    title: 'Reset Onboarding',
                    subtitle: 'Show welcome screens again on next launch',
                    onTap: () => _resetOnboarding(context),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(context, 'Backup', Icons.backup_outlined),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.file_upload_outlined,
                    iconColor: colorScheme.primary,
                    title: 'Export All',
                    subtitle: 'Save QR codes as a JSON backup file',
                    onTap: () => _exportAll(context),
                  ),
                  _ActionTile(
                    icon: Icons.file_download_outlined,
                    iconColor: colorScheme.primary,
                    title: 'Import',
                    subtitle: 'Restore QR codes from a backup file',
                    onTap: () => _importAll(context),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(context, 'About', Icons.info_outline_rounded),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.qr_code_rounded,
                    title: AppConstants.appName,
                    subtitle: 'v$_appVersion',
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(context, 'Links', Icons.link_rounded),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    title: 'Rate the App',
                    subtitle: 'Leave a review on Google Play',
                    onTap: () => _rateApp(context),
                  ),
                  _ActionTile(
                    icon: Icons.share_rounded,
                    iconColor: colorScheme.primary,
                    title: 'Share the App',
                    subtitle: 'Tell your friends about QR Studio',
                    onTap: () => _shareApp(context),
                  ),
                  _ActionTile(
                    icon: Icons.feedback_rounded,
                    iconColor: Colors.lime,
                    title: 'Send Feedback',
                    subtitle: 'Contact the developer with suggestions',
                    onTap: () => _sendFeedback(context),
                  ),
                  _ActionTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.teal,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _ActionTile(
                    icon: Icons.article_outlined,
                    iconColor: Colors.brown,
                    title: 'Open Source Licenses',
                    subtitle: 'Third-party software notices',
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: AppConstants.appName,
                      applicationVersion: _appVersion,
                      applicationLegalese: '\u00a9 2026 Salah. All rights reserved.',
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Clear All QR Codes'),
          ],
        ),
        content: const Text(
          'This will permanently remove all your QR codes. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<QrCubit>().clearAllQrCodes();
              Navigator.pop(ctx);
              context.showSnackBar('All QR codes cleared');
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text('Clear Scan History'),
          ],
        ),
        content: const Text('Remove all scanned QR records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () {
              context.read<ScanHistoryCubit>().clearHistory();
              Navigator.pop(ctx);
              context.showSnackBar('Scan history cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _resetOnboarding(BuildContext context) async {
    final storage = StorageService(await SharedPreferences.getInstance());
    await storage.remove(AppConstants.onboardingDoneKey);
    context.showSnackBar('Onboarding will show on next launch');
  }

  void _exportAll(BuildContext context) {
    final cubit = context.read<QrCubit>();
    final state = cubit.state;
    if (state is QrSuccess) {
      context.read<ExportImportCubit>().exportQrCodes(state.qrCodes);
      context.showSnackBar('Exporting...');
    }
  }

  void _importAll(BuildContext context) async {
    final ec = context.read<ExportImportCubit>();
    final path = await ec.pickJsonFile();
    if (path != null && context.mounted) {
      final codes = await ec.importFromFile(path);
      if (codes != null && codes.isNotEmpty && context.mounted) {
        final add = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Import QR Codes'),
            content: Text(
              'Imported ${codes.length} QR codes.\nAdd them to your collection?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Add All'),
              ),
            ],
          ),
        );
        if (add == true && context.mounted) {
          final qrCubit = context.read<QrCubit>();
          for (final code in codes) {
            qrCubit.addQrCode(
              title: code.title,
              data: code.data,
              category: code.category,
              colorValue: code.colorValue,
            );
          }
          context.showSnackBar('Added ${codes.length} QR codes');
        }
      }
    }
  }

  Future<void> _rateApp(BuildContext context) async {
    final uri = Uri.parse(AppConstants.playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    await Share.share(
      'Check out QR Studio - the best QR code generator and scanner app!\n${AppConstants.playStoreUrl}',
      subject: AppConstants.appName,
    );
  }

  Future<void> _sendFeedback(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.developerEmail,
      queryParameters: {
        'subject': '${AppConstants.appName} Feedback',
        'body': 'App version: $_appVersion\n\n',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            'Settings',
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

class _SectionHeader extends StatelessWidget {
  final BuildContext context;
  final String title;
  final IconData icon;

  const _SectionHeader(this.context, this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _ThemeOption(
            icon: Icons.settings_suggest_rounded,
            label: 'System',
            mode: ThemeMode.system,
            current: themeMode,
          ),
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            mode: ThemeMode.light,
            current: themeMode,
          ),
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            mode: ThemeMode.dark,
            current: themeMode,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeMode mode;
  final ThemeMode current;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.mode,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final selected = mode == current;
    final primary = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<ThemeCubit>().setTheme(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : Colors.grey.shade500,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultColorPicker extends StatelessWidget {
  final int defaultColorIndex;
  final ValueChanged<int> onChanged;

  const _DefaultColorPicker({
    required this.defaultColorIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
              const Icon(Icons.palette_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                'Default QR Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppConstants.qrColors[defaultColorIndex],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withAlpha(60),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(AppConstants.qrColors.length, (i) {
              final color = AppConstants.qrColors[i];
              final selected = i == defaultColorIndex;
              return GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: selected ? 3 : 0,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withAlpha(100),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Center(
                          child: Icon(Icons.check_rounded, size: 18, color: Colors.white),
                        )
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: SwitchListTile(
          secondary: Icon(icon, color: theme.colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          value: value,
          activeColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade400,
            size: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
