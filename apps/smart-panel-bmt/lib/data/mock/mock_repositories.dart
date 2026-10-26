import 'dart:async';
import 'dart:math';
import '../../domain/feature_gate.dart';
import '../../domain/models.dart';
import '../../domain/repositories.dart';
import 'simulation_clock.dart';
part 'p0_simulation.dart';
part 'p1_simulation.dart';

class _Pending {
  const _Pending(
    this.command,
    this.due,
    this.evidence, {
    this.localHouse = false,
  });
  final bool localHouse;
  final DeviceCommand command;
  final int due;
  final bool evidence;
}

class MockHomeStore {
  MockHomeStore(this.profiles, {this.seed = 25102026, SimulationClock? clock})
    : clock = clock ?? SimulationClock(),
      _random = Random(seed) {
    runner = ScenarioRunner(this.clock);
    _house = _initial(profiles.first);
    _visible = _house;
    _subscription = this.clock.ticks.listen(_tick);
  }
  final List<HomeProfile> profiles;
  final int seed;
  final SimulationClock clock;
  late final ScenarioRunner runner;
  late final StreamSubscription<int> _subscription;
  final _changes = StreamController<HomeSnapshot>.broadcast(sync: true);
  final _gate = const FeatureGate();
  late HomeSnapshot _house, _visible;
  Random _random;
  final List<_Pending> _pending = [];
  int _nextId = 0, _sampleAt = 0;
  String? _scheduledMinute;
  HomeSnapshot get current => _visible;
  Stream<HomeSnapshot> get changes => _changes.stream;

  Repositories get repositories => Repositories(
    home: MockHomeRepository(this),
    devices: MockDeviceRepository(this),
    alerts: MockAlertRepository(this),
    access: MockAccessRepository(this),
    cameras: MockCameraRepository(this),
    energy: MockEnergyRepository(this),
    guests: MockGuestRepository(this),
  );

  HomeSnapshot _initial(HomeProfile p) => HomeSnapshot(
    profile: p,
    tier: p.tier,
    time: clock.now,
    powerKw: p.powerKw,
    voltage: p.voltage,
    todayKwh: p.todayKwh,
    tankPercent: p.tankPercent,
    p1: P1State(events: p.seedEvents),
    scenes: p.seedScenes.isNotEmpty
        ? p.seedScenes
        : const [
            ScenePlan(SceneId.morning),
            ScenePlan(SceneId.night, lightsOn: false, hour: 22),
            ScenePlan(SceneId.guest, curtainOpen: true, hour: 17),
            ScenePlan(SceneId.away, lightsOn: false, hour: 8),
          ],
    members: p.seedMembers.isNotEmpty
        ? p.seedMembers
        : const [
            DemoMember('owner', UserRole.owner),
            DemoMember('family', UserRole.family),
            DemoMember('technician', UserRole.technician, active: false),
          ],
    devices: p.seedDevices.isNotEmpty
        ? p.seedDevices
        : [
            Device(
              id: 'main-light',
              kind: DeviceKind.mainLight,
              room: p.rooms.first,
              capabilities: const {Capability.switchable, Capability.dimmer},
              status: DeviceStatus.on,
              value: 72,
              source: EventSource.wallSwitch,
            ),
            Device(
              id: 'reading-light',
              kind: DeviceKind.readingLight,
              room: p.rooms.first,
              capabilities: const {Capability.switchable},
            ),
            Device(
              id: 'ac',
              kind: DeviceKind.airConditioner,
              room: RoomId.bedroom,
              capabilities: const {Capability.climate},
              oneWay: true,
              value: 24,
            ),
            Device(
              id: 'curtain',
              kind: DeviceKind.curtain,
              room: p.rooms.first,
              capabilities: const {Capability.curtain},
              value: 60,
            ),
            Device(
              id: 'door-lock',
              kind: DeviceKind.doorLock,
              room: RoomId.terrace,
              capabilities: const {Capability.lock},
            ),
            Device(
              id: 'cloud-robot',
              kind: DeviceKind.cloudRobot,
              room: p.rooms.first,
              capabilities: const {Capability.switchable},
              cloud: true,
            ),
          ],
    commands: const [],
    alerts: const [],
    history: const [],
    powerHistory: const [
      .62,
      .74,
      .68,
      1.12,
      1.82,
      1.52,
      1.64,
      2.14,
      2.28,
      1.96,
      1.72,
      1.84,
    ],
  );

