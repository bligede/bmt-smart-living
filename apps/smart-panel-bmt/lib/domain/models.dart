part 'p1_models.dart';

enum PackageTier { basic, medium, high, custom }

enum HouseKind { privateHome, rental }

enum UserRole { owner, family, guest, technician }

enum ConnectionPath { atHome, localOffline, remote, unreachable }

enum ViewCondition { normal, pressed, disabled, loading, empty, error, locked }

enum Foundation { electricity, water, wifi, gas, cctv }

enum Feature {
  electricity,
  water,
  wifi,
  gas,
  cctv,
  circuits,
  applianceRanking,
  waterZones,
  waterValve,
  guestWifi,
  guestRotation,
  gasActions,
  gasValve,
  recording,
  personDetection,
  climate,
  curtains,
  doorLock,
  gate,
  alarm,
  members,
  energy,
  accessCodes,
  remoteGuestCodes,
  cloudDevice,
  automations,
  addDevice,
  rental,
  rentalReset,
  service,
  secondContacts,
  waterHeating,
}

enum GateDecision { available, locked, forbidden }

enum Capability { switchable, dimmer, climate, curtain, lock, sensor, camera }

enum DeviceKind {
  mainLight,
  readingLight,
  airConditioner,
  curtain,
  doorLock,
  cloudRobot,
  porchLight,
  gateMotor,
  alarmSiren,
  waterValve,
  pump,
  kitchenPlug,
  exhaustFan,
  waterHeater,
  doorSensor,
  leakSensor,
  kitchenCircuit,
}

enum DeviceStatus { on, off, unreachable, noPower, lowBattery, attention }

enum CommandPhase { sent, confirmed, failed, unconfirmed }

enum CommandFailure {
  none,
  unreachable,
  noPower,
  noEvidence,
  permission,
  superseded,
}

enum EventSource { owner, family, guest, wallSwitch, automation, demo }

enum AlertLevel { critical, important, info }

enum AlertKind {
  sampleCritical,
  voltage,
  lowBattery,
  gasLeak,
  waterLeak,
  powerOutage,
  powerRestored,
  loadShed,
  detectorTest,
  motion,
  person,
}

enum ScenarioId { s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 }

enum AuditAction {
  acknowledged,
  gasDetected,
  gasActions,
  gasValveClosed,
  gasNormal,
  physicalReset,
  waterDetected,
  waterValveClosed,
  powerLost,
  powerRestored,
  voltageAnomaly,
  loadShed,
  memberChanged,
  technicianGranted,
  technicianRevoked,
  sceneEdited,
  alarmArmed,
  alarmDisarmed,
  cameraViewed,
  codeIssued,
  codeRevoked,
  codeUsed,
  checkedOut,
  wifiRotated,
  deviceAdded,
  automationChanged,
  automationRan,
  ticketCreated,
  contactChanged,
  housePaired,
}

enum RoomId {
  living,
  bedroom,
  kitchen,
  bathroom,
  terrace,
  bedroomTwo,
  carport,
  gate,
}

enum CameraId { frontGate, carport, terrace, living, gate }

enum SceneId { morning, night, guest, away }

enum ChartPeriod { day, week, month }

class DemoConnection {
  const DemoConnection({this.atHome = true, this.internet = true});
  final bool atHome;
  final bool internet;
  ConnectionPath get path => atHome
      ? (internet ? ConnectionPath.atHome : ConnectionPath.localOffline)
      : (internet ? ConnectionPath.remote : ConnectionPath.unreachable);
  bool get reachable => path != ConnectionPath.unreachable;
  bool canControl({required bool cloud}) => reachable && (!cloud || internet);
  bool get phoneNotificationsAvailable => reachable && internet;
}

