import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/l10n/generated/app_localizations.dart';
import '../domain/models.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
  String number(num value, {int decimals = 0}) =>
      NumberFormat.decimalPatternDigits(
        locale: l.localeName,
        decimalDigits: decimals,
      ).format(value);
  String houseTime(DateTime utc, {bool seconds = false}) => DateFormat(
    seconds ? 'HH.mm.ss' : 'HH.mm',
    l.localeName,
  ).format(utc.toUtc().add(const Duration(hours: 8)));
  String houseDate(DateTime utc) => DateFormat(
    'd MMM y',
    l.localeName,
  ).format(utc.toUtc().add(const Duration(hours: 8)));
}

extension Labels on AppLocalizations {
  String tierName(PackageTier v) => switch (v) {
    PackageTier.basic => basic,
    PackageTier.medium => medium,
    PackageTier.high => high,
    PackageTier.custom => custom,
  };
  String roleName(UserRole v) => switch (v) {
    UserRole.owner => owner,
    UserRole.family => family,
    UserRole.guest => guest,
    UserRole.technician => technician,
  };
  String profileName(String id) => switch (id) {
    'a' => houseA,
    'b' => houseB,
    _ => villa,
  };
  String roomName(RoomId v) => switch (v) {
    RoomId.living => living,
    RoomId.bedroom => bedroom,
    RoomId.kitchen => kitchen,
    RoomId.bathroom => bathroom,
    RoomId.terrace => terrace,
    RoomId.bedroomTwo => bedroomTwo,
    RoomId.carport => carport,
    RoomId.gate => gate,
  };
  String cameraName(CameraId v) => switch (v) {
    CameraId.frontGate => frontGate,
    CameraId.carport => carport,
    CameraId.terrace => terrace,
    CameraId.living => living,
    CameraId.gate => gate,
  };
  String deviceName(DeviceKind v) => switch (v) {
    DeviceKind.mainLight => mainLight,
    DeviceKind.readingLight => readingLight,
    DeviceKind.airConditioner => airConditioner,
    DeviceKind.curtain => curtain,
    DeviceKind.doorLock => doorLock,
    DeviceKind.cloudRobot => cloudRobot,
    DeviceKind.porchLight => porchLight,
    DeviceKind.gateMotor => gateMotor,
    DeviceKind.alarmSiren => alarmSiren,
    DeviceKind.waterValve => waterValve,
    DeviceKind.pump => pump,
    DeviceKind.kitchenPlug => kitchenPlug,
    DeviceKind.exhaustFan => exhaustFan,
    DeviceKind.waterHeater => waterHeater,
    DeviceKind.doorSensor => doorSensor,
    DeviceKind.leakSensor => leakSensor,
    DeviceKind.kitchenCircuit => kitchenCircuit,
  };
  String deviceStatus(DeviceStatus v) => switch (v) {
    DeviceStatus.on => on,
    DeviceStatus.off => off,
    DeviceStatus.unreachable => unreachable,
    DeviceStatus.noPower => noPower,
    DeviceStatus.lowBattery => lowBattery,
    DeviceStatus.attention => needsAttention,
  };
  String pathName(ConnectionPath v) => switch (v) {
    ConnectionPath.atHome => atHome,
    ConnectionPath.localOffline => localOffline,
    ConnectionPath.remote => remote,
    ConnectionPath.unreachable => unreachable,
  };
  String foundationName(Foundation v) => switch (v) {
    Foundation.electricity => electricity,
    Foundation.water => water,
    Foundation.wifi => wifi,
    Foundation.gas => gas,
    Foundation.cctv => cctv,
  };
  String featureName(Feature v) => switch (v) {
    Feature.electricity => electricity,
    Feature.water => water,
    Feature.wifi => wifi,
    Feature.gas => gas,
    Feature.cctv => cctv,
    Feature.circuits => circuits,
    Feature.applianceRanking => applianceRanking,
    Feature.waterZones => waterZones,
    Feature.waterValve => waterValve,
    Feature.guestWifi => guestWifi,
    Feature.guestRotation => guestRotation,
    Feature.gasActions => gasActions,
    Feature.gasValve => gasValve,
    Feature.recording => recording,
    Feature.personDetection => personDetection,
    Feature.climate => climate,
    Feature.curtains => curtains,
    Feature.doorLock => doorLock,
    Feature.gate => gate,
    Feature.alarm => alarm,
    Feature.members => members,
    Feature.energy => energy,
    Feature.accessCodes => accessCodes,
    Feature.remoteGuestCodes => remoteGuestCodes,
    Feature.cloudDevice => cloudDevice,
    Feature.automations => automations,
    Feature.addDevice => addDevice,
    Feature.rental => rental,
    Feature.rentalReset => rentalReset,
    Feature.service => service,
    Feature.secondContacts => secondContacts,
    Feature.waterHeating => waterHeating,
  };
  String sourceName(EventSource v) => switch (v) {
    EventSource.owner => owner,
    EventSource.family => family,
    EventSource.guest => guest,
    EventSource.wallSwitch => wallSwitch,
    EventSource.automation => automation,
    EventSource.demo => simulation,
  };
  String sceneName(SceneId v) => switch (v) {
    SceneId.morning => morning,
    SceneId.night => night,
    SceneId.guest => guestScene,
    SceneId.away => away,
  };
  String conditionName(ViewCondition v) => switch (v) {
    ViewCondition.normal => normal,
    ViewCondition.pressed => pressed,
    ViewCondition.disabled => disabled,
    ViewCondition.loading => loading,
    ViewCondition.empty => empty,
    ViewCondition.error => error,
    ViewCondition.locked => locked,
  };
  String commandName(CommandPhase v) => switch (v) {
    CommandPhase.sent => sent,
    CommandPhase.confirmed => confirmed,
    CommandPhase.failed => failed,
    CommandPhase.unconfirmed => unconfirmed,
  };
  String levelName(AlertLevel v) => switch (v) {
    AlertLevel.critical => critical,
    AlertLevel.important => important,
    AlertLevel.info => info,
  };
  String alertName(AlertKind v) => switch (v) {
    AlertKind.sampleCritical => criticalPreview,
    AlertKind.voltage => voltageAlert,
    AlertKind.lowBattery => batteryAlert,
    AlertKind.gasLeak => gasLeak,
    AlertKind.waterLeak => waterLeak,
    AlertKind.powerOutage => powerOutage,
    AlertKind.powerRestored => powerRestored,
    AlertKind.loadShed => loadShed,
    AlertKind.detectorTest => detectorTest,
    AlertKind.motion => motion,
    AlertKind.person => personDetected,
  };
  String scenarioName(ScenarioId v) => switch (v) {
    ScenarioId.s1 => s1,
    ScenarioId.s2 => s2,
    ScenarioId.s3 => s3,
    ScenarioId.s4 => s4,
    ScenarioId.s5 => s5,
    ScenarioId.s6 => s6,
    ScenarioId.s7 => s7,
    ScenarioId.s8 => s8,
    ScenarioId.s9 => s9,
    ScenarioId.s10 => s10,
  };
  String scenarioNote(ScenarioId v) => switch (v) {
    ScenarioId.s1 => s1BasicNote,
    ScenarioId.s2 => s2ResetNote,
    ScenarioId.s3 => s3Note,
    ScenarioId.s4 => s4Note,
    ScenarioId.s5 => s5Note,
    ScenarioId.s6 => s6Note,
    ScenarioId.s7 => s7Note,
    ScenarioId.s8 => s8Note,
    ScenarioId.s9 => s9Note,
    ScenarioId.s10 => s10Note,
  };
  String auditName(AuditAction v) => switch (v) {
    AuditAction.acknowledged => acknowledgedEvent,
    AuditAction.gasDetected => gasDetectedEvent,
    AuditAction.gasActions => gasActionsApplied,
    AuditAction.gasValveClosed => gasValveClosed,
    AuditAction.gasNormal => gasNormal,
    AuditAction.physicalReset => gasPhysicalResetEvent,
    AuditAction.waterDetected => waterDetectedEvent,
    AuditAction.waterValveClosed => waterValveClosedEvent,
    AuditAction.powerLost => powerOutage,
    AuditAction.powerRestored => powerRestored,
    AuditAction.voltageAnomaly => voltageAnomalyEvent,
    AuditAction.loadShed => loadShed,
    AuditAction.memberChanged => memberChangedEvent,
    AuditAction.technicianGranted => technicianGrantedEvent,
    AuditAction.technicianRevoked => technicianRevokedEvent,
    AuditAction.sceneEdited => sceneEditedEvent,
    AuditAction.alarmArmed => alarmArmed,
    AuditAction.alarmDisarmed => alarmDisarmed,
    AuditAction.cameraViewed => cameraAccess,
    AuditAction.codeIssued => codeIssuedEvent,
    AuditAction.codeRevoked => codeRevokedEvent,
    AuditAction.codeUsed => codeUsedEvent,
    AuditAction.checkedOut => checkedOutEvent,
    AuditAction.wifiRotated => wifiRotatedEvent,
    AuditAction.deviceAdded => deviceAddedEvent,
    AuditAction.automationChanged => automationChangedEvent,
    AuditAction.automationRan => automationRanEvent,
    AuditAction.ticketCreated => ticketCreatedEvent,
    AuditAction.contactChanged => contactChangedEvent,
    AuditAction.housePaired => housePairedEvent,
  };
  String automationName(AutomationKind v) => switch (v) {
    AutomationKind.vacantAc => vacantAc,
    AutomationKind.humidFan => humidFan,
    AutomationKind.scheduledHeater => scheduledHeater,
  };
  String eventName(CameraEventKind v) => switch (v) {
    CameraEventKind.motion => motion,
    CameraEventKind.person => personDetected,
    CameraEventKind.vehicle => vehicleDetected,
  };
  String serviceName(ServiceCategory v) => switch (v) {
    ServiceCategory.urgent => urgentService,
    ServiceCategory.disruption => disruptionService,
    ServiceCategory.general => generalService,
  };
}