  bool roleActive(UserRole role) =>
      role != UserRole.family ||
      _house.members.any((m) => m.role == role && m.active);
  bool powered(Device d) =>
      d.batteryPowered ||
      d.kind == DeviceKind.doorLock ||
      (_house.plnAvailable &&
          (!_house.operation.kitchenCircuitCut ||
              d.room != RoomId.kitchen ||
              d.kind == DeviceKind.kitchenCircuit));
  GateDecision check(Feature feature, UserRole role) => !roleActive(role)
      ? GateDecision.forbidden
      : _gate.check(feature, _house.tier, _house.profile.kind, role);
  bool permitted(Device d, UserRole role) {
    if (role == UserRole.technician || !roleActive(role)) return false;
    if (role == UserRole.guest &&
        !{
          DeviceKind.mainLight,
          DeviceKind.readingLight,
          DeviceKind.airConditioner,
        }.contains(d.kind)) {
      return false;
    }
    return d.feature == null ||
        check(d.feature!, role) == GateDecision.available;
  }

  void _publish({bool force = false}) {
    if (_house.connection.reachable || force) _visible = _house;
    _changes.add(_visible);
  }

  void selectProfile(String id) {
    runner.stop();
    _pending.clear();
    _random = Random(seed);
    clock.reset();
    _sampleAt = 0;
    _nextId = 0;
    _scheduledMinute = null;
    _house = _initial(profiles.firstWhere((p) => p.id == id));
    _publish(force: true);
  }

  void reset() => selectProfile(_house.profile.id);
  void setTier(PackageTier tier) {
    stopScenario();
    _pending.clear();
    _house = _house.copyWith(tier: tier, commands: []);
    _visible = _visible.copyWith(tier: tier, commands: []);
    _publish();
  }

  void setConnection(DemoConnection connection) {
    _house = _house.copyWith(connection: connection);
    if (!connection.reachable) {
      _visible = _visible.copyWith(connection: connection);
      _changes.add(_visible);
    } else {
      _publish();
    }
  }

  void setClock({required bool night, required int speed}) {
    final t = clock.now;
    clock.now = DateTime.utc(
      t.year,
      t.month,
      t.day,
      night ? 12 : 6,
      t.minute,
      t.second,
    );
    clock.speed = speed;
    _house = _house.copyWith(time: clock.now);
    _publish();
  }

