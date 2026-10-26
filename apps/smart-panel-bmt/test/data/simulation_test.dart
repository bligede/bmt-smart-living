import 'package:flutter_test/flutter_test.dart';
import 'package:smart_panel_bmt/data/mock/simulation_clock.dart';
import 'package:smart_panel_bmt/domain/models.dart';
import '../helpers.dart';

void main() {
  test('seed and reset reproduce all power samples', () {
    final a = createStore(), b = createStore();
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    for (var i = 0; i < 10; i++) {
      a.clock.advance(2000);
      b.clock.advance(2000);
      expect(a.current.powerKw, b.current.powerKw);
      expect(a.current.voltage, b.current.voltage);
    }
    final history = List.of(a.current.powerHistory);
    a.reset();
    for (var i = 0; i < 10; i++) {
      a.clock.advance(2000);
    }
    expect(a.current.powerHistory, history);
  });
  test(
    'a command is sent immediately and only changes state after confirmation',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      final c = s.repositories.devices.send(
        'reading-light',
        on: true,
        actor: UserRole.owner,
      );
      expect(c.phase, CommandPhase.sent);
      expect(
        s.current.devices.firstWhere((d) => d.id == 'reading-light').status,
        DeviceStatus.off,
      );
      s.clock.advance(649);
      expect(s.current.commandFor('reading-light')!.phase, CommandPhase.sent);
      s.clock.advance(1);
      expect(
        s.current.commandFor('reading-light')!.phase,
        CommandPhase.confirmed,
      );
      expect(
        s.current.devices.firstWhere((d) => d.id == 'reading-light').status,
        DeviceStatus.on,
      );
    },
  );
  test(
    'one-way AC requires measured power and x10 does not shorten its deadline',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.setTier(PackageTier.medium);
      s.setClock(night: false, speed: 10);
      s.repositories.devices.send(
        'ac',
        on: true,
        actor: UserRole.owner,
        provideEvidence: false,
      );
      s.clock.advance(7999);
      expect(s.current.commandFor('ac')!.phase, CommandPhase.sent);
      s.clock.advance(1);
      expect(s.current.commandFor('ac')!.phase, CommandPhase.unconfirmed);
      expect(
        s.current.devices.firstWhere((d) => d.id == 'ac').status,
        DeviceStatus.off,
      );
      s.repositories.devices.send('ac', on: true, actor: UserRole.owner);
      s.clock.advance(2200);
      expect(s.current.commandFor('ac')!.measuredWatts, 742);
      expect(
        s.current.devices.firstWhere((d) => d.id == 'ac').status,
        DeviceStatus.on,
      );
    },
  );
  test('reset cancels old commands and runner steps before reusing IDs', () {
    final s = createStore();
    addTearDown(s.dispose);
    var actions = 0;
    s.runner.run([ScenarioStep(const Duration(seconds: 2), () => actions++)]);
    s.repositories.devices.send(
      'reading-light',
      on: true,
      actor: UserRole.owner,
    );
    s.reset();
    s.clock.advance(10000);
    expect(actions, 0);
    expect(s.current.commands, isEmpty);
    expect(
      s.current.devices.firstWhere((d) => d.id == 'reading-light').status,
      DeviceStatus.off,
    );
  });
  test(
    'outside without internet freezes the last known snapshot until reconnection',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.clock.advance(2000);
      final before = s.current;
      s.setConnection(const DemoConnection(atHome: false, internet: false));
      s.clock.advance(6000);
      expect(s.current.time, before.time);
      expect(s.current.powerKw, before.powerKw);
      expect(s.current.connection.path, ConnectionPath.unreachable);
      s.setConnection(const DemoConnection(atHome: false, internet: true));
      expect(s.current.time.isAfter(before.time), isTrue);
      expect(s.current.powerKw, isNot(before.powerKw));
    },
  );
  test(
    'repository rejects package/role violations and an unconfirmed unlock',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      expect(
        s.repositories.devices
            .send('ac', on: true, actor: UserRole.owner)
            .failure,
        CommandFailure.permission,
      );
      s.selectProfile('c');
      expect(
        s.repositories.devices
            .send('door-lock', on: true, actor: UserRole.owner)
            .failure,
        CommandFailure.permission,
      );
      expect(
        s.repositories.devices
            .send(
              'door-lock',
              on: true,
              actor: UserRole.guest,
              riskConfirmed: true,
            )
            .failure,
        CommandFailure.permission,
      );
      expect(s.repositories.cameras.camerasFor(UserRole.technician), isEmpty);
      expect(
        s.repositories.cameras.camerasFor(UserRole.family),
        isNot(contains(CameraId.living)),
      );
    },
  );
  test(
    'wall switch supersedes pending app command without a false confirmation',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.repositories.devices.send(
        'main-light',
        on: true,
        actor: UserRole.owner,
      );
      s.repositories.devices.wallSwitch('main-light');
      s.clock.advance(1000);
      final d = s.current.devices.firstWhere((d) => d.id == 'main-light');
      expect(d.status, DeviceStatus.off);
      expect(d.source, EventSource.wallSwitch);
      expect(
        s.current.commandFor('main-light')!.phase,
        isNot(CommandPhase.sent),
      );
    },
  );
  test(
    'cloud device reports unreachable offline while local switches still work',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.setTier(PackageTier.custom);
      s.setConnection(const DemoConnection(internet: false));
      final devices = s.repositories.devices.devicesFor(UserRole.owner);
      expect(
        devices.firstWhere((d) => d.cloud).status,
        DeviceStatus.unreachable,
      );
      expect(
        s.repositories.devices
            .send('reading-light', on: true, actor: UserRole.owner)
            .phase,
        CommandPhase.sent,
      );
    },
  );
  test('guest controls are attributed to guest, not to owner', () {
    final s = createStore();
    addTearDown(s.dispose);
    final c = s.repositories.devices.send(
      'main-light',
      on: false,
      actor: UserRole.guest,
    );
    expect(c.source, EventSource.guest);
    s.clock.advance(650);
    expect(
      s.current.devices.firstWhere((d) => d.id == 'main-light').source,
      EventSource.guest,
    );
  });
  test(
    'x10 accelerates scenario steps while the AC evidence deadline stays real',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      s.setClock(night: false, speed: 10);
      var fired = false;
      s.runner.run([
        ScenarioStep(const Duration(seconds: 1), () => fired = true),
      ]);
      s.clock.advance(99);
      expect(fired, isFalse);
      s.clock.advance(1);
      expect(fired, isTrue);
    },
  );
  test(
    'runner executes ordered steps and stop inside a step cancels the remainder',
    () {
      final s = createStore();
      addTearDown(s.dispose);
      final order = <int>[];
      s.runner.run([
        ScenarioStep(const Duration(seconds: 2), () => order.add(2)),
        ScenarioStep(const Duration(seconds: 1), () {
          order.add(1);
          s.runner.stop();
        }),
      ]);
      s.clock.advance(3000);
      expect(order, [1]);
      s.runner.run([
        ScenarioStep(const Duration(seconds: 1), () => order.add(3)),
      ]);
      s.clock.advance(1000);
      expect(order, [1, 3]);
    },
  );
}
