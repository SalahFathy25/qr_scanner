import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_code/app/data/export_import_cubit.dart';
import 'package:qr_code/app/data/qr_cubit.dart';
import 'package:qr_code/app/data/qr_state.dart';
import 'package:qr_code/app/data/scan_history_cubit.dart';
import 'package:qr_code/core/constants/app_constants.dart';
import 'package:qr_code/core/utils/theme/theme_cubit.dart';

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
  bool _defaultGradient = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoLaunchScanner = prefs.getBool(AppConstants.autoLaunchScannerKey) ?? false;
      _vibrateOnScan = prefs.getBool(AppConstants.vibrateOnScanKey) ?? true;
      _defaultColorIndex = prefs.getInt(AppConstants.defaultColorKey) ?? 1;
      _defaultGradient = prefs.getBool(AppConstants.defaultGradientKey) ?? false;
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _appVersion = '${info.version}+${info.buildNumber}');
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) prefs.setBool(key, value);
    if (value is int) prefs.setInt(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSectionHeader(context, 'Appearance', Icons.palette_outlined),
                  const SizedBox(height: 12),
                  _buildThemeSelector(context),
                  const SizedBox(height: 16),
                  _buildDefaultColorPicker(context),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    context,
                    icon: Icons.gradient_rounded,
                    title: 'Default Gradient',
                    subtitle: 'Enable gradient on new QR codes',
                    value: _defaultGradient,
                    onChanged: (v) {
                      setState(() => _defaultGradient = v);
                      _saveSetting(AppConstants.defaultGradientKey, v);
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Scanning', Icons.qr_code_scanner_outlined),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    context,
                    icon: Icons.camera_alt_outlined,
                    title: 'Auto-open Scanner',
                    subtitle: 'Open camera immediately on app start',
                    value: _autoLaunchScanner,
                    onChanged: (v) {
                      setState(() => _autoLaunchScanner = v);
                      _saveSetting(AppConstants.autoLaunchScannerKey, v);
                    },
                  ),
                  _buildSwitchTile(
                    context,
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

                  _buildSectionHeader(context, 'Data', Icons.storage_outlined),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    icon: Icons.delete_sweep_rounded,
                    iconColor: Colors.redAccent,
                    title: 'Clear All QR Codes',
                    subtitle: 'Remove every QR code from your collection',
                    onTap: () => _confirmClearAll(context),
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.history_rounded,
                    iconColor: Colors.orangeAccent,
                    title: 'Clear Scan History',
                    subtitle: 'Remove all scanned QR records',
                    onTap: () => _confirmClearHistory(context),
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.refresh_rounded,
                    iconColor: Colors.blueAccent,
                    title: 'Reset Onboarding',
                    subtitle: 'Show welcome screens again on next launch',
                    onTap: () => _resetOnboarding(context),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Backup', Icons.backup_outlined),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    icon: Icons.file_upload_outlined,
                    iconColor: colorScheme.primary,
                    title: 'Export All',
                    subtitle: 'Save QR codes as a JSON backup file',
                    onTap: () => _exportAll(context),
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.file_download_outlined,
                    iconColor: colorScheme.primary,
                    title: 'Import',
                    subtitle: 'Restore QR codes from a backup file',
                    onTap: () => _importAll(context),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'About', Icons.info_outline_rounded),
                  const SizedBox(height: 12),
                  _buildInfoTile(context, icon: Icons.qr_code_rounded, title: AppConstants.appName, subtitle: 'v$_appVersion'),
                  _buildInfoTile(context, icon: Icons.person_rounded, title: 'Developer', subtitle: 'Salah'),
                  _buildInfoTile(context, icon: Icons.public_rounded, title: 'Country', subtitle: 'Egypt'),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'Links', Icons.link_rounded),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    title: 'Rate the App',
                    subtitle: 'Leave a review on Google Play',
                    onTap: () => _rateApp(context),
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.share_rounded,
                    iconColor: colorScheme.primary,
                    title: 'Share the App',
                    subtitle: 'Tell your friends about QR Studio',
                    onTap: () => _shareApp(context),
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.teal,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _buildActionTile(
                    context,
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _themeOption(context, Icons.settings_suggest_rounded, 'System', ThemeMode.system, themeMode),
          _themeOption(context, Icons.light_mode_rounded, 'Light', ThemeMode.light, themeMode),
          _themeOption(context, Icons.dark_mode_rounded, 'Dark', ThemeMode.dark, themeMode),
        ],
      ),
    );
  }

  Widget _themeOption(BuildContext context, IconData icon, String label, ThemeMode mode, ThemeMode current) {
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
              Icon(icon, size: 22, color: selected ? Colors.white : Colors.grey.shade500),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultColorPicker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
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
              Text('Default QR Color', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppConstants.qrColors[_defaultColorIndex],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(60)),
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
              final selected = i == _defaultColorIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _defaultColorIndex = i);
                  _saveSetting(AppConstants.defaultColorKey, i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: selected ? 3 : 0,
                    ),
                    boxShadow: selected ? [BoxShadow(color: color.withAlpha(100), blurRadius: 8, spreadRadius: 1)] : null,
                  ),
                  child: selected
                      ? const Center(child: Icon(Icons.check_rounded, size: 18, color: Colors.white))
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        value: value,
        activeColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withAlpha(25), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.redAccent), SizedBox(width: 8), Text('Clear All QR Codes')]),
        content: const Text('This will permanently remove all your QR codes. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<QrCubit>().clearAllQrCodes();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: Text('All QR codes cleared'))));
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
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent), SizedBox(width: 8), Text('Clear Scan History')]),
        content: const Text('Remove all scanned QR records?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () {
              context.read<ScanHistoryCubit>().clearHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: Text('Scan history cleared'))));
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _resetOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.onboardingDoneKey);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Onboarding will show on next launch'))),
      );
    }
  }

  void _exportAll(BuildContext context) {
    final cubit = context.read<QrCubit>();
    final state = cubit.state;
    if (state is QrSuccess) {
      final ec = ExportImportCubit();
      ec.exportQrCodes(state.qrCodes);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: Text('Exporting...'))));
    }
  }

  void _importAll(BuildContext context) async {
    final ec = ExportImportCubit();
    final path = await ec.pickJsonFile();
    if (path != null && context.mounted) {
      final codes = await ec.importFromFile(path);
      if (codes != null && codes.isNotEmpty && context.mounted) {
        final add = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Import QR Codes'),
            content: Text('Imported ${codes.length} QR codes.\nAdd them to your collection?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add All')),
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
              gradientStart: code.gradientStart,
              gradientEnd: code.gradientEnd,
              hasLogo: code.hasLogo,
            );
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Center(child: Text('Added ${codes.length} QR codes'))),
            );
          }
        }
      }
    }
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Center(child: Text('Google Play link will open on release'))),
    );
  }

  void _shareApp(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'Check out QR Studio - the best QR code app!'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Center(child: Text('Link copied to clipboard'))),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'QR Studio Privacy Policy\n\n'
            'This app does not collect, store, or share any personal data.\n\n'
            'All QR codes, scan history, and settings are stored locally on your device using SharedPreferences. '
            'No data is transmitted to any server.\n\n'
            'Camera permission is used solely for QR code scanning and no images are captured or stored.\n\n'
            'If you have any questions, please contact the developer.',
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }
}