  DeviceCommand send(
    String id, {
    required bool on,
    required UserRole actor,
    bool provideEvidence = true,
    bool riskConfirmed = false,
    double? value,
    bool automatic = false,
    EventSource? sourceOverride,
  }) {
    final d = _house.devices.firstWhere((d) => d.id == id);
    final source =
        sourceOverride ??
        (automatic
            ? EventSource.automation
            : actor == UserRole.family
            ? EventSource.family
            : actor == UserRole.guest
            ? EventSource.guest
            : EventSource.owner);
    var command = DeviceCommand(
      id: ++_nextId,
      deviceId: id,
      phase: CommandPhase.sent,
      issuedAt: clock.now,
      source: source,
      targetOn: on,
      targetValue:
          value ??
          (d.capabilities.contains(Capability.curtain)
              ? (on ? 100.0 : 0.0)
              : null),
      path: automatic ? ConnectionPath.atHome : _house.connection.path,
    );
    final failure =
        !permitted(d, actor) ||
            d.capabilities.contains(Capability.sensor) ||
            ((d.capabilities.contains(Capability.lock) ||
                    d.kind == DeviceKind.waterValve ||
                    d.kind == DeviceKind.alarmSiren ||
                    d.kind == DeviceKind.kitchenCircuit ||
                    d.kind == DeviceKind.waterHeater) &&
                !riskConfirmed)
        ? CommandFailure.permission
        : !automatic && !_house.connection.canControl(cloud: d.cloud)
        ? CommandFailure.unreachable
        : !powered(d)
        ? CommandFailure.noPower
        : CommandFailure.none;
    if (failure != CommandFailure.none) {
      command = command.result(CommandPhase.failed, failure: failure);
    } else {
      _supersede(id);
      _pending.add(
        _Pending(
          command,
          clock.realMilliseconds +
              (d.oneWay ? (provideEvidence ? 2200 : 8000) : 650),
          provideEvidence,
          localHouse: automatic,
        ),
      );
    }
    _house = _house.copyWith(
      commands: [..._house.commands, command],
      history: [
        ..._house.history,
        HistoryEvent(
          time: clock.now,
          source: source,
          device: d.kind,
          phase: command.phase,
          targetOn: on,
          path: command.path,
        ),
      ],
    );
    _publish();
    return command;
  }

  void _supersede(String id) {
    final ids = _pending
        .where((p) => p.command.deviceId == id)
        .map((p) => p.command.id)
        .toSet();
    _pending.removeWhere((p) => p.command.deviceId == id);
    _house = _house.copyWith(
      commands: _house.commands
          .map(
            (c) => ids.contains(c.id)
                ? c.result(
                    CommandPhase.failed,
                    failure: CommandFailure.superseded,
                  )
                : c,
          )
          .toList(),
    );
  }

  void wallSwitch(String id) {
    final d = _house.devices.firstWhere((d) => d.id == id);
    if (!d.capabilities.contains(Capability.switchable) || !powered(d)) {
      return;
    }
    _supersede(id);
    _house = _house.copyWith(
      devices: _house.devices
          .map(
            (v) => v.id == id
                ? v.copyWith(
                    status: v.status == DeviceStatus.on
                        ? DeviceStatus.off
                        : DeviceStatus.on,
                    source: EventSource.wallSwitch,
                  )
                : v,
          )
          .toList(),
      history: [
        ..._house.history,
        HistoryEvent(
          time: clock.now,
          source: EventSource.wallSwitch,
          device: d.kind,
          path: ConnectionPath.atHome,
        ),
      ],
    );
    _publish();
  }

  void runScene(SceneId scene, UserRole actor, {bool automatic = false}) {
    if (actor == UserRole.technician ||
        (!automatic && !_house.connection.reachable)) {
      return;
    }
    if (!roleActive(actor)) return;
    final plan = _house.scenes.firstWhere((p) => p.id == scene);
    for (final d in _house.devices.where(
      (d) => d.capabilities.contains(Capability.switchable) && !d.cloud,
    )) {
      if (permitted(d, actor) &&
          !{
            DeviceKind.kitchenPlug,
            DeviceKind.waterHeater,
            DeviceKind.pump,
            DeviceKind.exhaustFan,
            DeviceKind.cloudRobot,
            DeviceKind.kitchenCircuit,
          }.contains(d.kind)) {
        send(d.id, on: plan.lightsOn, actor: actor, automatic: automatic);
      }
    }
    for (final d in _house.devices.where(
      (d) =>
          d.kind == DeviceKind.airConditioner || d.kind == DeviceKind.curtain,
    )) {
      if (permitted(d, actor)) {
        send(
          d.id,
          on: d.kind == DeviceKind.airConditioner
              ? plan.acOn
              : plan.curtainOpen,
          actor: actor,
          value: d.kind == DeviceKind.curtain
              ? (plan.curtainOpen ? 100 : 0)
              : null,
          automatic: automatic,
        );
      }
    }
    _house = _house.copyWith(
      history: [
        ..._house.history,
        HistoryEvent(
          time: clock.now,
          source: automatic
              ? EventSource.automation
              : actor == UserRole.family
              ? EventSource.family
              : actor == UserRole.guest
              ? EventSource.guest
              : EventSource.owner,
          scene: scene,
          path: automatic ? ConnectionPath.atHome : _house.connection.path,
        ),
      ],
    );
    if (actor != UserRole.guest &&
        (scene == SceneId.away || scene == SceneId.night)) {
      armAlarm(true, actor);
    }
    _publish();
  }