class HomeProfile {
  const HomeProfile({
    required this.id,
    required this.tier,
    required this.kind,
    required this.hasTank,
    required this.rooms,
    required this.cameras,
    required this.powerKw,
    required this.voltage,
    required this.todayKwh,
    required this.monthKwh,
    required this.tankPercent,
    required this.waterLitres,
    required this.wifiDevices,
    this.seedDevices = const [],
    this.seedScenes = const [],
    this.seedMembers = const [],
    this.weekKwh = const [],
    this.dailyKwh = const [],
    this.previousMonthKwh = 345,
    this.seedEvents = const [],
  });
  final String id;
  final PackageTier tier;
  final HouseKind kind;
  final bool hasTank;
  final List<RoomId> rooms;
  final List<CameraId> cameras;
  final double powerKw, voltage, todayKwh, monthKwh;
  final int tankPercent, waterLitres, wifiDevices;
  final List<Device> seedDevices;
  final List<ScenePlan> seedScenes;
  final List<DemoMember> seedMembers;
  final List<double> weekKwh, dailyKwh;
  final double previousMonthKwh;
  final List<CameraEvent> seedEvents;
  factory HomeProfile.fromJson(Map<String, dynamic> j) => HomeProfile(
    id: j['id'] as String,
    tier: PackageTier.values.byName(j['tier'] as String),
    kind: j['kind'] == 'rental' ? HouseKind.rental : HouseKind.privateHome,
    hasTank: j['hasTank'] as bool,
    rooms: (j['rooms'] as List)
        .map((v) => RoomId.values.byName(v as String))
        .toList(),
    cameras: (j['cameras'] as List)
        .map((v) => CameraId.values.byName(v as String))
        .toList(),
    powerKw: (j['powerKw'] as num).toDouble(),
    voltage: (j['voltage'] as num).toDouble(),
    todayKwh: (j['todayKwh'] as num).toDouble(),
    monthKwh: (j['monthKwh'] as num).toDouble(),
    tankPercent: j['tankPercent'] as int,
    waterLitres: j['waterLitres'] as int,
    wifiDevices: j['wifiDevices'] as int,
    previousMonthKwh: (j['previousMonthKwh'] as num? ?? 345).toDouble(),
    seedEvents: ((j['cameraEvents'] as List?) ?? [])
        .map(
          (v) => CameraEvent(
            v['id'] as int,
            CameraId.values.byName(v['camera'] as String),
            DateTime.parse(v['time'] as String),
            CameraEventKind.values.byName(v['kind'] as String),
          ),
        )
        .toList(),
    seedScenes: ((j['scenes'] as List?) ?? [])
        .map((v) => ScenePlan.fromJson(v as Map<String, dynamic>))
        .toList(),
    seedMembers: ((j['members'] as List?) ?? [])
        .map(
          (v) => DemoMember(
            v['id'] as String,
            UserRole.values.byName(v['role'] as String),
            active: v['active'] as bool,
          ),
        )
        .toList(),
    weekKwh: ((j['weekKwh'] as List?) ?? [])
        .map((v) => (v as num).toDouble())
        .toList(),
    dailyKwh: ((j['dailyKwh'] as List?) ?? [])
        .map((v) => (v as num).toDouble())
        .toList(),
    seedDevices: ((j['devices'] as List?) ?? [])
        .map((v) => Device.fromJson(v as Map<String, dynamic>))
        .toList(),
  );
}

class Device {
  factory Device.fromJson(Map<String, dynamic> j) => Device(
    id: j['id'] as String,
    kind: DeviceKind.values.byName(j['kind'] as String),
    room: RoomId.values.byName(j['room'] as String),
    capabilities: (j['capabilities'] as List)
        .map((v) => Capability.values.byName(v as String))
        .toSet(),
    status: DeviceStatus.values.byName(j['status'] as String? ?? 'off'),
    value: (j['value'] as num? ?? 0).toDouble(),
    cloud: j['cloud'] == true,
    batteryPowered: j['batteryPowered'] == true,
    oneWay: j['oneWay'] == true,
  );
  const Device({
    required this.id,
    required this.kind,
    required this.room,
    required this.capabilities,
    this.status = DeviceStatus.off,
    this.cloud = false,
    this.oneWay = false,
    this.value = 0,
    this.source = EventSource.demo,
    this.batteryPowered = false,
  });
  final String id;
  final DeviceKind kind;
  final RoomId room;
  final Set<Capability> capabilities;
  final DeviceStatus status;
  final bool cloud, oneWay;
  final double value;
  final EventSource source;
  final bool batteryPowered;
  Feature? get feature => switch (kind) {
    DeviceKind.airConditioner => Feature.climate,
    DeviceKind.curtain => Feature.curtains,
    DeviceKind.doorLock => Feature.doorLock,
    DeviceKind.cloudRobot => Feature.cloudDevice,
    DeviceKind.gateMotor => Feature.gate,
    DeviceKind.alarmSiren => Feature.alarm,
    DeviceKind.waterValve => Feature.waterValve,
    DeviceKind.pump => Feature.waterZones,
    DeviceKind.kitchenPlug => Feature.gasActions,
    DeviceKind.waterHeater => Feature.waterHeating,
    DeviceKind.kitchenCircuit => Feature.applianceRanking,
    _ => null,
  };
  Device copyWith({DeviceStatus? status, double? value, EventSource? source}) =>
      Device(
        id: id,
        kind: kind,
        room: room,
        capabilities: capabilities,
        status: status ?? this.status,
        cloud: cloud,
        oneWay: oneWay,
        value: value ?? this.value,
        source: source ?? this.source,
        batteryPowered: batteryPowered,
      );
}

