part of 'mock_repositories.dart';

/// Presenter actions and house automation share the store and its virtual clock.
extension P0Simulation on MockHomeStore {
  void _audit(
    AuditAction action, {
    EventSource source = EventSource.automation,
    AlertKind? alert,
  }) {
    _house = _house.copyWith(
      history: [
        ..._house.history,
        HistoryEvent(
          time: clock.now,
          source: source,
          action: action,
          path: source == EventSource.automation
              ? ConnectionPath.atHome
              : _house.connection.path,
          alert: alert,
        ),
      ],
    );
  }

  void _alert(AlertKind kind, AlertLevel level) {
    _house = _house.copyWith(
      alerts: [
        ..._house.alerts,
        HomeAlert(id: ++_nextId, kind: kind, level: level, time: clock.now),
      ],
    );
  }

  void _deviceState(String id, bool on) {
    _supersede(id);
    _house = _house.copyWith(
      devices: _house.devices
          .map(
            (d) => d.id == id
                ? d.copyWith(
                    status: on ? DeviceStatus.on : DeviceStatus.off,
                    source: EventSource.automation,
                  )
                : d,
          )
          .toList(),
    );
  }

  void _stage(int step) {
    _house = _house.copyWith(
      operation: _house.operation.copyWith(scenarioStep: step),
    );
    _publish();
  }