  void previewCritical() {
    if (!_house.connection.reachable) return;
    _house = _house.copyWith(
      alerts: [
        ..._house.alerts,
        HomeAlert(
          id: ++_nextId,
          kind: AlertKind.sampleCritical,
          level: AlertLevel.critical,
          time: clock.now,
        ),
      ],
    );
    _publish();
  }

  void acknowledge(int id, UserRole actor) {
    if (!_house.connection.reachable || !roleActive(actor)) return;
    final matches = _house.alerts.where((a) => a.id == id && !a.acknowledged);
    if (matches.isEmpty) return;
    final kind = matches.first.kind;
    _house = _house.copyWith(
      alerts: _house.alerts
          .map((a) => a.id == id ? a.acknowledge() : a)
          .toList(),
    );
    _audit(
      AuditAction.acknowledged,
      alert: kind,
      source: actor == UserRole.family
          ? EventSource.family
          : actor == UserRole.guest
          ? EventSource.guest
          : EventSource.owner,
    );
    _publish();
  }

  void _tick(int milliseconds) {
    var changed = false;
    final due = _pending.where((p) => p.due <= clock.realMilliseconds).toList();
    for (final p in due) {
      _pending.remove(p);
      final d = _house.devices.firstWhere((d) => d.id == p.command.deviceId);
      final failure =
          !p.localHouse && !_house.connection.canControl(cloud: d.cloud)
          ? CommandFailure.unreachable
          : !powered(d)
          ? CommandFailure.noPower
          : !p.evidence
          ? CommandFailure.noEvidence
          : CommandFailure.none;
      final result = p.command.result(
        failure == CommandFailure.none
            ? CommandPhase.confirmed
            : failure == CommandFailure.noEvidence
            ? CommandPhase.unconfirmed
            : CommandPhase.failed,
        failure: failure,
        measuredWatts: d.oneWay && failure == CommandFailure.none
            ? (p.command.targetOn ? 742 : 0)
            : null,
      );
      _house = _house.copyWith(
        commands: _house.commands
            .map((c) => c.id == result.id ? result : c)
            .toList(),
        devices: _house.devices
            .map(
              (v) => v.id == d.id && result.phase == CommandPhase.confirmed
                  ? v.copyWith(
                      status: p.command.targetOn
                          ? DeviceStatus.on
                          : DeviceStatus.off,
                      source: result.source,
                      value: result.targetValue ?? v.value,
                    )
                  : v,
            )
            .toList(),
        history: [
          ..._house.history,
          HistoryEvent(
            time: clock.now,
            source: result.source,
            device: d.kind,
            phase: result.phase,
            targetOn: result.targetOn,
            path: result.path,
          ),
        ],
      );
      changed = true;
      if (result.phase == CommandPhase.confirmed &&
          d.kind == DeviceKind.waterValve) {
        _house = _house.copyWith(
          operation: _house.operation.copyWith(
            waterValveClosed: !p.command.targetOn,
          ),
        );
      }
      if (result.phase == CommandPhase.confirmed &&
          d.kind == DeviceKind.kitchenCircuit) {
        _house = _house.copyWith(
          operation: _house.operation.copyWith(
            kitchenCircuitCut: !p.command.targetOn,
          ),
        );
      }
    }
    tickP0();
    tickP1();
    if (clock.realMilliseconds - _sampleAt >= 2000) {
      _sampleAt = clock.realMilliseconds;
      final power = !_house.plnAvailable
          ? 0.0
          : (_house.powerKw + (_random.nextDouble() - .5) * .16).clamp(.4, 3.2);
      _house = _house.copyWith(
        time: clock.now,
        powerKw: power,
        voltage: !_house.plnAvailable
            ? 0
            : _house.operation.voltageAnomaly
            ? _house.voltage
            : 225 + _random.nextDouble() * 6,
        todayKwh: _house.todayKwh + power * (2 * clock.speed) / 3600,
        powerHistory: [
          ..._house.powerHistory.skip(_house.powerHistory.length >= 24 ? 1 : 0),
          power,
        ],
      );
      changed = true;
    }
    if (changed) _publish();
  }