class DeviceCommand {
  const DeviceCommand({
    required this.id,
    required this.deviceId,
    required this.phase,
    required this.issuedAt,
    required this.source,
    this.targetOn = true,
    this.failure = CommandFailure.none,
    this.measuredWatts,
    this.targetValue,
    this.path = ConnectionPath.atHome,
  });
  final int id;
  final String deviceId;
  final CommandPhase phase;
  final DateTime issuedAt;
  final EventSource source;
  final bool targetOn;
  final CommandFailure failure;
  final int? measuredWatts;
  final double? targetValue;
  final ConnectionPath path;
  DeviceCommand result(
    CommandPhase phase, {
    CommandFailure failure = CommandFailure.none,
    int? measuredWatts,
  }) => DeviceCommand(
    id: id,
    deviceId: deviceId,
    phase: phase,
    issuedAt: issuedAt,
    source: source,
    targetOn: targetOn,
    failure: failure,
    measuredWatts: measuredWatts,
    targetValue: targetValue,
    path: path,
  );
}

class HomeAlert {
  const HomeAlert({
    required this.id,
    required this.kind,
    required this.level,
    required this.time,
    this.acknowledged = false,
    this.camera,
  });
  final int id;
  final AlertKind kind;
  final AlertLevel level;
  final DateTime time;
  final bool acknowledged;
  final CameraId? camera;
  HomeAlert acknowledge() => HomeAlert(
    id: id,
    kind: kind,
    level: level,
    time: time,
    acknowledged: true,
    camera: camera,
  );
}

class HistoryEvent {
  const HistoryEvent({
    required this.time,
    required this.source,
    this.device,
    this.phase,
    this.scene,
    this.action,
    this.camera,
    this.targetOn,
    this.path,
    this.alert,
  });
  final DateTime time;
  final EventSource source;
  final DeviceKind? device;
  final CommandPhase? phase;
  final SceneId? scene;
  final AuditAction? action;
  final CameraId? camera;
  final bool? targetOn;
  final ConnectionPath? path;
  final AlertKind? alert;
}

class HomeSnapshot {
  const HomeSnapshot({
    required this.profile,
    required this.tier,
    required this.time,
    required this.powerKw,
    required this.voltage,
    required this.todayKwh,
    required this.tankPercent,
    required this.devices,
    required this.commands,
    required this.alerts,
    required this.history,
    required this.powerHistory,
    this.connection = const DemoConnection(),
    this.plnAvailable = true,
    this.operation = const HouseOperation(),
    this.scenes = const [],
    this.members = const [],
    this.p1 = const P1State(),
  });
  final HomeProfile profile;
  final PackageTier tier;
  final DateTime time;
  final double powerKw, voltage, todayKwh;
  final int tankPercent;
  final List<Device> devices;
  final List<DeviceCommand> commands;
  final List<HomeAlert> alerts;
  final List<HistoryEvent> history;
  final List<double> powerHistory;
  final DemoConnection connection;
  final bool plnAvailable;
  bool get gasPowered => plnAvailable && !operation.kitchenCircuitCut;
  final HouseOperation operation;
  final List<ScenePlan> scenes;
  final List<DemoMember> members;
  final P1State p1;
  DeviceCommand? commandFor(String id) {
    for (final c in commands.reversed) {
      if (c.deviceId == id) return c;
    }
    return null;
  }

