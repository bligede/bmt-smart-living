part of 'models.dart';

enum AutomationKind { vacantAc, humidFan, scheduledHeater }

enum CameraEventKind { motion, person, vehicle }

enum PairingCandidate { localRelay, cloudRobot, unsupported }

enum ServiceCategory { urgent, disruption, general }

class AccessCode {
  const AccessCode({
    required this.id,
    required this.value,
    required this.guest,
    required this.from,
    required this.until,
    this.revoked = false,
  });
  final int id, guest;
  final String value;
  final DateTime from, until;
  final bool revoked;
  bool validAt(DateTime now) =>
      !revoked && !now.isBefore(from) && now.isBefore(until);
  AccessCode revoke() => AccessCode(
    id: id,
    value: value,
    guest: guest,
    from: from,
    until: until,
    revoked: true,
  );
}

class RentalReport {
  const RentalReport(
    this.time,
    this.revokedCount,
    this.wifiVersion,
    this.commandIds,
  );
  final DateTime time;
  final int revokedCount, wifiVersion;
  final List<int> commandIds;
}

class AutomationRule {
  const AutomationRule(
    this.kind, {
    this.enabled = false,
    this.hour = 6,
    this.minute = 0,
    this.lastRun,
  });
  final AutomationKind kind;
  final bool enabled;
  final int hour, minute;
  final DateTime? lastRun;
  Feature get feature => switch (kind) {
    AutomationKind.vacantAc => Feature.climate,
    AutomationKind.humidFan => Feature.automations,
    AutomationKind.scheduledHeater => Feature.waterHeating,
  };
  AutomationRule copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    DateTime? lastRun,
  }) => AutomationRule(
    kind,
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    lastRun: lastRun ?? this.lastRun,
  );
}

class CompatibilityResult {
  const CompatibilityResult(this.candidate, this.checks);
  final PairingCandidate candidate;
  // Local control, state feedback, operation without internet, supported integration.
  final List<bool> checks;
  bool get local => checks.every((v) => v);
  bool get cloud => candidate == PairingCandidate.cloudRobot;
  bool get supported => local || cloud;
}

class CameraEvent {
  const CameraEvent(this.id, this.camera, this.time, this.kind);
  final int id;
  final CameraId camera;
  final DateTime time;
  final CameraEventKind kind;
}

class MonthlyEnergyReport {
  const MonthlyEnergyReport(
    this.month,
    this.currentKwh,
    this.previousKwh,
    this.byDevice,
  );
  final DateTime month;
  final double currentKwh, previousKwh;
  final Map<DeviceKind, double> byDevice;
}

class ServiceTicket {
  const ServiceTicket(this.id, this.category, this.time);
  final int id;
  final ServiceCategory category;
  final DateTime time;
}

class P1State {
  const P1State({
    this.codes = const [],
    this.checkedInCode,
    this.report,
    this.rules = const [
      AutomationRule(AutomationKind.vacantAc),
      AutomationRule(AutomationKind.humidFan),
      AutomationRule(AutomationKind.scheduledHeater),
    ],
    this.events = const [],
    this.tickets = const [],
    this.secondContact = false,
    this.paired = false,
    this.humidity = 68,
    this.vacantSince,
    this.batteryPercent = 82,
    this.batteryDays = 180,
  });
  final List<AccessCode> codes;
  final int? checkedInCode;
  final RentalReport? report;
  final List<AutomationRule> rules;
  final List<CameraEvent> events;
  final List<ServiceTicket> tickets;
  final bool secondContact, paired;
  final int humidity, batteryPercent, batteryDays;
  final DateTime? vacantSince;
  P1State copyWith({
    List<AccessCode>? codes,
    int? checkedInCode,
    bool clearStay = false,
    RentalReport? report,
    List<AutomationRule>? rules,
    List<CameraEvent>? events,
    List<ServiceTicket>? tickets,
    bool? secondContact,
    bool? paired,
    int? humidity,
    DateTime? vacantSince,
    int? batteryPercent,
    int? batteryDays,
  }) => P1State(
    codes: codes ?? this.codes,
    checkedInCode: clearStay ? null : checkedInCode ?? this.checkedInCode,
    report: report ?? this.report,
    rules: rules ?? this.rules,
    events: events ?? this.events,
    tickets: tickets ?? this.tickets,
    secondContact: secondContact ?? this.secondContact,
    paired: paired ?? this.paired,
    humidity: humidity ?? this.humidity,
    vacantSince: vacantSince ?? this.vacantSince,
    batteryPercent: batteryPercent ?? this.batteryPercent,
    batteryDays: batteryDays ?? this.batteryDays,
  );
}
