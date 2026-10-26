import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/demo/emergency_host.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers.dart';
import 'router.dart';
import 'theme.dart';

class SmartPanelApp extends ConsumerWidget {
  const SmartPanelApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(demoProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: bmtTheme(Brightness.light),
      darkTheme: bmtTheme(Brightness.dark),
      themeMode: settings.theme,
      locale: Locale(settings.language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations:
              settings.reduceMotion || MediaQuery.of(context).disableAnimations,
        ),
        child: EmergencyHost(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