  HomeSnapshot copyWith({
    PackageTier? tier,
    DateTime? time,
    double? powerKw,
    double? voltage,
    double? todayKwh,
    int? tankPercent,
    List<Device>? devices,
    List<DeviceCommand>? commands,
    List<HomeAlert>? alerts,
    List<HistoryEvent>? history,
    List<double>? powerHistory,
    DemoConnection? connection,
    bool? plnAvailable,
    HouseOperation? operation,
    List<ScenePlan>? scenes,
    List<DemoMember>? members,
    P1State? p1,
  }) => HomeSnapshot(
    profile: profile,
    tier: tier ?? this.tier,
    time: time ?? this.time,
    powerKw: powerKw ?? this.powerKw,
    voltage: voltage ?? this.voltage,
    todayKwh: todayKwh ?? this.todayKwh,
    tankPercent: tankPercent ?? this.tankPercent,
    devices: devices ?? this.devices,
    commands: commands ?? this.commands,
    alerts: alerts ?? this.alerts,
    history: history ?? this.history,
    powerHistory: powerHistory ?? this.powerHistory,
    connection: connection ?? this.connection,
    plnAvailable: plnAvailable ?? this.plnAvailable,
    operation: operation ?? this.operation,
    scenes: scenes ?? this.scenes,
    members: members ?? this.members,
    p1: p1 ?? this.p1,
  );
}

class HouseOperation {
  const HouseOperation({
    this.gasDetected = false,
    this.gasValveClosed = false,
    this.gasActionsApplied = false,
    this.wetSensor = false,
    this.abnormalFlow = false,
    this.waterValveClosed = false,
    this.alarmArmed = false,
    this.technicianUntil,
    this.scenario,
    this.scenarioRunning = false,
    this.scenarioStep = 0,
    this.voltageAnomaly = false,
    this.loadShed = false,
    this.indoorPrivacy = false,
    this.wifiVersion = 1,
    this.kitchenCircuitCut = false,
  });
  final bool gasDetected,
      gasValveClosed,
      gasActionsApplied,
      wetSensor,
      abnormalFlow,
      waterValveClosed,
      alarmArmed,
      scenarioRunning,
      voltageAnomaly,
      loadShed;
  final DateTime? technicianUntil;
  final ScenarioId? scenario;
  final int scenarioStep;
  final bool indoorPrivacy;
  final int wifiVersion;
  final bool kitchenCircuitCut;
  HouseOperation copyWith({
    bool? gasDetected,
    bool? gasValveClosed,
    bool? gasActionsApplied,
    bool? wetSensor,
    bool? abnormalFlow,
    bool? waterValveClosed,
    bool? alarmArmed,
    DateTime? technicianUntil,
    bool revokeTechnician = false,
    ScenarioId? scenario,
    bool? scenarioRunning,
    int? scenarioStep,
    bool? voltageAnomaly,
    bool? loadShed,
    bool? indoorPrivacy,
    int? wifiVersion,
    bool? kitchenCircuitCut,
  }) => HouseOperation(
    gasDetected: gasDetected ?? this.gasDetected,
    gasValveClosed: gasValveClosed ?? this.gasValveClosed,
    gasActionsApplied: gasActionsApplied ?? this.gasActionsApplied,
    wetSensor: wetSensor ?? this.wetSensor,
    abnormalFlow: abnormalFlow ?? this.abnormalFlow,
    waterValveClosed: waterValveClosed ?? this.waterValveClosed,
    alarmArmed: alarmArmed ?? this.alarmArmed,
    technicianUntil: revokeTechnician
        ? null
        : technicianUntil ?? this.technicianUntil,
    scenario: scenario ?? this.scenario,
    scenarioRunning: scenarioRunning ?? this.scenarioRunning,
    scenarioStep: scenarioStep ?? this.scenarioStep,
    voltageAnomaly: voltageAnomaly ?? this.voltageAnomaly,
    loadShed: loadShed ?? this.loadShed,
    indoorPrivacy: indoorPrivacy ?? this.indoorPrivacy,
    wifiVersion: wifiVersion ?? this.wifiVersion,
    kitchenCircuitCut: kitchenCircuitCut ?? this.kitchenCircuitCut,
  );
}

class ScenePlan {
  factory ScenePlan.fromJson(Map<String, dynamic> j) => ScenePlan(
    SceneId.values.byName(j['id'] as String),
    lightsOn: j['lightsOn'] as bool,
    acOn: j['acOn'] as bool,
    curtainOpen: j['curtainOpen'] as bool,
    hour: j['hour'] as int,
    minute: j['minute'] as int,
    scheduled: j['scheduled'] as bool,
  );
  const ScenePlan(
    this.id, {
    this.lightsOn = true,
    this.acOn = false,
    this.curtainOpen = false,
    this.hour = 7,
    this.minute = 0,
    this.scheduled = false,
  });
  final SceneId id;
  final bool lightsOn, acOn, curtainOpen, scheduled;
  final int hour, minute;
}

class DemoMember {
  const DemoMember(this.id, this.role, {this.active = true});
  final String id;
  final UserRole role;
  final bool active;
}
