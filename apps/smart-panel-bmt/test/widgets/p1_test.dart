import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_panel_bmt/app/biometric.dart';
import 'package:smart_panel_bmt/app/notifications.dart';
import 'package:smart_panel_bmt/app/providers.dart';
import 'package:smart_panel_bmt/app/router.dart';
import 'package:smart_panel_bmt/core/widgets/visuals.dart';
import 'package:smart_panel_bmt/domain/models.dart';
import 'foundation_test.dart' as fixture;

class FakeBiometric implements BiometricConfirmation {
  FakeBiometric(this.result);
  final Future<bool> result;
  int cancellations = 0;
  @override
  Future<bool> confirm(
    String reason, {
    required String title,
    required String cancel,
  }) => result;
  @override
  Future<void> cancel() async {
    cancellations++;
  }
}

class TrackedNotifications extends DemoNotifications {
  int clears = 0;
  @override
  Future<void> clear() async {
    clears++;
    await super.clear();
  }
}

class DeniedNotifications extends TrackedNotifications {
  int attempts = 0;
  @override
  Future<NotificationResult> showAlert({
    required HomeAlert alert,
    required String profileId,
    required DemoConnection connection,
    required String title,
    required String body,
    required String channelName,
  }) async {
    attempts++;
    return NotificationResult.denied;
  }
}

