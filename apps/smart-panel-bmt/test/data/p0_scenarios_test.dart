import 'package:flutter_test/flutter_test.dart';
import 'package:smart_panel_bmt/domain/models.dart';
import 'package:smart_panel_bmt/data/mock/mock_repositories.dart'
    show P0Simulation;
import '../helpers.dart';

void main() {
  test('curtain open and close buttons confirm their final position', () {
    final s = createStore();
    addTearDown(s.dispose);
    s.selectProfile('b');
    s.send('curtain', on: true, actor: UserRole.owner);
    s.clock.advance(650);
    expect(s.current.devices.firstWhere((d) => d.id == 'curtain').value, 100);
    s.send('curtain', on: false, actor: UserRole.owner);
    s.clock.advance(650);
    expect(s.current.devices.firstWhere((d) => d.id == 'curtain').value, 0);
  });
  test('changing day/night does not skip or pause an active scenario', () {
    final s = createStore();
    addTearDown(s.dispose);
    s.selectProfile('b');
    s.runScenario(ScenarioId.s5);
    s.clock.advance(1000);
    expect(s.current.plnAvailable, isFalse);
    s.setClock(night: true, speed: 1);
    s.clock.advance(100);
    expect(s.current.plnAvailable, isFalse);
    s.setClock(night: false, speed: 1);
    s.clock.advance(13900);
    expect(s.current.plnAvailable, isTrue);
  });
  test(
    'High circuit disconnection requires risk confirmation and removes gas power',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('c');
      expect(
        s.send('kitchen-circuit', on: false, actor: UserRole.owner).failure,
        CommandFailure.permission,
      );
      s.send(
        'kitchen-circuit',
        on: false,
        actor: UserRole.owner,
        riskConfirmed: true,
      );
      s.clock.advance(650);
      expect(s.current.plnAvailable, isTrue);
      expect(s.current.gasPowered, isFalse);
      expect(
        s.repositories.devices
            .devicesFor(UserRole.owner)
            .firstWhere((d) => d.id == 'kitchen-plug')
            .status,
        DeviceStatus.noPower,
      );
      expect(
        s.send('kitchen-plug', on: true, actor: UserRole.owner).failure,
        CommandFailure.noPower,
      );
      s.send(
        'kitchen-circuit',
        on: true,
        actor: UserRole.owner,
        riskConfirmed: true,
      );
      s.clock.advance(650);
      expect(s.current.gasPowered, isTrue);
    },
  );
  test('Wi-Fi rotation obeys package role and four connection routes', () {
    final s = createStore();
    addTearDown(s.dispose);
    final g = s.repositories.guests;
    g.rotateWifi(UserRole.owner);
    expect(s.current.operation.wifiVersion, 1);
    s.selectProfile('b');
    g.rotateWifi(UserRole.guest);
    expect(s.current.operation.wifiVersion, 1);
    s.setConnection(const DemoConnection(internet: false));
    g.rotateWifi(UserRole.owner);
    expect(s.current.operation.wifiVersion, 2);
    s.setConnection(const DemoConnection(atHome: false, internet: false));
    g.rotateWifi(UserRole.owner);
    s.setConnection(const DemoConnection());
    expect(s.current.operation.wifiVersion, 2);
  });
  test('only owner invites edits and revokes fictional members', () {
    final s = createStore();
    addTearDown(s.dispose);
    final a = s.repositories.access, n = s.current.members.length;
    a.inviteMember(UserRole.family, UserRole.family);
    expect(s.current.members.length, n);
    a.inviteMember(UserRole.family, UserRole.owner);
    final id = s.current.members.last.id;
    a.setMember(id, UserRole.guest, true, UserRole.owner);
    expect(s.current.members.last.role, UserRole.guest);
    a.setMember(id, UserRole.guest, false, UserRole.owner);
    expect(s.current.members.last.active, isFalse);
    a.setMember('owner', UserRole.guest, false, UserRole.owner);
    expect(s.current.members.first.role, UserRole.owner);
  });
  test(
    'energy periods are separate datasets and camera depth follows current tier',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('b');
      final e = s.repositories.energy;
      expect(e.historyFor(UserRole.owner, period: ChartPeriod.week).length, 7);
      expect(
        e.historyFor(UserRole.owner, period: ChartPeriod.month).length,
        25,
      );
      expect(s.repositories.cameras.camerasFor(UserRole.owner).length, 4);
      s.setTier(PackageTier.basic);
      expect(s.repositories.cameras.camerasFor(UserRole.owner).length, 2);
    },
  );
  for (final profile in ['a', 'b', 'c']) {
    for (final scenario in ScenarioId.values) {
      test('$profile ${scenario.name} repeats identical state after reset', () {
        final store = createStore();
        addTearDown(store.dispose);
        store.selectProfile(profile);
        String run() {
          store.runScenario(scenario);
          for (var i = 0; i < 300; i++) {
            store.clock.advance(100);
          }
          final h = store.current;
          expect(h.operation.scenarioRunning, isFalse);
          return '${h.time}|${h.powerKw}|${h.voltage}|${h.devices.map((d) => '${d.id}:${d.status}:${d.value}:${d.source}').join(',')}|${h.commands.map((c) => '${c.id}:${c.deviceId}:${c.phase}:${c.failure}:${c.measuredWatts}').join(',')}|${h.alerts.map((a) => '${a.id}:${a.kind}:${a.time}').join(',')}|${h.history.map((e) => '${e.time}:${e.source}:${e.device}:${e.phase}:${e.action}').join(',')}';
        }

        final first = run();
        expect(run(), first);
      });
    }
  }
  test('S1 respects Basic and confirms Medium AC using measured evidence', () {
    final s = createStore();
    addTearDown(s.dispose);
    s.runScenario(ScenarioId.s1);
    s.clock.advance(7000);
    expect(
      s.current.commands.any(
        (c) => c.deviceId == 'ac' || c.deviceId == 'door-lock',
      ),
      isFalse,
    );
    s.selectProfile('b');
    s.runScenario(ScenarioId.s1);
    for (var i = 0; i < 70; i++) {
      s.clock.advance(100);
    }
    expect(s.current.commandFor('ac')!.measuredWatts, 742);
    expect(
      s.current.devices.firstWhere((d) => d.id == 'door-lock').status,
      DeviceStatus.on,
    );
    expect(s.current.commandFor('door-lock')!.source, EventSource.owner);
  });
  test(
    'S1 missing AC evidence stays unconfirmed at real eight seconds on x10',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('b');
      s.clock.speed = 10;
      s.runScenario(ScenarioId.s1, provideEvidence: false);
      s.clock.advance(300);
      s.clock.advance(7999);
      expect(s.current.commandFor('ac')!.phase, CommandPhase.sent);
      s.clock.advance(1);
      expect(s.current.commandFor('ac')!.phase, CommandPhase.unconfirmed);
      expect(
        s.current.devices.firstWhere((d) => d.id == 'ac').status,
        DeviceStatus.off,
      );
    },
  );
  test(
    'S2 acknowledgement does not clear gas or physically reset High valve',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('c');
      s.runScenario(ScenarioId.s2);
      s.clock.advance(3000);
      expect(s.current.operation.gasDetected, isTrue);
      expect(s.current.operation.gasValveClosed, isTrue);
      expect(s.current.operation.gasActionsApplied, isTrue);
      s.repositories.alerts.acknowledge(
        s.current.alerts.single.id,
        UserRole.owner,
      );
      expect(s.current.operation.gasDetected, isTrue);
      expect(s.current.alerts.single.acknowledged, isTrue);
      s.physicalGasReset();
      expect(s.current.operation.gasValveClosed, isTrue);
      s.normalizeGas();
      expect(s.current.operation.gasDetected, isFalse);
      expect(s.current.operation.gasValveClosed, isTrue);
      s.physicalGasReset();
      expect(s.current.operation.gasValveClosed, isFalse);
      expect(s.current.alerts, isNotEmpty);
    },
  );
  test(
    'S3 High waits for two sources and reopening requires confirmed hold',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('c');
      s.runScenario(ScenarioId.s3);
      s.clock.advance(1000);
      expect(s.current.operation.waterValveClosed, isFalse);
      expect(s.current.alerts.single.level, AlertLevel.important);
      s.clock.advance(3000);
      expect(s.current.operation.waterValveClosed, isTrue);
      expect(s.current.operation.abnormalFlow, isTrue);
      final rejected = s.send('water-valve', on: true, actor: UserRole.owner);
      expect(rejected.failure, CommandFailure.permission);
      s.send(
        'water-valve',
        on: true,
        actor: UserRole.owner,
        riskConfirmed: true,
      );
      s.clock.advance(650);
      expect(s.current.operation.waterValveClosed, isFalse);
      expect(s.current.operation.wetSensor, isTrue);
    },
  );
  test('S4 freezes phone snapshot while local house automation continues', () {
    final s = createStore();
    addTearDown(s.dispose);
    s.runScenario(ScenarioId.s4);
    expect(s.current.connection.path, ConnectionPath.atHome);
    s.clock.advance(5000);
    expect(s.current.connection.path, ConnectionPath.localOffline);
    s.clock.advance(5000);
    expect(s.current.connection.path, ConnectionPath.remote);
    s.clock.advance(5000);
    expect(s.current.connection.path, ConnectionPath.unreachable);
    final time = s.current.time;
    s.wallSwitch('main-light');
    s.clock.advance(4000);
    expect(s.current.time, time);
    s.clock.advance(6000);
    expect(s.current.connection.path, ConnectionPath.atHome);
    expect(
      s.current.devices.firstWhere((d) => d.id == 'main-light').source,
      EventSource.wallSwitch,
    );
  });
  test(
    'S5 battery lock works but mains gate and gas supply are unavailable',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('b');
      s.runScenario(ScenarioId.s5);
      s.clock.advance(1000);
      expect(s.current.plnAvailable, isFalse);
      expect(
        s.repositories.devices
            .devicesFor(UserRole.owner)
            .firstWhere((d) => d.id == 'ac')
            .status,
        DeviceStatus.noPower,
      );
      expect(
        s
            .send(
              'gate-motor',
              on: true,
              actor: UserRole.owner,
              riskConfirmed: true,
            )
            .failure,
        CommandFailure.noPower,
      );
      s.send('door-lock', on: true, actor: UserRole.owner, riskConfirmed: true);
      s.clock.advance(650);
      expect(s.current.commandFor('door-lock')!.phase, CommandPhase.confirmed);
      s.clock.advance(13350);
      expect(s.current.plnAvailable, isTrue);
      expect(
        s.current.alerts.any((a) => a.kind == AlertKind.powerRestored),
        isTrue,
      );
    },
  );
  test('S6 High disconnects heater; Medium retains it outside its package', () {
    final s = createStore();
    addTearDown(s.dispose);
    s.selectProfile('c');
    s.runScenario(ScenarioId.s6);
    s.clock.advance(4000);
    expect(s.current.operation.loadShed, isTrue);
    expect(s.current.voltage, 264);
    expect(
      s.current.devices.firstWhere((d) => d.id == 'water-heater').status,
      DeviceStatus.off,
    );
    s.selectProfile('b');
    s.runScenario(ScenarioId.s6);
    s.clock.advance(4000);
    expect(s.current.operation.loadShed, isFalse);
  });
  test(
    'reset cancels every scenario and pending command without late mutations',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      for (final id in ScenarioId.values) {
        s.runScenario(id);
        s.clock.advance(1200);
        s.reset();
        s.clock.advance(60000);
        expect(s.current.operation.scenario, isNull);
        expect(s.current.alerts, isEmpty);
        expect(s.current.commands, isEmpty);
      }
    },
  );
  test(
    'dimmer AC and curtain values change only after command confirmation',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('b');
      for (final (id, value, delay) in [
        ('main-light', 35.0, 650),
        ('curtain', 90.0, 650),
        ('ac', 22.0, 2200),
      ]) {
        s.send(id, on: true, actor: UserRole.owner, value: value);
        expect(
          s.current.devices.firstWhere((d) => d.id == id).value,
          isNot(value),
        );
        s.clock.advance(delay);
        expect(s.current.devices.firstWhere((d) => d.id == id).value, value);
      }
    },
  );
  test(
    'local schedules continue offline without publishing through frozen snapshot',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.saveScene(
        const ScenePlan(
          SceneId.morning,
          lightsOn: false,
          scheduled: true,
          hour: 14,
          minute: 6,
        ),
        UserRole.owner,
      );
      s.setConnection(const DemoConnection(atHome: false, internet: false));
      final frozen = s.current;
      s.clock.advance(60000);
      s.clock.advance(650);
      expect(s.current.time, frozen.time);
      expect(s.current.history, frozen.history);
      s.setConnection(const DemoConnection());
      expect(
        s.current.devices.firstWhere((d) => d.id == 'main-light').status,
        DeviceStatus.off,
      );
      expect(s.current.commands.last.source, EventSource.automation);
    },
  );
  test(
    'technician access expires and revokes without exposing cameras or locks',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('b');
      final a = s.repositories.access;
      expect(s.repositories.devices.devicesFor(UserRole.technician), isEmpty);
      a.technicianAccess(true, UserRole.owner);
      expect(a.technicianActive(), isTrue);
      expect(
        s.repositories.devices
            .devicesFor(UserRole.technician)
            .any((d) => d.kind == DeviceKind.doorLock),
        isFalse,
      );
      expect(s.repositories.cameras.camerasFor(UserRole.technician), isEmpty);
      s.clock.advance(30 * 60 * 1000);
      expect(a.technicianActive(), isFalse);
      expect(s.repositories.devices.devicesFor(UserRole.technician), isEmpty);
      a.technicianAccess(true, UserRole.owner);
      a.technicianAccess(false, UserRole.owner);
      expect(a.technicianActive(), isFalse);
    },
  );
  test(
    'revoked family loses controls and cameras; only owner manages membership',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('b');
      s.setMember('family', UserRole.family, false, UserRole.family);
      expect(
        s.current.members.firstWhere((m) => m.id == 'family').active,
        isTrue,
      );
      s.setMember('family', UserRole.family, false, UserRole.owner);
      expect(s.repositories.devices.devicesFor(UserRole.family), isEmpty);
      expect(s.repositories.cameras.camerasFor(UserRole.family), isEmpty);
      expect(
        s.send('main-light', on: false, actor: UserRole.family).failure,
        CommandFailure.permission,
      );
    },
  );
  test(
    'camera privacy stops live access logging; rental never returns indoor metadata',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.selectProfile('b');
      s.repositories.cameras.setIndoorPrivacy(true, UserRole.owner);
      final n = s.current.history.length;
      s.repositories.cameras.recordAccess(CameraId.living, UserRole.family);
      expect(s.current.history.length, n);
      s.selectProfile('c');
      expect(
        s.repositories.cameras.camerasFor(UserRole.owner),
        isNot(contains(CameraId.living)),
      );
      s.repositories.cameras.recordAccess(CameraId.living, UserRole.owner);
      expect(s.current.history, isEmpty);
    },
  );
}
