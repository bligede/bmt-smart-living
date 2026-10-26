import 'package:flutter_test/flutter_test.dart';
import 'package:smart_panel_bmt/domain/feature_gate.dart';
import 'package:smart_panel_bmt/domain/models.dart';

void main() {
  const gate = FeatureGate();
  test('all five foundations are available on every owner package', () {
    for (final tier in PackageTier.values) {
      for (final feature in [
        Feature.electricity,
        Feature.water,
        Feature.wifi,
        Feature.gas,
        Feature.cctv,
      ]) {
        expect(
          gate.check(feature, tier, HouseKind.privateHome, UserRole.owner),
          GateDecision.available,
          reason: '$tier / $feature',
        );
      }
    }
  });
  test(
    'package depth is independent of the navigation and rental lock exception',
    () {
      expect(
        gate.check(
          Feature.circuits,
          PackageTier.basic,
          HouseKind.privateHome,
          UserRole.owner,
        ),
        GateDecision.locked,
      );
      expect(
        gate.check(
          Feature.circuits,
          PackageTier.medium,
          HouseKind.privateHome,
          UserRole.owner,
        ),
        GateDecision.available,
      );
      expect(
        gate.check(
          Feature.applianceRanking,
          PackageTier.medium,
          HouseKind.privateHome,
          UserRole.owner,
        ),
        GateDecision.locked,
      );
      expect(
        gate.check(
          Feature.waterValve,
          PackageTier.high,
          HouseKind.rental,
          UserRole.owner,
        ),
        GateDecision.available,
      );
      expect(
        gate.check(
          Feature.doorLock,
          PackageTier.basic,
          HouseKind.rental,
          UserRole.owner,
        ),
        GateDecision.available,
      );
      expect(
        gate.check(
          Feature.doorLock,
          PackageTier.basic,
          HouseKind.privateHome,
          UserRole.owner,
        ),
        GateDecision.locked,
      );
    },
  );
  test('roles override even the highest package and rental exception', () {
    for (final tier in PackageTier.values) {
      for (final kind in HouseKind.values) {
        for (final role in [UserRole.guest, UserRole.technician]) {
          expect(
            gate.check(Feature.cctv, tier, kind, role),
            GateDecision.forbidden,
          );
          expect(
            gate.check(Feature.doorLock, tier, kind, role),
            GateDecision.forbidden,
          );
          expect(
            gate.check(Feature.accessCodes, tier, kind, role),
            GateDecision.forbidden,
          );
        }
        expect(
          gate.check(Feature.cctv, tier, kind, UserRole.family),
          GateDecision.available,
        );
        expect(
          gate.check(Feature.members, tier, kind, UserRole.family),
          GateDecision.forbidden,
        );
      }
    }
  });
  test(
    'four connection cells control local/cloud commands and phone notifications',
    () {
      for (final atHome in [true, false]) {
        for (final internet in [true, false]) {
          final c = DemoConnection(atHome: atHome, internet: internet);
          expect(c.canControl(cloud: false), atHome || internet);
          expect(c.canControl(cloud: true), internet);
          expect(c.phoneNotificationsAvailable, internet);
        }
      }
    },
  );
  test('rental camera filtering never includes an indoor camera', () {
    for (final role in UserRole.values) {
      expect(
        gate.cameraVisible(CameraId.living, HouseKind.rental, role),
        isFalse,
      );
    }
    expect(
      gate.cameraVisible(
        CameraId.living,
        HouseKind.privateHome,
        UserRole.family,
      ),
      isTrue,
    );
  });
}
