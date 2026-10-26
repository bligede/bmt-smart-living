import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_panel_bmt/app/providers.dart';
import 'package:smart_panel_bmt/app/router.dart';
import 'package:smart_panel_bmt/core/widgets/controls.dart';
import 'package:smart_panel_bmt/core/widgets/surfaces.dart';
import 'package:smart_panel_bmt/core/widgets/visuals.dart';
import 'package:smart_panel_bmt/domain/models.dart';
import 'foundation_test.dart' as fixture;

void main() {
  testWidgets('disconnected kitchen socket shows zero current consumption', (
    tester,
  ) async {
    final (store, container) = await fixture.mount(tester, profile: 'b');
    final c = container.read(demoProvider.notifier);
    c.scenario(ScenarioId.s2);
    store.clock.advance(3000);
    c.acknowledge(store.current.alerts.single.id);
    container.read(routerProvider).go('/device/kitchen-plug');
    await tester.pumpAndSettle();
    expect(find.text('Pemakaian: 0 W'), findsOneWidget);
  });
  testWidgets('connection path remains visible across every main tab', (
    tester,
  ) async {
    final (_, container) = await fixture.mount(tester, profile: 'b');
    container
        .read(demoProvider.notifier)
        .connection(atHome: false, internet: true);
    for (final route in ['/', '/rooms', '/security', '/alerts', '/more']) {
      container.read(routerProvider).go(route);
      await tester.pumpAndSettle();
      expect(find.text('Jarak jauh'), findsOneWidget, reason: route);
    }
  });
  testWidgets(
    'camera timestamp advances in seconds and freezes when unreachable',
    (tester) async {
      final (store, container) = await fixture.mount(tester, profile: 'b');
      container.read(routerProvider).go('/camera/frontGate');
      await tester.pumpAndSettle();
      store.clock.advance(2000);
      await tester.pumpAndSettle();
      expect(find.textContaining('14.05.02'), findsOneWidget);
      container
          .read(demoProvider.notifier)
          .connection(atHome: false, internet: false);
      store.clock.advance(4000);
      await tester.pumpAndSettle();
      expect(find.textContaining('14.05.02'), findsOneWidget);
      expect(find.textContaining('14.05.06'), findsNothing);
    },
  );
  testWidgets('More menu and house picker expose retryable review states', (
    tester,
  ) async {
    final (_, container) = await fixture.mount(tester);
    final c = container.read(demoProvider.notifier),
        router = container.read(routerProvider);
    router.go('/more');
    c.condition(ViewCondition.error);
    await tester.pumpAndSettle();
    expect(find.byType(StateMessage), findsOneWidget);
    c.condition(ViewCondition.normal);
    router.go('/');
    await tester.pumpAndSettle();
    c.condition(ViewCondition.error);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rumah Contoh A'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih rumah'), findsOneWidget);
    expect(find.text('Rumah Contoh B'), findsNothing);
    c.condition(ViewCondition.normal);
    await tester.pumpAndSettle();
    expect(find.text('Rumah Contoh B'), findsOneWidget);
  });
  setUpAll(() async {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/InterVariable.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets('P0 details and settings render in English at 200 percent', (
    tester,
  ) async {
    final (_, container) = await fixture.mount(tester, profile: 'b', scale: 2);
    container.read(demoProvider.notifier).language('en');
    final router = container.read(routerProvider);
    for (final path in [
      '/room/living',
      '/device/main-light',
      '/device/ac',
      '/device/curtain',
      '/device/gate-motor',
      '/scenes',
      '/scene/morning',
      '/members',
      '/notifications',
      '/foundation/water',
      '/foundation/gas',
      '/foundation/wifi',
      '/foundation/cctv',
      '/camera/living',
      '/history',
      '/settings',
      '/about',
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: path);
      if (find.byType(ListView).evaluate().isNotEmpty) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -450));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$path scrolled');
      }
    }
  });
  testWidgets(
    'gas acknowledgement keeps emergency status until source normalizes',
    (tester) async {
      final (store, container) = await fixture.mount(tester, profile: 'c');
      final c = container.read(demoProvider.notifier);
      c.scenario(ScenarioId.s2);
      store.clock.advance(3000);
      await tester.pumpAndSettle();
      expect(find.text('Gas terdeteksi di dapur'), findsOneWidget);
      expect(find.text('Saya mengerti, tutup'), findsOneWidget);
      await tester.tap(find.text('Saya mengerti, tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Darurat'), findsOneWidget);
      expect(store.current.operation.gasDetected, isTrue);
      c.normalizeGas();
      await tester.pumpAndSettle();
      expect(find.text('Perlu perhatian'), findsOneWidget);
      c.physicalGasReset();
      await tester.pumpAndSettle();
      expect(find.text('Rumah aman'), findsOneWidget);
    },
  );
  testWidgets('P0 screen conditions are reachable without restarting', (
    tester,
  ) async {
    final (_, container) = await fixture.mount(tester, profile: 'b');
    final c = container.read(demoProvider.notifier),
        router = container.read(routerProvider);
    for (final path in [
      '/room/living',
      '/device/ac',
      '/scenes',
      '/members',
      '/notifications',
    ]) {
      router.go(path);
      for (final condition in [
        ViewCondition.loading,
        ViewCondition.empty,
        ViewCondition.error,
        ViewCondition.normal,
      ]) {
        c.condition(condition);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull, reason: '$path $condition');
      }
    }
  });
  testWidgets('family cannot manage members using a direct route', (
    tester,
  ) async {
    final (_, container) = await fixture.mount(tester, profile: 'b');
    container.read(demoProvider.notifier).role(UserRole.family);
    container.read(routerProvider).go('/members');
    await tester.pumpAndSettle();
    expect(find.text('Berikan akses'), findsNothing);
    expect(find.byType(StateMessage), findsOneWidget);
  });
  testWidgets('rental direct indoor camera route reveals no camera metadata', (
    tester,
  ) async {
    final (_, container) = await fixture.mount(tester, profile: 'c');
    container.read(routerProvider).go('/camera/living');
    await tester.pumpAndSettle();
    expect(find.text('Ruang keluarga'), findsNothing);
    expect(find.text('LIVE'), findsNothing);
    expect(find.byType(StateMessage), findsOneWidget);
  });
  testWidgets('High water valve remains closed until hold completes', (
    tester,
  ) async {
    final (store, container) = await fixture.mount(tester, profile: 'c');
    final c = container.read(demoProvider.notifier);
    c.scenario(ScenarioId.s3);
    store.clock.advance(4000);
    container.read(routerProvider).go('/device/water-valve');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(HoldToConfirm), findsOneWidget);
    var gesture = await tester.startGesture(
      tester.getCenter(find.byType(HoldToConfirm)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(store.current.operation.waterValveClosed, isTrue);
    gesture = await tester.startGesture(
      tester.getCenter(find.byType(HoldToConfirm)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1520));
    await gesture.up();
    store.clock.advance(650);
    await tester.pumpAndSettle();
    expect(store.current.operation.waterValveClosed, isFalse);
    expect(store.current.operation.wetSensor, isTrue);
  });
  testWidgets('scene editing saves actual schedule and actions', (
    tester,
  ) async {
    final (_, container) = await fixture.mount(tester, profile: 'b');
    container.read(routerProvider).go('/scene/morning');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nyalakan lampu'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(container.read(demoProvider).home.scenes.first.lightsOn, isFalse);
  });
  testWidgets('capture P0 and S1-S6 review', (tester) async {
    final (store, container) = await fixture.mount(tester, profile: 'c');
    final c = container.read(demoProvider.notifier),
        router = container.read(routerProvider);
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      c.theme(theme);
      final suffix = theme.name;
      c.reset();
      router.go('/scenes');
      await tester.pumpAndSettle();
      await fixture.capture(tester, 'stage3-scenes-$suffix');
      for (final (id, path, time) in [
        (ScenarioId.s1, '/device/ac', 9000),
        (ScenarioId.s2, '/', 3000),
        (ScenarioId.s3, '/foundation/water', 4000),
        (ScenarioId.s4, '/', 15000),
        (ScenarioId.s5, '/foundation/gas', 1000),
        (ScenarioId.s6, '/foundation/electricity', 4000),
      ]) {
        c.scenario(id);
        for (var n = 0; n < time; n += 100) {
          store.clock.advance(100);
        }
        router.go(path);
        await tester.pumpAndSettle();
        if (id == ScenarioId.s3) {
          await tester.ensureVisible(
            find.text('Dua sumber cocok: sensor basah dan aliran tidak wajar'),
          );
          await tester.pumpAndSettle();
        }
        if (id == ScenarioId.s6) {
          await tester.ensureVisible(find.byType(PowerChart));
          await tester.pumpAndSettle();
        }
        await fixture.capture(tester, 'stage3-${id.name}-$suffix');
        if (id == ScenarioId.s2) {
          c.acknowledge(store.current.alerts.single.id);
          await tester.pumpAndSettle();
        }
      }
      c.reset();
      router.go('/device/ac');
      await tester.pumpAndSettle();
      await fixture.capture(tester, 'stage3-device-$suffix');
      router.go('/members');
      await tester.pumpAndSettle();
      await fixture.capture(tester, 'stage3-members-$suffix');
    }
  });
}
