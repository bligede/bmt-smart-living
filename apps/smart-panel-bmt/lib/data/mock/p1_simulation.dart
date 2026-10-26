part of 'mock_repositories.dart';

extension P1Simulation on MockHomeStore {
  bool canIssueCode(UserRole actor) =>
      actor == UserRole.owner &&
      check(Feature.accessCodes, actor) == GateDecision.available &&
      _house.connection.reachable &&
      (_house.connection.atHome ||
          (_house.profile.kind == HouseKind.rental &&
              check(Feature.remoteGuestCodes, actor) ==
                  GateDecision.available));

  AccessCode? issueCode(
    int guest,
    DateTime from,
    DateTime until,
    UserRole actor,
  ) {
    if (!canIssueCode(actor) ||
        guest < 1 ||
        guest > 3 ||
        !until.isAfter(from) ||
        !until.isAfter(clock.now) ||
        until.difference(from) > const Duration(days: 30)) {
      return null;
    }
    final code = AccessCode(
      id: ++_nextId,
      value: '${610000 + _nextId * 17}',
      guest: guest,
      from: from.toUtc(),
      until: until.toUtc(),
    );
    _house = _house.copyWith(
      p1: _house.p1.copyWith(codes: [..._house.p1.codes, code]),
    );
    _audit(AuditAction.codeIssued, source: EventSource.owner);
    _publish();
    return code;
  }

  void revokeCode(int id, UserRole actor) {
    if (!canIssueCode(actor)) return;
    final matches = _house.p1.codes.where((c) => c.id == id && !c.revoked);
    if (matches.isEmpty) return;
    _house = _house.copyWith(
      p1: _house.p1.copyWith(
        codes: _house.p1.codes.map((c) => c.id == id ? c.revoke() : c).toList(),
        clearStay: _house.p1.checkedInCode == id,
      ),
    );
    _audit(AuditAction.codeRevoked, source: EventSource.owner);
    _publish();
  }

  bool useCode(int id, UserRole actor, {bool riskConfirmed = false}) {
    // The presenter simulates a physical keypad; phone controls still require a route.
    if (actor != UserRole.owner || !riskConfirmed || !canIssueCode(actor)) {
      return false;
    }
    final matches = _house.p1.codes.where(
      (c) => c.id == id && c.validAt(clock.now),
    );
    if (matches.isEmpty) return false;
    final command = send(
      'door-lock',
      on: true,
      actor: UserRole.owner,
      riskConfirmed: true,
      automatic: true,
      sourceOverride: EventSource.guest,
    );
    if (command.phase == CommandPhase.failed) return false;
    _house = _house.copyWith(p1: _house.p1.copyWith(checkedInCode: id));
    if (check(Feature.guestRotation, actor) == GateDecision.available) {
      _house = _house.copyWith(
        operation: _house.operation.copyWith(
          wifiVersion: _house.operation.wifiVersion + 1,
        ),
      );
      _audit(AuditAction.wifiRotated);
    }
    _audit(AuditAction.codeUsed, source: EventSource.guest);
    _publish();
    return true;
  }

  bool checkout(UserRole actor, {bool riskConfirmed = false}) {
    if (!riskConfirmed ||
        actor != UserRole.owner ||
        check(Feature.rentalReset, actor) != GateDecision.available ||
        !_house.connection.internet ||
        !_house.connection.reachable) {
      return false;
    }
    final count = _house.p1.codes.where((c) => !c.revoked).length;
    _house = _house.copyWith(
      p1: _house.p1.copyWith(
        codes: _house.p1.codes.map((c) => c.revoke()).toList(),
        clearStay: true,
      ),
      operation: _house.operation.copyWith(
        wifiVersion: _house.operation.wifiVersion + 1,
      ),
    );
    final ids = <int>[];
    for (final d in _house.devices.where(
      (d) => {
        DeviceKind.mainLight,
        DeviceKind.readingLight,
        DeviceKind.porchLight,
        DeviceKind.airConditioner,
      }.contains(d.kind),
    )) {
      if (permitted(d, actor)) ids.add(send(d.id, on: false, actor: actor).id);
    }
    _house = _house.copyWith(
      p1: _house.p1.copyWith(
        report: RentalReport(
          clock.now,
          count,
          _house.operation.wifiVersion,
          ids,
        ),
      ),
    );
    _audit(AuditAction.checkedOut, source: EventSource.owner);
    _audit(AuditAction.wifiRotated, source: EventSource.owner);
    _publish();
    return true;
  }

  CompatibilityResult compatibility(PairingCandidate candidate) =>
      CompatibilityResult(candidate, switch (candidate) {
        PairingCandidate.localRelay => const [true, true, true, true],
        PairingCandidate.cloudRobot => const [false, true, false, true],
        PairingCandidate.unsupported => const [false, false, false, false],
      });

  bool addDevice(PairingCandidate candidate, UserRole actor) {
    if (check(Feature.addDevice, actor) != GateDecision.available ||
        !_house.connection.atHome ||
        !_house.connection.reachable ||
        !_house.plnAvailable) {
      return false;
    }
    final result = compatibility(candidate);
    if (!result.supported ||
        (result.cloud &&
            (check(Feature.cloudDevice, actor) != GateDecision.available ||
                !_house.connection.internet))) {
      return false;
    }
    final id = result.cloud ? 'paired-cloud-robot' : 'paired-relay';
    if (_house.devices.any((d) => d.id == id)) return false;
    _house = _house.copyWith(
      devices: [
        ..._house.devices,
        Device(
          id: id,
          kind: result.cloud ? DeviceKind.cloudRobot : DeviceKind.readingLight,
          room: _house.profile.rooms.first,
          capabilities: const {Capability.switchable},
          cloud: result.cloud,
        ),
      ],
    );
    _audit(AuditAction.deviceAdded, source: EventSource.owner);
    _publish();
    return true;
  }