  void runScenario(ScenarioId id, {bool provideEvidence = true}) {
    final tier = _house.tier, speed = clock.speed;
    reset();
    _house = _house.copyWith(
      tier: tier,
      operation: _house.operation.copyWith(scenario: id, scenarioRunning: true),
    );
    clock.speed = speed;
    final steps = <ScenarioStep>[];
    void at(int seconds, void Function() action) =>
        steps.add(ScenarioStep(Duration(seconds: seconds), action));
    switch (id) {
      case ScenarioId.s1:
        setClock(night: true, speed: speed);
        at(0, () {
          send('porch-light', on: true, actor: UserRole.owner);
          _stage(1);
        });
        at(3, () {
          if (check(Feature.climate, UserRole.owner) ==
              GateDecision.available) {
            send(
              'ac',
              on: true,
              actor: UserRole.owner,
              provideEvidence: provideEvidence,
            );
          }
          _stage(2);
        });
        at(6, () {
          if (check(Feature.doorLock, UserRole.owner) ==
              GateDecision.available) {
            send(
              'door-lock',
              on: true,
              actor: UserRole.owner,
              riskConfirmed: true,
            );
          }
          _stage(3);
        });
      case ScenarioId.s2:
        at(1, () {
          _house = _house.copyWith(
            operation: _house.operation.copyWith(gasDetected: true),
          );
          _alert(AlertKind.gasLeak, AlertLevel.critical);
          _audit(AuditAction.gasDetected);
          _stage(1);
        });
        // C08: only illustrative states. The guidance remains pending BMT validation.
        at(3, () {
          if (check(Feature.gasActions, UserRole.owner) ==
              GateDecision.available) {
            _deviceState('kitchen-plug', false);
            _deviceState('exhaust-fan', true);
            _house = _house.copyWith(
              operation: _house.operation.copyWith(gasActionsApplied: true),
            );
            _audit(AuditAction.gasActions);
          }
          if (check(Feature.gasValve, UserRole.owner) ==
              GateDecision.available) {
            _house = _house.copyWith(
              operation: _house.operation.copyWith(gasValveClosed: true),
            );
            _audit(AuditAction.gasValveClosed);
          }
          _stage(2);
        });
      case ScenarioId.s3:
        at(1, () {
          _house = _house.copyWith(
            operation: _house.operation.copyWith(wetSensor: true),
          );
          _alert(AlertKind.waterLeak, AlertLevel.important);
          _audit(AuditAction.waterDetected);
          _stage(1);
        });
        at(4, () {
          _house = _house.copyWith(
            operation: _house.operation.copyWith(abnormalFlow: true),
          );
          if (check(Feature.waterValve, UserRole.owner) ==
              GateDecision.available) {
            _house = _house.copyWith(
              operation: _house.operation.copyWith(waterValveClosed: true),
            );
            _deviceState('water-valve', false);
            _audit(AuditAction.waterValveClosed);
          }
          _stage(2);
        });
      case ScenarioId.s4:
        at(0, () {
          setConnection(const DemoConnection());
          _stage(1);
        });
        at(5, () {
          setConnection(const DemoConnection(internet: false));
          _stage(2);
        });
        at(10, () {
          setConnection(const DemoConnection(atHome: false));
          _stage(3);
        });
        at(15, () {
          _stage(4);
          setConnection(const DemoConnection(atHome: false, internet: false));
        });
        at(25, () {
          setConnection(const DemoConnection());
          _stage(5);
        });
      case ScenarioId.s5:
        at(1, () {
          _house = _house.copyWith(plnAvailable: false, powerKw: 0, voltage: 0);
          _alert(AlertKind.powerOutage, AlertLevel.important);
          _audit(AuditAction.powerLost);
          _stage(1);
        });
        at(15, () {
          _house = _house.copyWith(
            plnAvailable: true,
            powerKw: _house.profile.powerKw,
            voltage: 228,
          );
          _alert(AlertKind.powerRestored, AlertLevel.info);
          _audit(AuditAction.powerRestored);
          _stage(2);
        });
      case ScenarioId.s6:
        at(1, () {
          _house = _house.copyWith(
            voltage: 264,
            powerKw: 3.15,
            powerHistory: [..._house.powerHistory, 3.15],
            operation: _house.operation.copyWith(voltageAnomaly: true),
          );
          _alert(AlertKind.voltage, AlertLevel.important);
          _audit(AuditAction.voltageAnomaly);
          _stage(1);
        });
        at(4, () {
          if (check(Feature.applianceRanking, UserRole.owner) ==
              GateDecision.available) {
            _deviceState('water-heater', false);
            _house = _house.copyWith(
              powerKw: 1.2,
              operation: _house.operation.copyWith(loadShed: true),
            );
            _alert(AlertKind.loadShed, AlertLevel.info);
            _audit(AuditAction.loadShed);
          }
          _stage(2);
        });
        at(6, () {
          _house = _house.copyWith(voltage: 196);
          _publish();
        });
        at(10, () {
          _house = _house.copyWith(voltage: 252);
          _publish();
        });
        at(20, () {
          _house = _house.copyWith(
            voltage: 228,
            operation: _house.operation.copyWith(voltageAnomaly: false),
          );
          _stage(3);
        });
      case ScenarioId.s7:
        at(0, () {
          runScene(SceneId.away, UserRole.owner);
          _stage(1);
        });
        at(2, () {
          motionAtGate();
          _stage(2);
        });
      case ScenarioId.s8:
        at(0, () {
          if (check(Feature.rentalReset, UserRole.owner) ==
              GateDecision.available) {
            issueCode(
              1,
              clock.now,
              clock.now.add(const Duration(days: 2)),
              UserRole.owner,
            );
          }
          _stage(1);
        });
        at(3, () {
          if (_house.p1.codes.isNotEmpty) {
            useCode(
              _house.p1.codes.last.id,
              UserRole.owner,
              riskConfirmed: true,
            );
          }
          _stage(2);
        });
        at(12, () {
          checkout(UserRole.owner, riskConfirmed: true);
          _stage(3);
        });
      case ScenarioId.s9:
        at(1, () {
          if (check(Feature.climate, UserRole.owner) ==
              GateDecision.available) {
            send('ac', on: true, actor: UserRole.owner, provideEvidence: false);
          }
          _stage(1);
        });
      case ScenarioId.s10:
        at(1, () {
          lowBattery();
          _stage(1);
        });
    }
    at(30, () {
      _house = _house.copyWith(
        operation: _house.operation.copyWith(scenarioRunning: false),
      );
      _publish();
    });
    runner.run(steps);
    _publish();
  }

  void stopScenario() {
    runner.stop();
    _house = _house.copyWith(
      operation: _house.operation.copyWith(scenarioRunning: false),
    );
    _publish();
  }

  void normalizeGas() {
    if (!_house.connection.reachable) return;
    _house = _house.copyWith(
      operation: _house.operation.copyWith(gasDetected: false),
    );
    _audit(AuditAction.gasNormal, source: EventSource.demo);
    _publish();
  }