  void dispose() {
    runner.dispose();
    _subscription.cancel();
    clock.dispose();
    _changes.close();
  }
}

class MockHomeRepository implements HomeRepository {
  MockHomeRepository(this.store);
  final MockHomeStore store;
  @override
  HomeSnapshot get current => store.current;
  @override
  List<HomeProfile> get profiles => List.unmodifiable(store.profiles);
  @override
  Stream<HomeSnapshot> watchHome() => store.changes;
  @override
  void selectProfile(String id) => store.selectProfile(id);
  @override
  void setTier(PackageTier tier) => store.setTier(tier);
  @override
  void setConnection(DemoConnection connection) =>
      store.setConnection(connection);
  @override
  void setClock({required bool night, required int speed}) =>
      store.setClock(night: night, speed: speed);
  @override
  void reset() => store.reset();
  @override
  void runScenario(ScenarioId id, {bool provideEvidence = true}) =>
      store.runScenario(id, provideEvidence: provideEvidence);
  @override
  void stopScenario() => store.stopScenario();
  @override
  void normalizeGas() => store.normalizeGas();
  @override
  void physicalGasReset() => store.physicalGasReset();
  @override
  void testDetector() => store.testDetector();
  @override
  void pairHouse(String profile, UserRole actor) {
    if (actor != UserRole.owner || !store.current.connection.atHome) return;
    store.selectProfile(profile);
    store._house = store._house.copyWith(
      p1: store._house.p1.copyWith(paired: true),
    );
    store._audit(AuditAction.housePaired, source: EventSource.owner);
    store._publish();
  }

  @override
  void createTicket(ServiceCategory category, UserRole actor) =>
      store.createTicket(category, actor);
}

class MockDeviceRepository implements DeviceRepository {
  MockDeviceRepository(this.store);
  final MockHomeStore store;
  @override
  List<Device> devicesFor(UserRole role) => store.current.devices
      .where(
        (d) => role == UserRole.technician
            ? (store.current.operation.technicianUntil?.isAfter(
                        store.clock.now,
                      ) ??
                      false) &&
                  d.kind != DeviceKind.doorLock &&
                  (d.feature == null ||
                      store.check(d.feature!, role) == GateDecision.available)
            : store.permitted(d, role),
      )
      .map(
        (d) => !store.current.connection.canControl(cloud: d.cloud)
            ? d.copyWith(status: DeviceStatus.unreachable)
            : !store.powered(d)
            ? d.copyWith(status: DeviceStatus.noPower)
            : d,
      )
      .toList();
  @override
  DeviceCommand send(
    String deviceId, {
    required bool on,
    required UserRole actor,
    bool provideEvidence = true,
    bool riskConfirmed = false,
    double? value,
  }) => store.send(
    deviceId,
    on: on,
    actor: actor,
    provideEvidence: provideEvidence,
    riskConfirmed: riskConfirmed,
    value: value,
  );
  @override
  void wallSwitch(String deviceId) => store.wallSwitch(deviceId);
  @override
  void runScene(SceneId scene, UserRole actor) => store.runScene(scene, actor);
  @override
  void saveScene(ScenePlan plan, UserRole actor) =>
      store.saveScene(plan, actor);
  @override
  CompatibilityResult compatibility(PairingCandidate candidate) =>
      store.compatibility(candidate);
  @override
  bool addDevice(PairingCandidate candidate, UserRole actor) =>
      store.addDevice(candidate, actor);
  @override
  void saveAutomation(AutomationRule rule, UserRole actor) =>
      store.saveAutomation(rule, actor);
  @override
  void simulateAutomation(AutomationKind kind, UserRole actor) =>
      store.simulateAutomation(kind, actor);
}