Future<void> tapText(WidgetTester tester, String value) async {
  final f = find.text(value).first;
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/InterVariable.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets(
    'OS notification denial keeps in-app critical acknowledgement usable',
    (tester) async {
      final notifications = DeniedNotifications();
      final (_, container) = await fixture.mount(
        tester,
        notifications: notifications,
      );
      container.read(demoProvider.notifier).previewCritical();
      await tester.pumpAndSettle();
      expect(notifications.attempts, 1);
      expect(find.text('Saya mengerti, tutup'), findsOneWidget);
      await tapText(tester, 'Saya mengerti, tutup');
      expect(
        container.read(demoProvider).home.alerts.single.acknowledged,
        isTrue,
      );
    },
  );
  testWidgets('notification camera targets enforce current profile and role', (
    tester,
  ) async {
    final notifications = TrackedNotifications();
    final (_, container) = await fixture.mount(
      tester,
      profile: 'c',
      notifications: notifications,
    );
    final router = container.read(routerProvider);
    notifications.onOpenCamera!('a', CameraId.gate);
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/');
    notifications.onOpenCamera!('c', CameraId.gate);
    await tester.pumpAndSettle();
    expect(find.text('LIVE'), findsOneWidget);
    container.read(demoProvider.notifier).role(UserRole.guest);
    await tester.pumpAndSettle();
    expect(notifications.clears, 1);
    notifications.onOpenCamera!('c', CameraId.gate);
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(find.text('LIVE'), findsNothing);
  });
  testWidgets('cold notification target opens permitted outdoor live view', (
    tester,
  ) async {
    final notifications = DemoNotifications()
      ..launchCamera = CameraId.gate
      ..launchProfile = 'c';
    final (_, container) = await fixture.mount(
      tester,
      profile: 'c',
      notifications: notifications,
    );
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/camera/gate',
    );
    expect(find.text('LIVE'), findsOneWidget);
  });
  testWidgets(
    'P1 routes remain scrollable in both languages and at 200 percent',
    (tester) async {
      final (_, container) = await fixture.mount(
        tester,
        profile: 'c',
        scale: 2,
      );
      final c = container.read(demoProvider.notifier),
          router = container.read(routerProvider);
      for (final language in ['id', 'en']) {
        c.language(language);
        c.theme(language == 'id' ? ThemeMode.light : ThemeMode.dark);
        for (final path in [
          '/welcome',
          '/rental',
          '/codes',
          '/automations',
          '/add-device',
          '/monthly-report',
          '/service',
          '/second-contact',
          '/timeline/gate',
        ]) {
          router.go(path);
          await tester.pumpAndSettle();
          for (var i = 0; i < 5; i++) {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, -400),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$language $path scroll $i',
            );
          }
        }
      }
    },
  );
  testWidgets(
    'owner issues code with time window; family direct route exposes no code',
    (tester) async {
      final (_, container) = await fixture.mount(tester, profile: 'c');
      final router = container.read(routerProvider);
      router.go('/codes');
      await tester.pumpAndSettle();
      await tapText(tester, 'Terbitkan kode');
      final codes = container.read(demoProvider).home.p1.codes;
      expect(codes.length, 1);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text(codes.single.value), findsOneWidget);
      container.read(demoProvider.notifier).role(UserRole.family);
      await tester.pumpAndSettle();
      expect(find.text(codes.single.value), findsNothing);
      expect(find.text('Anda tidak memiliki akses.'), findsOneWidget);
    },
  );
  testWidgets(
    'guest has bilingual controls command feedback and real guest Wi-Fi QR only',
    (tester) async {
      final (store, container) = await fixture.mount(tester, profile: 'c');
      final c = container.read(demoProvider.notifier);
      c.role(UserRole.guest);
      c.language('en');
      await tester.pumpAndSettle();
      expect(find.text('Lights'), findsOneWidget);
      expect(find.text('Camera'), findsNothing);
      expect(find.text('Settings'), findsNothing);
      await tapText(tester, 'Lights');
      store.clock.advance(700);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -650));
      await tester.pumpAndSettle();
      expect(find.textContaining('BMT-Tamu-Contoh'), findsOneWidget);
      expect(find.textContaining('ContohSaja2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'timeline filters persons and plays using the shared simulation clock',
    (tester) async {
      final (store, container) = await fixture.mount(tester, profile: 'c');
      container.read(routerProvider).go('/timeline/gate');
      await tester.pumpAndSettle();
      await tapText(tester, 'Orang terdeteksi');
      expect(
        find.text('Kendaraan terdeteksi').evaluate().length,
        1,
      ); // Filter chip stays, its event row is removed.
      await tapText(tester, 'Putar');
      store.clock.advance(3000);
      await tester.pumpAndSettle();
      expect(
        find.text('13.25.03'),
        findsNothing,
      ); // Date and WITA share the timestamp line.
      expect(find.textContaining('13.25.03'), findsOneWidget);
      container.read(demoProvider.notifier).tier(PackageTier.basic);
      await tester.pumpAndSettle();
      expect(find.textContaining('13.25.03'), findsNothing);
      expect(find.text('Putar'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('biometric success sends exactly one mock command', (
    tester,
  ) async {
    final (store, container) = await fixture.mount(
      tester,
      profile: 'c',
      biometric: FakeBiometric(Future.value(true)),
    );
    container.read(routerProvider).go('/security');
    await tester.pumpAndSettle();
    await tapText(tester, 'Buka kunci');
    await tapText(tester, 'Konfirmasi biometrik');
    expect(
      store.current.commands.where((c) => c.deviceId == 'door-lock').length,
      1,
    );
    expect(store.current.commandFor('door-lock')!.phase, CommandPhase.sent);
    store.clock.advance(700);
    await tester.pumpAndSettle();
    expect(
      store.current.commandFor('door-lock')!.phase,
      CommandPhase.confirmed,
    );
  });
  testWidgets('biometric cancellation prevents a late command', (tester) async {
    final pending = Completer<bool>(), auth = FakeBiometric(pending.future);
    final (store, container) = await fixture.mount(
      tester,
      profile: 'c',
      biometric: auth,
    );
    container.read(routerProvider).go('/security');
    await tester.pumpAndSettle();
    await tapText(tester, 'Buka kunci');
    await tapText(tester, 'Konfirmasi biometrik');
    await tapText(tester, 'Batal');
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(store.current.commandFor('door-lock'), isNull);
    expect(auth.cancellations, 1);
  });
  testWidgets('unavailable biometrics keep hold confirmation usable', (
    tester,
  ) async {
    final (store, container) = await fixture.mount(
      tester,
      profile: 'c',
      biometric: FakeBiometric(Future.value(false)),
    );
    container.read(routerProvider).go('/security');
    await tester.pumpAndSettle();
    await tapText(tester, 'Buka kunci');
    await tapText(tester, 'Konfirmasi biometrik');
    expect(find.textContaining('Biometrik dibatalkan'), findsOneWidget);
    final button = find.text('Tahan untuk konfirmasi').first;
    await tester.ensureVisible(button);
    final gesture = await tester.startGesture(tester.getCenter(button));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1520));
    await gesture.up();
    await tester.pump();
    expect(store.current.commandFor('door-lock')!.phase, CommandPhase.sent);
    store.clock.advance(700);
    await tester.pumpAndSettle();
  });
  testWidgets(
    'S9 retry keeps missing evidence and S10 reads low battery status',
    (tester) async {
      final (store, container) = await fixture.mount(tester, profile: 'c');
      final c = container.read(demoProvider.notifier);
      c.scenario(ScenarioId.s9);
      expect(container.read(demoProvider).evidence, isFalse);
      c.scenario(ScenarioId.s10);
      store.clock.advance(1000);
      container.read(routerProvider).go('/device/door-sensor');
      await tester.pumpAndSettle();
      expect(find.text('Baterai lemah'), findsOneWidget);
      expect(find.textContaining('7 hari'), findsOneWidget);
      c.profile('a');
      c.reset();
      c.tier(PackageTier.basic);
      c.locked(false);
      container.read(routerProvider).go('/more');
      await tester.pumpAndSettle();
      expect(find.text('Kode akses'), findsNothing);
    },
  );
  testWidgets('notification image is original camera illustration', (
    tester,
  ) async {
    if (!const bool.fromEnvironment('MEDIA')) return;
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder(), canvas = Canvas(recorder);
      const size = Size(640, 360);
      const CameraIllustration().paint(canvas, size);
      canvas.drawRect(
        const Rect.fromLTWH(0, 306, 640, 54),
        Paint()..color = const Color(0xff282828),
      );
      final text = TextPainter(
        text: const TextSpan(
          text: 'SIMULASI · BMT',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, const Offset(18, 319));
      final picture = recorder.endRecording(),
          image = await picture.toImage(640, 360);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File(
        'assets/mock/camera-event.png',
      ).writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
    });
  });
  testWidgets('capture stage4 main screens in two themes', (tester) async {
    if (!const bool.fromEnvironment('CAPTURE')) return;
    final (store, container) = await fixture.mount(tester, profile: 'c');
    final c = container.read(demoProvider.notifier),
        router = container.read(routerProvider);
    final r = container.read(repositoriesProvider).guests;
    final code = r.issueCode(
      1,
      store.clock.now,
      store.clock.now.add(const Duration(days: 2)),
      UserRole.owner,
    )!;
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      c.theme(theme);
      c.language('id');
      for (final (name, path) in [
        ('welcome', '/welcome'),
        ('rental', '/rental'),
        ('codes', '/codes'),
        ('automation', '/automations'),
        ('pairing', '/add-device'),
        ('timeline', '/timeline/gate'),
        ('energy-report', '/monthly-report'),
        ('service', '/service'),
        ('contacts', '/second-contact'),
        ('home', '/'),
        ('electricity', '/foundation/electricity'),
        ('water', '/foundation/water'),
        ('wifi', '/foundation/wifi'),
        ('gas', '/foundation/gas'),
        ('cctv', '/foundation/cctv'),
        ('rooms', '/rooms'),
        ('security', '/security'),
        ('alerts', '/alerts'),
        ('more', '/more'),
        ('settings', '/settings'),
        ('about', '/about'),
        ('scenes', '/scenes'),
        ('members', '/members'),
        ('notifications', '/notifications'),
        ('history', '/history'),
        ('device', '/device/ac'),
        ('live', '/camera/gate'),
      ]) {
        router.go(path);
        await tester.pumpAndSettle();
        if (name == 'codes') {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -440),
          );
          await tester.pumpAndSettle();
        }
        await fixture.capture(tester, 'stage4-$name-${theme.name}');
      }
      c.role(UserRole.guest);
      c.language('en');
      router.go('/');
      await tester.pumpAndSettle();
      await fixture.capture(tester, 'stage4-guest-${theme.name}');
      c.role(UserRole.owner);
    }
    expect(code.value, isNotEmpty);
  });
  testWidgets('render scenario frames for MP4 backups', (tester) async {
    if (!const bool.fromEnvironment('MEDIA')) return;
    final (store, container) = await fixture.mount(tester, profile: 'c');
    final c = container.read(demoProvider.notifier),
        router = container.read(routerProvider);
    for (final scenario in ScenarioId.values) {
      c.reset();
      c.clock(speed: 1);
      c.scenario(scenario);
      final path = switch (scenario) {
        ScenarioId.s1 => '/device/ac',
        ScenarioId.s2 => '/',
        ScenarioId.s3 => '/foundation/water',
        ScenarioId.s4 => '/',
        ScenarioId.s5 => '/foundation/gas',
        ScenarioId.s6 => '/foundation/electricity',
        ScenarioId.s7 => '/alerts',
        ScenarioId.s8 => '/rental',
        ScenarioId.s9 => '/device/ac',
        ScenarioId.s10 => '/device/door-sensor',
      };
      router.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      for (var second = 0; second <= 32; second++) {
        if (second > 0) store.clock.advance(1000);
        if (scenario == ScenarioId.s2 && second == 8) {
          c.acknowledge(store.current.alerts.last.id);
          router.go('/foundation/gas');
        }
        if (scenario == ScenarioId.s2 && second == 14) c.normalizeGas();
        if (scenario == ScenarioId.s2 && second == 20) c.physicalGasReset();
        if (scenario == ScenarioId.s7 && second == 5) router.go('/camera/gate');
        if (scenario == ScenarioId.s7 && second == 12) {
          router.go('/timeline/gate');
        }
        if (scenario == ScenarioId.s8 && second == 1) router.go('/codes');
        if (scenario == ScenarioId.s8 && second == 5) router.go('/security');
        if (scenario == ScenarioId.s8 && second == 10) router.go('/rental');
        if (scenario == ScenarioId.s8 && second >= 13) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -120),
          );
        }
        if (scenario == ScenarioId.s6 && second == 2) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -440),
          );
        }
        if (scenario == ScenarioId.s3 && second == 5) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -320),
          );
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 180));
        // Opt-in media render, not an Android device recording or an integration test.
        if (const bool.fromEnvironment('CAPTURE')) {
          await fixture.capture(
            tester,
            'frames/${scenario.name}/frame-${second.toString().padLeft(3, '0')}',
          );
        }
      }
      expect(tester.takeException(), isNull, reason: scenario.name);
    }
  });
}