  void physicalGasReset() {
    if (_house.operation.gasDetected || !_house.connection.reachable) return;
    _house = _house.copyWith(
      operation: _house.operation.copyWith(
        gasValveClosed: false,
        gasActionsApplied: false,
      ),
    );
    _deviceState('exhaust-fan', false);
    _audit(AuditAction.physicalReset, source: EventSource.demo);
    _publish();
  }

  void testDetector() {
    if (!_house.gasPowered || !_house.connection.reachable) return;
    _alert(AlertKind.detectorTest, AlertLevel.info);
    _publish();
  }

  void saveScene(ScenePlan plan, UserRole actor) {
    if (!{UserRole.owner, UserRole.family}.contains(actor) ||
        !_house.connection.reachable) {
      return;
    }
    if (plan.hour < 0 ||
        plan.hour > 23 ||
        plan.minute < 0 ||
        plan.minute > 59) {
      return;
    }
    _house = _house.copyWith(
      scenes: _house.scenes.map((p) => p.id == plan.id ? plan : p).toList(),
    );
    _audit(
      AuditAction.sceneEdited,
      source: actor == UserRole.family ? EventSource.family : EventSource.owner,
    );
    _publish();
  }

  void setMember(String id, UserRole role, bool active, UserRole actor) {
    if (actor != UserRole.owner ||
        id == 'owner' ||
        role == UserRole.owner ||
        !_house.connection.reachable) {
      return;
    }
    _house = _house.copyWith(
      members: _house.members
          .map((m) => m.id == id ? DemoMember(id, role, active: active) : m)
          .toList(),
    );
    _audit(AuditAction.memberChanged, source: EventSource.owner);
    _publish();
  }

  void inviteMember(UserRole role, UserRole actor) {
    if (actor != UserRole.owner ||
        role == UserRole.owner ||
        !_house.connection.reachable) {
      return;
    }
    _house = _house.copyWith(
      members: [
        ..._house.members,
        DemoMember('member-${_house.members.length}', role),
      ],
    );
    _audit(AuditAction.memberChanged, source: EventSource.owner);
    _publish();
  }

  void technicianAccess(bool enabled, UserRole actor) {
    if (actor != UserRole.owner || !_house.connection.reachable) return;
    _house = _house.copyWith(
      operation: _house.operation.copyWith(
        technicianUntil: enabled
            ? clock.now.add(const Duration(minutes: 30))
            : null,
        revokeTechnician: !enabled,
      ),
    );
    _audit(
      enabled ? AuditAction.technicianGranted : AuditAction.technicianRevoked,
      source: EventSource.owner,
    );
    _publish();
  }

  void armAlarm(bool armed, UserRole actor, {bool riskConfirmed = false}) {
    if (check(Feature.alarm, actor) != GateDecision.available ||
        !_house.connection.reachable ||
        !_house.plnAvailable ||
        (!armed && !riskConfirmed)) {
      return;
    }
    _house = _house.copyWith(
      operation: _house.operation.copyWith(alarmArmed: armed),
    );
    _audit(
      armed ? AuditAction.alarmArmed : AuditAction.alarmDisarmed,
      source: actor == UserRole.family ? EventSource.family : EventSource.owner,
    );
    _publish();
  }

  void tickP0() {
    final until = _house.operation.technicianUntil;
    if (until != null && !until.isAfter(clock.now)) {
      _house = _house.copyWith(
        operation: _house.operation.copyWith(revokeTechnician: true),
      );
      _audit(AuditAction.technicianRevoked);
      _publish();
    }
    final local = clock.now.toUtc().add(const Duration(hours: 8));
    final key =
        '${local.year}-${local.month}-${local.day}-${local.hour}-${local.minute}';
    if (key == _scheduledMinute) return;
    _scheduledMinute = key;
    for (final p in _house.scenes.where(
      (p) => p.scheduled && p.hour == local.hour && p.minute == local.minute,
    )) {
      // Schedules run inside the home even when the phone cannot reach it.
      runScene(p.id, UserRole.owner, automatic: true);
    }
  }
}