class MockAlertRepository implements AlertRepository {
  MockAlertRepository(this.store);
  final MockHomeStore store;
  @override
  List<HomeAlert> alertsFor(UserRole role) =>
      role == UserRole.technician || !store.roleActive(role)
      ? []
      : List.unmodifiable(
          store.current.alerts.where(
            (a) => role != UserRole.guest || a.camera == null,
          ),
        );
  @override
  void acknowledge(int id, UserRole actor) {
    if (actor != UserRole.technician) store.acknowledge(id, actor);
  }

  @override
  void previewCritical() => store.previewCritical();
}

class MockAccessRepository implements AccessRepository {
  MockAccessRepository(this.store);
  final MockHomeStore store;
  @override
  bool canUnlock(UserRole role) =>
      store.check(Feature.doorLock, role) == GateDecision.available &&
      store.current.connection.reachable;
  @override
  void setMember(String id, UserRole role, bool active, UserRole actor) =>
      store.setMember(id, role, active, actor);
  @override
  void inviteMember(UserRole role, UserRole actor) =>
      store.inviteMember(role, actor);
  @override
  void technicianAccess(bool enabled, UserRole actor) =>
      store.technicianAccess(enabled, actor);
  @override
  bool technicianActive() =>
      store.current.operation.technicianUntil?.isAfter(store.clock.now) ??
      false;
  @override
  void armAlarm(bool armed, UserRole actor, {bool riskConfirmed = false}) =>
      store.armAlarm(armed, actor, riskConfirmed: riskConfirmed);
  @override
  void setSecondContact(bool enabled, UserRole actor) {
    if (store.check(Feature.secondContacts, actor) != GateDecision.available ||
        !store.current.connection.reachable) {
      return;
    }
    store._house = store._house.copyWith(
      p1: store._house.p1.copyWith(secondContact: enabled),
    );
    store._audit(AuditAction.contactChanged, source: EventSource.owner);
    store._publish();
  }
}

class MockCameraRepository implements CameraRepository {
  MockCameraRepository(this.store);
  final MockHomeStore store;
  @override
  List<CameraId> camerasFor(UserRole role) => store.current.profile.cameras
      .where(
        (c) =>
            store.roleActive(role) &&
            const FeatureGate().cameraVisible(
              c,
              store.current.profile.kind,
              role,
            ),
      )
      .take(const FeatureGate().cameraLimit(store.current.tier))
      .toList();
  @override
  void recordAccess(CameraId camera, UserRole role) {
    if (!camerasFor(role).contains(camera) ||
        !store.current.connection.reachable ||
        !store.current.plnAvailable ||
        (camera == CameraId.living && store.current.operation.indoorPrivacy)) {
      return;
    }
    store._house = store._house.copyWith(
      history: [
        ...store._house.history,
        HistoryEvent(
          time: store.clock.now,
          camera: camera,
          path: store.current.connection.path,
          action: AuditAction.cameraViewed,
          source: role == UserRole.family
              ? EventSource.family
              : EventSource.owner,
        ),
      ],
    );
    store._publish();
  }

  @override
  void setIndoorPrivacy(bool enabled, UserRole actor) {
    if (store.check(Feature.recording, actor) != GateDecision.available ||
        store.current.profile.kind == HouseKind.rental ||
        !store.current.connection.reachable) {
      return;
    }
    store._house = store._house.copyWith(
      operation: store._house.operation.copyWith(indoorPrivacy: enabled),
    );
    store._publish();
  }

