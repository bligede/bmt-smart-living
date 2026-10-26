import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_panel_bmt/app/app.dart';
import 'package:smart_panel_bmt/app/biometric.dart';
import 'package:smart_panel_bmt/app/notifications.dart';
import 'package:smart_panel_bmt/app/l10n/generated/app_localizations.dart';
import 'package:smart_panel_bmt/app/providers.dart';
import 'package:smart_panel_bmt/app/router.dart';
import 'package:smart_panel_bmt/app/theme.dart';
import 'package:smart_panel_bmt/core/widgets/controls.dart';
import 'package:smart_panel_bmt/core/widgets/surfaces.dart';
import 'package:smart_panel_bmt/data/mock/mock_repositories.dart';
import 'package:smart_panel_bmt/domain/models.dart';
import '../helpers.dart';

final _capture = GlobalKey();

Future<(MockHomeStore, ProviderContainer)> mount(
  WidgetTester tester, {
  String profile = 'a',
  double scale = 1,
  BiometricConfirmation? biometric,
  DemoNotifications? notifications,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  final store = createStore();
  store.selectProfile(profile);
  final container = ProviderContainer(
    overrides: [
      repositoriesProvider.overrideWithValue(store.repositories),
      if (biometric != null) biometricProvider.overrideWithValue(biometric),
      if (notifications != null)
        notificationsProvider.overrideWithValue(notifications),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    store.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(key: _capture, child: const SmartPanelApp()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => precacheImage(
      const AssetImage('assets/brand/bmt-m-only.png'),
      tester.element(find.byType(SmartPanelApp)),
    ),
  );
  await tester.pumpAndSettle();
  return (store, container);
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE')) return;
  for (var attempt = 0; attempt < 20; attempt++) {
    final images = tester.widgetList<RawImage>(find.byType(RawImage));
    if (images.every((image) => image.image != null)) break;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  expect(
    tester
        .widgetList<RawImage>(find.byType(RawImage))
        .every((image) => image.image != null),
    isTrue,
  );
  await tester.runAsync(() async {
    final boundary =
        _capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('artifacts/preview')
      ..createSync(recursive: true);
    final file = File('${directory.path}/$name.png');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/InterVariable.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  for (final (profile, name) in [
    ('a', 'Rumah Contoh A'),
    ('b', 'Rumah Contoh B'),
    ('c', 'Villa Contoh'),
  ]) {
    testWidgets(
      'home $profile loads with its profile and five foundation links',
      (tester) async {
        await mount(tester, profile: profile);
        expect(find.text(name), findsOneWidget);
        expect(find.text('Lima fondasi'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('language and theme switch without restarting the session', (
    tester,
  ) async {
    final (_, container) = await mount(tester);
    final controller = container.read(demoProvider.notifier);
    controller.language('en');
    controller.theme(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(find.text('Five foundations'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Five foundations'))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'emergency preview requires acknowledgement and preserves the alert',
    (tester) async {
      final (_, container) = await mount(tester);
      container.read(demoProvider.notifier).previewCritical();
      await tester.pumpAndSettle();
      expect(find.text('Contoh peringatan kritis'), findsOneWidget);
      await tester.tap(find.text('Saya mengerti, tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Saya mengerti, tutup'), findsNothing);
      expect(
        container.read(demoProvider).home.alerts.single.acknowledged,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('five primary views remain scrollable at 200 percent text', (
    tester,
  ) async {
    final (_, container) = await mount(tester, profile: 'b', scale: 2);
    final router = container.read(routerProvider);
    for (final path in [
      '/',
      '/foundation/electricity',
      '/rooms',
      '/security',
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: path);
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$path after scroll');
    }
    container.read(demoProvider.notifier).previewCritical();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'emergency 200%');
  });
  testWidgets('guest and technician cannot keep a direct camera route', (
    tester,
  ) async {
    final (_, container) = await mount(tester, profile: 'b');
    final router = container.read(routerProvider);
    router.go('/camera/living');
    await tester.pumpAndSettle();
    container.read(demoProvider.notifier).role(UserRole.guest);
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang'), findsOneWidget);
    expect(find.text('LIVE'), findsNothing);
    router.go('/camera/living');
    await tester.pumpAndSettle();
    expect(find.text('LIVE'), findsNothing);
    container.read(demoProvider.notifier).role(UserRole.technician);
    await tester.pumpAndSettle();
    expect(find.text('Diagnosa perangkat'), findsOneWidget);
    expect(find.text('LIVE'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('gallery renders every component state', (tester) async {
    final (_, container) = await mount(tester, profile: 'b');
    container.read(routerProvider).go('/gallery');
    await tester.pumpAndSettle();
    for (final condition in ViewCondition.values) {
      container.read(demoProvider.notifier).galleryCondition(condition);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: condition.name);
    }
  });
  testWidgets(
    'every gallery example lays out at standard and 200 percent text',
    (tester) async {
      final (_, container) = await mount(tester, profile: 'b');
      container.read(routerProvider).go('/gallery');
      await tester.pumpAndSettle();
      for (final scale in [1.0, 2.0]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        await tester.pumpAndSettle();
        final dropdown = tester.widget<DropdownButtonFormField<int>>(
          find.byType(DropdownButtonFormField<int>),
        );
        final select = dropdown.onChanged!,
            count =
                tester
                    .widget<DropdownButton<int>>(
                      find.byType(DropdownButton<int>),
                    )
                    .items!
                    .length -
                1;
        for (var i = 0; i < count; i++) {
          select(i);
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.byType(ConditionView),
            300,
            scrollable: find.byType(Scrollable).first,
            maxScrolls: 10,
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'gallery $i scale $scale',
          );
          final scroll = tester.state<ScrollableState>(
            find.byType(Scrollable).first,
          );
          scroll.position.jumpTo(0);
          await tester.pumpAndSettle();
        }
        select(-1);
        await tester.pumpAndSettle();
      }
    },
  );
  testWidgets(
    'hold confirmation cancels when released and fires once after 1.5 seconds',
    (tester) async {
      var confirmed = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          theme: bmtTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(child: HoldToConfirm(onConfirmed: () => confirmed++)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      var gesture = await tester.startGesture(
        tester.getCenter(find.byType(HoldToConfirm)),
      );
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await tester.pump();
      expect(confirmed, 0);
      gesture = await tester.startGesture(
        tester.getCenter(find.byType(HoldToConfirm)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1499));
      expect(confirmed, 0);
      await tester.pump(const Duration(milliseconds: 17));
      expect(confirmed, 1);
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      expect(confirmed, 1);
    },
  );
  testWidgets(
    'hold confirmation stays compact and cancels when the finger moves',
    (tester) async {
      var confirmed = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          theme: bmtTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(child: HoldToConfirm(onConfirmed: () => confirmed++)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(HoldToConfirm)),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump(const Duration(seconds: 2));
      await gesture.up();
      expect(confirmed, 0);
      expect(tester.getSize(find.byType(HoldToConfirm)).height, lessThan(100));
    },
  );
  testWidgets('capture review previews in both themes', (tester) async {
    final (_, container) = await mount(tester, profile: 'b');
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      container.read(demoProvider.notifier).theme(theme);
      container.read(routerProvider).go('/');
      await tester.pumpAndSettle();
      await capture(tester, 'home_${theme.name}');
      container.read(routerProvider).go('/gallery');
      await tester.pumpAndSettle();
      await capture(tester, 'gallery_${theme.name}');
      container.read(routerProvider).go('/foundation/electricity');
      await tester.pumpAndSettle();
      await capture(tester, 'electricity_${theme.name}');
    }
    container.read(demoProvider.notifier).previewCritical();
    await tester.pumpAndSettle();
    await capture(tester, 'emergency_dark');
    expect(tester.takeException(), isNull);
  });
}
