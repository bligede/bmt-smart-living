import 'models.dart';

abstract interface class HomeRepository {
  HomeSnapshot get current;
  List<HomeProfile> get profiles;
  Stream<HomeSnapshot> watchHome();
  void selectProfile(String id);
  void setTier(PackageTier tier);
  void setConnection(DemoConnection connection);
  void setClock({required bool night, required int speed});
  void reset();
  void runScenario(ScenarioId id, {bool provideEvidence = true});
  void stopScenario();
  void normalizeGas();
  void physicalGasReset();
  void testDetector();
  void pairHouse(String profile, UserRole actor);
  void createTicket(ServiceCategory category, UserRole actor);
}

abstract interface class DeviceRepository {
  List<Device> devicesFor(UserRole role);
  DeviceCommand send(
    String deviceId, {
    required bool on,
    required UserRole actor,
    bool provideEvidence = true,
    bool riskConfirmed = false,
    double? value,
  });
  void wallSwitch(String deviceId);
  void runScene(SceneId scene, UserRole actor);
  void saveScene(ScenePlan plan, UserRole actor);
  CompatibilityResult compatibility(PairingCandidate candidate);
  bool addDevice(PairingCandidate candidate, UserRole actor);
  void saveAutomation(AutomationRule rule, UserRole actor);
  void simulateAutomation(AutomationKind kind, UserRole actor);
}

abstract interface class AlertRepository {
  List<HomeAlert> alertsFor(UserRole role);
  void acknowledge(int id, UserRole actor);
  void previewCritical();
}

abstract interface class AccessRepository {
  bool canUnlock(UserRole role);
  void setMember(String id, UserRole role, bool active, UserRole actor);
  void inviteMember(UserRole role, UserRole actor);
  void technicianAccess(bool enabled, UserRole actor);
  bool technicianActive();
  void armAlarm(bool armed, UserRole actor, {bool riskConfirmed = false});
  void setSecondContact(bool enabled, UserRole actor);
}

abstract interface class CameraRepository {
  List<CameraId> camerasFor(UserRole role);
  void recordAccess(CameraId camera, UserRole role);
  void setIndoorPrivacy(bool enabled, UserRole actor);
  List<CameraEvent> eventsFor(
    CameraId camera,
    UserRole role, {
    CameraEventKind? filter,
  });
}

abstract interface class EnergyRepository {
  List<double> historyFor(
    UserRole role, {
    ChartPeriod period = ChartPeriod.day,
  });
  MonthlyEnergyReport? monthlyReport(UserRole role);
}

abstract interface class GuestRepository {
  bool canIssueRemoteCode(UserRole role);
  void rotateWifi(UserRole actor);
  bool canIssueCode(UserRole role);
  List<AccessCode> codesFor(UserRole role);
  AccessCode? issueCode(
    int guest,
    DateTime from,
    DateTime until,
    UserRole actor,
  );
  void revokeCode(int id, UserRole actor);
  bool useCode(int id, UserRole actor, {bool riskConfirmed = false});
  bool checkout(UserRole actor, {bool riskConfirmed = false});
}

class Repositories {
  const Repositories({
    required this.home,
    required this.devices,
    required this.alerts,
    required this.access,
    required this.cameras,
    required this.energy,
    required this.guests,
  });
  final HomeRepository home;
  final DeviceRepository devices;
  final AlertRepository alerts;
  final AccessRepository access;
  final CameraRepository cameras;
  final EnergyRepository energy;
  final GuestRepository guests;
}
