import 'package:flutter_test/flutter_test.dart';
import 'package:smart_panel_bmt/domain/feature_gate.dart';
import 'package:smart_panel_bmt/domain/models.dart';
import '../helpers.dart';

void main() {
  test(
    'C05 local rental codes work offline on Basic and Medium; remote stays High',
    () {
      final store = createStore();
      addTearDown(store.dispose);
      store.selectProfile('c');
      final r = store.repositories.guests;
      for (final tier in [PackageTier.basic, PackageTier.medium]) {
        store.setTier(tier);
        store.setConnection(const DemoConnection(internet: false));
        final code = r.issueCode(
          1,
          store.clock.now,
          store.clock.now.add(const Duration(hours: 2)),
          UserRole.owner,
        );
        expect(code, isNotNull);
        expect(r.canIssueRemoteCode(UserRole.owner), isFalse);
        store.setConnection(const DemoConnection(atHome: false));
        expect(
          r.issueCode(
            1,
            store.clock.now,
            store.clock.now.add(const Duration(days: 1)),
            UserRole.owner,
          ),
          isNull,
        );
        expect(r.checkout(UserRole.owner, riskConfirmed: true), isFalse);
      }
      store.setTier(PackageTier.high);
      expect(r.canIssueRemoteCode(UserRole.owner), isTrue);
      expect(
        r.issueCode(
          2,
          store.clock.now,
          store.clock.now.add(const Duration(days: 1)),
          UserRole.owner,
        ),
        isNotNull,
      );
      for (final role in [
        UserRole.family,
        UserRole.guest,
        UserRole.technician,
      ]) {
        expect(r.codesFor(role), isEmpty);
        expect(r.canIssueCode(role), isFalse);
      }
    },
  );
  test('code windows revocation and physical keypad identity are enforced', () {
    final store = createStore();
    addTearDown(store.dispose);
    store.selectProfile('c');
    final r = store.repositories.guests, now = store.clock.now;
    expect(r.issueCode(1, now, now, UserRole.owner), isNull);
    expect(
      r.issueCode(1, now, now.add(const Duration(days: 31)), UserRole.owner),
      isNull,
    );
    expect(
      r.issueCode(
        1,
        now,
        now.add(const Duration(days: 30, hours: 1)),
        UserRole.owner,
      ),
      isNull,
    );
    final future = r.issueCode(
      1,
      now.add(const Duration(hours: 1)),
      now.add(const Duration(hours: 2)),
      UserRole.owner,
    )!;
    expect(r.useCode(future.id, UserRole.owner, riskConfirmed: true), isFalse);
    final code = r.issueCode(
      2,
      now,
      now.add(const Duration(seconds: 4)),
      UserRole.owner,
    )!;
    expect(r.useCode(code.id, UserRole.owner), isFalse);
    expect(r.useCode(code.id, UserRole.owner, riskConfirmed: true), isTrue);
    expect(store.current.commandFor('door-lock')!.phase, CommandPhase.sent);
    store.setConnection(const DemoConnection(atHome: false, internet: false));
    store.clock.advance(1000);
    store.setConnection(const DemoConnection());
    expect(
      store.current.commandFor('door-lock')!.phase,
      CommandPhase.confirmed,
    );
    expect(store.current.commandFor('door-lock')!.source, EventSource.guest);
    expect(store.current.commandFor('door-lock')!.path, ConnectionPath.atHome);
    expect(
      store.current.history
          .where((e) => e.device == DeviceKind.doorLock)
          .every((e) => e.source == EventSource.guest),
      isTrue,
    );
    store.clock.advance(4000);
    expect(r.useCode(code.id, UserRole.owner, riskConfirmed: true), isFalse);
    expect(store.current.p1.checkedInCode, isNull);
    r.revokeCode(future.id, UserRole.owner);
    expect(r.codesFor(UserRole.owner).first.revoked, isTrue);
  });
  test(
    'checkout reports pending commands before confirmed off and reset cancels everything',
    () {
      final store = createStore();
      addTearDown(store.dispose);
      store.selectProfile('c');
      final r = store.repositories.guests;
      final code = r.issueCode(
        1,
        store.clock.now,
        store.clock.now.add(const Duration(days: 2)),
        UserRole.owner,
      )!;
      r.useCode(code.id, UserRole.owner, riskConfirmed: true);
      store.clock.advance(1000);
      final wifi = store.current.operation.wifiVersion;
      expect(r.checkout(UserRole.owner), isFalse);
      store.setConnection(const DemoConnection(internet: false));
      expect(r.checkout(UserRole.owner, riskConfirmed: true), isFalse);
      store.setConnection(const DemoConnection());
      expect(r.checkout(UserRole.owner, riskConfirmed: true), isTrue);
      expect(store.current.p1.codes.every((c) => c.revoked), isTrue);
      expect(store.current.operation.wifiVersion, wifi + 1);
      final ids = store.current.p1.report!.commandIds;
      expect(
        store.current.commands
            .where((c) => ids.contains(c.id))
            .every((c) => c.phase == CommandPhase.sent),
        isTrue,
      );
      store.clock.advance(3000);
      expect(
        store.current.commands
            .where((c) => ids.contains(c.id))
            .every((c) => c.phase == CommandPhase.confirmed && !c.targetOn),
        isTrue,
      );
      store.reset();
      store.clock.advance(20000);
      expect(store.current.p1.codes, isEmpty);
      expect(store.current.p1.report, isNull);
      expect(store.current.commands, isEmpty);
    },
  );
  test(
    'pairing requires owner, local power and compatibility; cloud is Custom only',
    () {
      final store = createStore();
      addTearDown(store.dispose);
      final r = store.repositories.devices;
      expect(r.compatibility(PairingCandidate.localRelay).local, isTrue);
      expect(r.compatibility(PairingCandidate.cloudRobot).cloud, isTrue);
      expect(
        r.addDevice(PairingCandidate.localRelay, UserRole.family),
        isFalse,
      );
      expect(
        r.addDevice(PairingCandidate.unsupported, UserRole.owner),
        isFalse,
      );
      expect(r.addDevice(PairingCandidate.cloudRobot, UserRole.owner), isFalse);
      store.setConnection(const DemoConnection(internet: false));
      expect(r.addDevice(PairingCandidate.localRelay, UserRole.owner), isTrue);
      expect(r.addDevice(PairingCandidate.localRelay, UserRole.owner), isFalse);
      store.setTier(PackageTier.custom);
      expect(r.addDevice(PairingCandidate.cloudRobot, UserRole.owner), isFalse);
      store.setConnection(const DemoConnection());
      expect(r.addDevice(PairingCandidate.cloudRobot, UserRole.owner), isTrue);
      store.setConnection(const DemoConnection(internet: false));
      expect(
        r
            .devicesFor(UserRole.owner)
            .singleWhere((d) => d.id == 'paired-cloud-robot')
            .status,
        DeviceStatus.unreachable,
      );
      store.reset();
      expect(
        store.current.devices.any((d) => d.id.startsWith('paired-')),
        isFalse,
      );
    },
  );
  test('local humidity automation executes while phone snapshot is frozen', () {
    final store = createStore();
    addTearDown(store.dispose);
    final r = store.repositories.devices;
    r.saveAutomation(
      const AutomationRule(AutomationKind.humidFan, enabled: true),
      UserRole.owner,
    );
    store.setConnection(const DemoConnection(atHome: false, internet: false));
    final time = store.current.time;
    // Establish the sensor condition while local, then let the command finish with the phone away.
    store.setConnection(const DemoConnection(internet: false));
    r.simulateAutomation(AutomationKind.humidFan, UserRole.owner);
    store.setConnection(const DemoConnection(atHome: false, internet: false));
    store.clock.advance(3000);
    expect(store.current.time, time);
    store.setConnection(const DemoConnection());
    expect(
      store.current.devices.singleWhere((d) => d.id == 'exhaust-fan').status,
      DeviceStatus.on,
    );
    expect(
      store.current.commandFor('exhaust-fan')!.source,
      EventSource.automation,
    );
  });
  test(
    'Medium heater schedule runs once per minute locally and respects power',
    () {
      final store = createStore();
      addTearDown(store.dispose);
      store.selectProfile('b');
      final r = store.repositories.devices;
      r.saveAutomation(
        const AutomationRule(
          AutomationKind.scheduledHeater,
          enabled: true,
          hour: 14,
          minute: 5,
        ),
        UserRole.family,
      );
      store.setConnection(const DemoConnection(atHome: false, internet: false));
      store.clock.advance(1000);
      store.clock.advance(1000);
      store.setConnection(const DemoConnection());
      expect(
        store.current.commands
            .where((c) => c.deviceId == 'water-heater')
            .length,
        1,
      );
      expect(
        store.current.commandFor('water-heater')!.phase,
        CommandPhase.confirmed,
      );
      expect(
        const FeatureGate().check(
          Feature.waterHeating,
          PackageTier.basic,
          HouseKind.privateHome,
          UserRole.owner,
        ),
        GateDecision.locked,
      );
    },
  );
  test(
    'timeline privacy and event classification follow camera role and package',
    () {
      final store = createStore();
      addTearDown(store.dispose);
      store.selectProfile('c');
      final r = store.repositories.cameras;
      expect(r.eventsFor(CameraId.living, UserRole.owner), isEmpty);
      for (final role in [UserRole.guest, UserRole.technician]) {
        expect(r.eventsFor(CameraId.gate, role), isEmpty);
      }
      expect(
        r.eventsFor(
          CameraId.gate,
          UserRole.owner,
          filter: CameraEventKind.person,
        ),
        isNotEmpty,
      );
      store.setTier(PackageTier.medium);
      expect(
        r
            .eventsFor(CameraId.gate, UserRole.family)
            .every((e) => e.kind == CameraEventKind.motion),
        isTrue,
      );
      expect(
        r.eventsFor(
          CameraId.gate,
          UserRole.owner,
          filter: CameraEventKind.person,
        ),
        isEmpty,
      );
      store.setTier(PackageTier.basic);
      expect(r.eventsFor(CameraId.gate, UserRole.owner), isEmpty);
    },
  );
  test(
    'S7 chooses outdoor camera, S9 never falsely turns on AC, S10 retains source',
    () {
      final store = createStore();
      addTearDown(store.dispose);
      store.selectProfile('c');
      store.repositories.home.runScenario(ScenarioId.s7);
      store.clock.advance(2000);
      expect(store.current.alerts.last.kind, AlertKind.person);
      expect(store.current.alerts.last.camera, CameraId.gate);
      store.setTier(PackageTier.basic);
      store.repositories.home.runScenario(ScenarioId.s7);
      store.clock.advance(2000);
      expect(store.current.alerts.last.kind, AlertKind.motion);
      store.setTier(PackageTier.medium);
      store.repositories.home.runScenario(ScenarioId.s9);
      store.clock.advance(1000);
      store.clock.advance(7999);
      expect(store.current.commandFor('ac')!.phase, CommandPhase.sent);
      store.clock.advance(1);
      expect(store.current.commandFor('ac')!.phase, CommandPhase.unconfirmed);
      expect(
        store.current.devices.singleWhere((d) => d.id == 'ac').status,
        DeviceStatus.off,
      );
      store.repositories.home.runScenario(ScenarioId.s10);
      store.clock.advance(1000);
      expect(store.current.alerts.last.level, AlertLevel.info);
      expect(store.current.p1.batteryDays, 7);
      expect(
        store.current.devices.singleWhere((d) => d.id == 'door-sensor').status,
        DeviceStatus.lowBattery,
      );
    },
  );
  test(
    'S8 makes codes invalid at checkout, and Stop prevents future checkout',
    () {
      final store = createStore();
      addTearDown(store.dispose);
      store.selectProfile('c');
      store.repositories.home.runScenario(ScenarioId.s8);
      store.clock.advance(3000);
      expect(store.current.p1.checkedInCode, isNotNull);
      store.repositories.home.stopScenario();
      store.clock.advance(20000);
      expect(store.current.p1.report, isNull);
      store.repositories.home.runScenario(ScenarioId.s8);
      for (var i = 0; i < 16; i++) {
        store.clock.advance(1000);
      }
      expect(store.current.p1.report, isNotNull);
      expect(store.current.p1.checkedInCode, isNull);
      expect(store.current.p1.codes.every((c) => c.revoked), isTrue);
      expect(
        store.current.devices
            .where(
              (d) => [
                DeviceKind.mainLight,
                DeviceKind.airConditioner,
              ].contains(d.kind),
            )
            .every((d) => d.status == DeviceStatus.off),
        isTrue,
      );
    },
  );
  test(
    'service contacts tickets and reports enforce roles and reset their session data',
    () {
      final store = createStore();
      addTearDown(store.dispose);
      final r = store.repositories;
      r.access.setSecondContact(true, UserRole.family);
      expect(store.current.p1.secondContact, isFalse);
      r.access.setSecondContact(true, UserRole.owner);
      expect(store.current.p1.secondContact, isTrue);
      r.home.createTicket(ServiceCategory.general, UserRole.guest);
      expect(store.current.p1.tickets, isEmpty);
      r.home.createTicket(ServiceCategory.disruption, UserRole.family);
      expect(store.current.p1.tickets.length, 1);
      expect(r.energy.monthlyReport(UserRole.guest), isNull);
      expect(r.energy.monthlyReport(UserRole.owner)!.byDevice, isEmpty);
      store.reset();
      expect(store.current.p1.tickets, isEmpty);
      expect(store.current.p1.secondContact, isFalse);
    },
  );
}
