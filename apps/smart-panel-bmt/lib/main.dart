import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/l10n/generated/app_localizations.dart';
import 'app/notifications.dart';
import 'app/providers.dart';
import 'data/mock/mock_repositories.dart';
import 'domain/models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final json =
      jsonDecode(await rootBundle.loadString('assets/mock/profiles.json'))
          as Map<String, dynamic>;
  final profiles = (json['profiles'] as List)
      .map((p) => HomeProfile.fromJson(p as Map<String, dynamic>))
      .toList();
  final store = MockHomeStore(profiles, seed: json['seed'] as int);
  final preferences = await SharedPreferences.getInstance();
  final notifications = DemoNotifications();
  final strings = lookupAppLocalizations(
    Locale(preferences.getString('language') ?? 'id'),
  );
  await notifications.initialize(
    critical: strings.critical,
    important: strings.important,
    info: strings.info,
  );
  if (profiles.any((p) => p.id == notifications.launchProfile)) {
    store.selectProfile(notifications.launchProfile!);
  }
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Inter',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  store.clock.start();
  runApp(
    ProviderScope(
      overrides: [
        repositoriesProvider.overrideWithValue(store.repositories),
        preferencesProvider.overrideWithValue(preferences),
        notificationsProvider.overrideWithValue(notifications),
      ],
      child: const SmartPanelApp(),
    ),
  );
}
