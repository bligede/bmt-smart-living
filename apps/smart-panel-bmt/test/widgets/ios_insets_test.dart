import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_panel_bmt/app/router.dart';
import 'foundation_test.dart' as fixture;

void main() {
  testWidgets(
    'iPhone scroll viewports stay above the Home indicator',
    (tester) async {
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(() {
        tester.view.resetPadding();
        tester.view.resetViewPadding();
      });
      final (_, container) = await fixture.mount(tester);
      final router = container.read(routerProvider);
      for (final route in ['/welcome', '/foundation/electricity', '/gallery']) {
        router.go(route);
        await tester.pumpAndSettle();
        final viewport = find.byType(ListView).first;
        expect(
          tester.getRect(viewport).bottom,
          lessThanOrEqualTo(800 - 34),
          reason: route,
        );
        await tester.drag(viewport, const Offset(0, -5000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: route);
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
