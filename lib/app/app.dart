import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_studio/app/data/custom_category_cubit.dart';
import 'package:qr_studio/app/data/qr_cubit.dart';
import 'package:qr_studio/app/data/scan_history_cubit.dart';
import 'package:qr_studio/app/screens/home.dart';
import 'package:qr_studio/app/screens/onboarding_screen.dart';
import 'package:qr_studio/core/constants/app_constants.dart';
import 'package:qr_studio/core/di/app_bootstrap.dart';
import 'package:qr_studio/core/services/storage_service.dart';
import 'package:qr_studio/core/utils/theme/theme.dart';
import 'package:qr_studio/core/utils/theme/theme_cubit.dart';

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<StorageService>.value(
          value: AppBootstrap.storage,
        ),
        BlocProvider(create: (_) => ThemeCubit(AppBootstrap.storage)),
      ],
      child: const _AppView(),
    );
  }
}

final class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: Apptheme.lightTheme.copyWith(
            textTheme: AppBootstrap.lightGoogleFonts,
          ),
          darkTheme: Apptheme.darkTheme.copyWith(
            textTheme: AppBootstrap.darkGoogleFonts,
          ),
          themeMode: themeMode,
          home: const _AppEntry(),
        );
      },
    );
  }
}

final class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

final class _AppEntryState extends State<_AppEntry> {
  @override
  Widget build(BuildContext context) {
    if (!AppBootstrap.onboardingDone) {
      return OnboardingScreen(onDone: _completeOnboarding);
    }
    return const _HomeWithProviders();
  }

  Future<void> _completeOnboarding() async {
    await AppBootstrap.storage.setBool(AppConstants.onboardingDoneKey, true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _HomeWithProviders()),
    );
  }
}

final class _HomeWithProviders extends StatelessWidget {
  const _HomeWithProviders();

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => QrCubit(storage)),
        BlocProvider(create: (_) => ScanHistoryCubit(storage)),
        BlocProvider(create: (_) => CustomCategoryCubit(storage)),
      ],
      child: const Home(),
    );
  }
}


