import 'models.dart';

class FeatureGate {
  const FeatureGate();
  int cameraLimit(PackageTier tier) => tier == PackageTier.basic ? 2 : 4;
  static const _minimum = <Feature, PackageTier>{
    Feature.circuits: PackageTier.medium,
    Feature.applianceRanking: PackageTier.high,
    Feature.waterZones: PackageTier.medium,
    Feature.waterValve: PackageTier.high,
    Feature.guestWifi: PackageTier.medium,
    Feature.guestRotation: PackageTier.high,
    Feature.gasActions: PackageTier.medium,
    Feature.gasValve: PackageTier.high,
    Feature.recording: PackageTier.medium,
    Feature.personDetection: PackageTier.high,
    Feature.climate: PackageTier.medium,
    Feature.curtains: PackageTier.medium,
    Feature.doorLock: PackageTier.medium,
    Feature.gate: PackageTier.medium,
    Feature.alarm: PackageTier.medium,
    Feature.accessCodes: PackageTier.medium,
    Feature.remoteGuestCodes: PackageTier.high,
    Feature.cloudDevice: PackageTier.custom,
    Feature.rentalReset: PackageTier.high,
    Feature.waterHeating: PackageTier.medium,
  };
  GateDecision check(
    Feature feature,
    PackageTier tier,
    HouseKind kind,
    UserRole role,
  ) {
    if (role == UserRole.guest &&
        !{Feature.climate, Feature.guestWifi}.contains(feature)) {
      return GateDecision.forbidden;
    }
    if (role == UserRole.technician &&
        {
          Feature.cctv,
          Feature.recording,
          Feature.personDetection,
          Feature.accessCodes,
          Feature.remoteGuestCodes,
          Feature.members,
          Feature.doorLock,
          Feature.addDevice,
          Feature.rental,
          Feature.rentalReset,
          Feature.secondContacts,
          Feature.automations,
          Feature.service,
        }.contains(feature)) {
      return GateDecision.forbidden;
    }
    if (role == UserRole.family &&
        {
          Feature.members,
          Feature.accessCodes,
          Feature.remoteGuestCodes,
          Feature.addDevice,
          Feature.rental,
          Feature.rentalReset,
          Feature.secondContacts,
        }.contains(feature)) {
      return GateDecision.forbidden;
    }
    if ({Feature.rental, Feature.rentalReset}.contains(feature) &&
        kind != HouseKind.rental) {
      return GateDecision.forbidden;
    }
    if (kind == HouseKind.rental &&
        {Feature.doorLock, Feature.accessCodes}.contains(feature)) {
      return GateDecision.available;
    }
    return tier.index >= (_minimum[feature] ?? PackageTier.basic).index
        ? GateDecision.available
        : GateDecision.locked;
  }

  bool cameraVisible(CameraId camera, HouseKind kind, UserRole role) =>
      role != UserRole.guest &&
      role != UserRole.technician &&
      !(kind == HouseKind.rental && camera == CameraId.living);
}