  void saveAutomation(AutomationRule rule, UserRole actor) {
    if (check(Feature.automations, actor) != GateDecision.available ||
        check(rule.feature, actor) != GateDecision.available ||
        !_house.connection.reachable ||
        rule.hour < 0 ||
        rule.hour > 23 ||
        rule.minute < 0 ||
        rule.minute > 59) {
      return;
    }
    _house = _house.copyWith(
      p1: _house.p1.copyWith(
        rules: _house.p1.rules
            .map((r) => r.kind == rule.kind ? rule : r)
            .toList(),
      ),
    );
    _audit(
      AuditAction.automationChanged,
      source: actor == UserRole.family ? EventSource.family : EventSource.owner,
    );
    _publish();
  }

  void simulateAutomation(AutomationKind kind, UserRole actor) {
    if (check(Feature.automations, actor) != GateDecision.available ||
        !_house.connection.reachable) {
      return;
    }
    final r = _house.p1.rules.firstWhere((r) => r.kind == kind);
    if (!r.enabled || check(r.feature, actor) != GateDecision.available) return;
    if (kind == AutomationKind.vacantAc) {
      _house = _house.copyWith(
        p1: _house.p1.copyWith(
          vacantSince: clock.now.subtract(const Duration(minutes: 16)),
        ),
      );
    } else if (kind == AutomationKind.humidFan) {
      _house = _house.copyWith(p1: _house.p1.copyWith(humidity: 78));
    } else {
      _runAutomation(r);
    }
    tickP1();
    _publish();
  }

  void _runAutomation(AutomationRule rule) {
    if (!_house.plnAvailable ||
        check(rule.feature, UserRole.owner) != GateDecision.available) {
      return;
    }
    final id = switch (rule.kind) {
      AutomationKind.vacantAc => 'ac',
      AutomationKind.humidFan => 'exhaust-fan',
      AutomationKind.scheduledHeater => 'water-heater',
    };
    send(
      id,
      on: rule.kind != AutomationKind.vacantAc,
      actor: UserRole.owner,
      automatic: true,
      riskConfirmed: true,
    );
    _house = _house.copyWith(
      p1: _house.p1.copyWith(
        rules: _house.p1.rules
            .map(
              (r) => r.kind == rule.kind ? r.copyWith(lastRun: clock.now) : r,
            )
            .toList(),
      ),
    );
    _audit(AuditAction.automationRan);
    _publish();
  }

  void tickP1() {
    final now = clock.now, p = _house.p1;
    if (p.checkedInCode != null &&
        !p.codes.any((c) => c.id == p.checkedInCode && c.validAt(now))) {
      _house = _house.copyWith(p1: p.copyWith(clearStay: true));
      _publish();
    }
    for (final rule in _house.p1.rules.where((r) => r.enabled)) {
      final local = now.toUtc().add(const Duration(hours: 8));
      final due = switch (rule.kind) {
        AutomationKind.vacantAc =>
          p.vacantSince != null &&
              now.difference(p.vacantSince!).inMinutes >= 15 &&
              (rule.lastRun == null || rule.lastRun!.isBefore(p.vacantSince!)),
        AutomationKind.humidFan => p.humidity > 75 && rule.lastRun == null,
        AutomationKind.scheduledHeater =>
          local.hour == rule.hour &&
              local.minute == rule.minute &&
              (rule.lastRun == null ||
                  now.difference(rule.lastRun!).inMinutes >= 1),
      };
      if (due) _runAutomation(rule);
    }
  }

  void createTicket(ServiceCategory category, UserRole actor) {
    if (check(Feature.service, actor) != GateDecision.available ||
        !_house.connection.reachable) {
      return;
    }
    final ticket = ServiceTicket(++_nextId, category, clock.now);
    _house = _house.copyWith(
      p1: _house.p1.copyWith(tickets: [..._house.p1.tickets, ticket]),
    );
    _audit(
      AuditAction.ticketCreated,
      source: actor == UserRole.family ? EventSource.family : EventSource.owner,
    );
    _publish();
  }

  void motionAtGate() {
    final cameras = repositories.cameras.camerasFor(UserRole.owner);
    if (cameras.isEmpty || !_house.plnAvailable) return;
    final camera = cameras.contains(CameraId.gate)
        ? CameraId.gate
        : cameras.first;
    final person =
        check(Feature.personDetection, UserRole.owner) ==
        GateDecision.available;
    final event = CameraEvent(
      ++_nextId,
      camera,
      clock.now,
      person ? CameraEventKind.person : CameraEventKind.motion,
    );
    _house = _house.copyWith(
      p1: _house.p1.copyWith(events: [..._house.p1.events, event]),
      alerts: [
        ..._house.alerts,
        HomeAlert(
          id: ++_nextId,
          kind: person ? AlertKind.person : AlertKind.motion,
          level: AlertLevel.important,
          time: clock.now,
          camera: camera,
        ),
      ],
    );
    _publish();
  }

  void lowBattery() {
    _house = _house.copyWith(
      devices: _house.devices
          .map(
            (d) => d.id == 'door-sensor'
                ? d.copyWith(
                    status: DeviceStatus.lowBattery,
                    source: EventSource.automation,
                  )
                : d,
          )
          .toList(),
      p1: _house.p1.copyWith(batteryPercent: 12, batteryDays: 7),
    );
    _alert(AlertKind.lowBattery, AlertLevel.info);
    _publish();
  }
}