  @override
  List<CameraEvent> eventsFor(
    CameraId camera,
    UserRole role, {
    CameraEventKind? filter,
  }) {
    if (!camerasFor(role).contains(camera) ||
        store.check(Feature.recording, role) != GateDecision.available ||
        (camera == CameraId.living && store.current.operation.indoorPrivacy)) {
      return [];
    }
    final detailed =
        store.check(Feature.personDetection, role) == GateDecision.available;
    if (filter != null && filter != CameraEventKind.motion && !detailed) {
      return [];
    }
    return store.current.p1.events
        .where((e) => e.camera == camera)
        .map(
          (e) => detailed
              ? e
              : CameraEvent(e.id, e.camera, e.time, CameraEventKind.motion),
        )
        .where((e) => filter == null || e.kind == filter)
        .toList()
      ..sort((a, b) => b.time.compareTo(a.time));
  }
}

class MockEnergyRepository implements EnergyRepository {
  MockEnergyRepository(this.store);
  final MockHomeStore store;
  @override
  List<double> historyFor(
    UserRole role, {
    ChartPeriod period = ChartPeriod.day,
  }) => store.check(Feature.energy, role) == GateDecision.available
      ? List.unmodifiable(switch (period) {
          ChartPeriod.day => store.current.powerHistory,
          ChartPeriod.week => store.current.profile.weekKwh,
          ChartPeriod.month => store.current.profile.dailyKwh,
        })
      : [];
  @override
  MonthlyEnergyReport? monthlyReport(UserRole role) =>
      store.check(Feature.energy, role) != GateDecision.available
      ? null
      : MonthlyEnergyReport(
          store.current.time,
          store.current.profile.monthKwh,
          store.current.profile.previousMonthKwh,
          store.check(Feature.applianceRanking, role) != GateDecision.available
              ? {}
              : {
                  DeviceKind.airConditioner: 142,
                  DeviceKind.waterHeater: 68,
                  DeviceKind.mainLight: 34,
                  DeviceKind.kitchenPlug: 24,
                },
        );
}

class MockGuestRepository implements GuestRepository {
  MockGuestRepository(this.store);
  final MockHomeStore store;
  @override
  bool canIssueRemoteCode(UserRole role) =>
      store.current.profile.kind == HouseKind.rental &&
      store.check(Feature.remoteGuestCodes, role) == GateDecision.available &&
      store.current.connection.internet &&
      store.current.connection.reachable;
  @override
  bool canIssueCode(UserRole role) => store.canIssueCode(role);
  @override
  List<AccessCode> codesFor(UserRole role) =>
      store.check(Feature.accessCodes, role) == GateDecision.available
      ? List.unmodifiable(store.current.p1.codes)
      : [];
  @override
  AccessCode? issueCode(
    int guest,
    DateTime from,
    DateTime until,
    UserRole actor,
  ) => store.issueCode(guest, from, until, actor);
  @override
  void revokeCode(int id, UserRole actor) => store.revokeCode(id, actor);
  @override
  bool useCode(int id, UserRole actor, {bool riskConfirmed = false}) =>
      store.useCode(id, actor, riskConfirmed: riskConfirmed);
  @override
  bool checkout(UserRole actor, {bool riskConfirmed = false}) =>
      store.checkout(actor, riskConfirmed: riskConfirmed);
  @override
  void rotateWifi(UserRole actor) {
    if (store.check(Feature.guestWifi, actor) != GateDecision.available ||
        (actor != UserRole.owner && actor != UserRole.family) ||
        !store.current.connection.reachable) {
      return;
    }
    store._house = store._house.copyWith(
      operation: store._house.operation.copyWith(
        wifiVersion: store._house.operation.wifiVersion + 1,
      ),
    );
    store._audit(
      AuditAction.wifiRotated,
      source: actor == UserRole.family ? EventSource.family : EventSource.owner,
    );
    store._publish();
  }
}
