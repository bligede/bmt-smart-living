import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/feature_gate.dart';
import '../domain/models.dart';
import '../domain/repositories.dart';
import 'notifications.dart';

final repositoriesProvider = Provider<Repositories>(
  (ref) => throw StateError('Repository override required'),
);
final preferencesProvider = Provider<SharedPreferences?>((ref) => null);

class DemoSession {
  const DemoSession({
    required this.home,
    this.role = UserRole.owner,
    this.condition = ViewCondition.normal,
    this.galleryCondition = ViewCondition.normal,
    this.showLocked = true,
    this.theme = ThemeMode.light,
    this.language = 'id',
    this.reduceMotion = false,
    this.night = false,
    this.speed = 1,
    this.evidence = true,
  });
  final HomeSnapshot home;
  final UserRole role;
  final ViewCondition condition, galleryCondition;
  final bool showLocked, reduceMotion, night, evidence;
  final ThemeMode theme;
  final String language;
  final int speed;
  DemoSession copyWith({
    HomeSnapshot? home,
    UserRole? role,
    ViewCondition? condition,
    ViewCondition? galleryCondition,
    bool? showLocked,
    ThemeMode? theme,
    String? language,
    bool? reduceMotion,
    bool? night,
    int? speed,
    bool? evidence,
  }) => DemoSession(
    home: home ?? this.home,
    role: role ?? this.role,
    condition: condition ?? this.condition,
    galleryCondition: galleryCondition ?? this.galleryCondition,
    showLocked: showLocked ?? this.showLocked,
    theme: theme ?? this.theme,
    language: language ?? this.language,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    night: night ?? this.night,
    speed: speed ?? this.speed,
    evidence: evidence ?? this.evidence,
  );
}

final demoProvider = NotifierProvider<DemoController, DemoSession>(
  DemoController.new,
);

class DemoController extends Notifier<DemoSession> {
  Repositories get _repos => ref.read(repositoriesProvider);
  SharedPreferences? get _prefs => ref.read(preferencesProvider);
  @override
  DemoSession build() {
    final repos = ref.watch(repositoriesProvider),
        prefs = ref.read(preferencesProvider);
    final subscription = repos.home.watchHome().listen((home) {
      state = state.copyWith(home: home);
    });
    ref.onDispose(subscription.cancel);
    return DemoSession(
      home: repos.home.current,
      theme: ThemeMode.values.byName(prefs?.getString('theme') ?? 'light'),
      language: prefs?.getString('language') ?? 'id',
      reduceMotion: prefs?.getBool('reduceMotion') ?? false,
      showLocked: prefs?.getBool('showLocked') ?? true,
    );
  }

  void profile(String id) {
    unawaited(ref.read(notificationsProvider).clear());
    _repos.home.selectProfile(id);
    state = state.copyWith(condition: ViewCondition.normal, night: false);
  }

  void tier(PackageTier tier) => _repos.home.setTier(tier);
  void role(UserRole role) {
    if (role != state.role) unawaited(ref.read(notificationsProvider).clear());
    state = state.copyWith(role: role);
  }

  void connection({bool? atHome, bool? internet}) => _repos.home.setConnection(
    DemoConnection(
      atHome: atHome ?? state.home.connection.atHome,
      internet: internet ?? state.home.connection.internet,
    ),
  );
  void theme(ThemeMode value) {
    state = state.copyWith(theme: value);
    unawaited(_prefs?.setString('theme', value.name));
  }

  void language(String value) {
    state = state.copyWith(language: value);
    unawaited(_prefs?.setString('language', value));
  }

  void motion(bool value) {
    state = state.copyWith(reduceMotion: value);
    unawaited(_prefs?.setBool('reduceMotion', value));
  }

  void locked(bool value) {
    state = state.copyWith(showLocked: value);
    unawaited(_prefs?.setBool('showLocked', value));
  }

  void condition(ViewCondition value) =>
      state = state.copyWith(condition: value);
  void galleryCondition(ViewCondition value) =>
      state = state.copyWith(galleryCondition: value);
  void evidence(bool value) => state = state.copyWith(evidence: value);
  void clock({bool? night, int? speed}) {
    state = state.copyWith(night: night, speed: speed);
    _repos.home.setClock(night: state.night, speed: state.speed);
  }

  void reset() {
    unawaited(ref.read(notificationsProvider).clear());
    _repos.home.reset();
    state = state.copyWith(
      condition: ViewCondition.normal,
      galleryCondition: ViewCondition.normal,
      evidence: true,
      night: false,
    );
    _repos.home.setClock(night: false, speed: state.speed);
  }

  GateDecision gate(Feature feature) =>
      state.role == UserRole.family &&
          !state.home.members.any((m) => m.active && m.role == UserRole.family)
      ? GateDecision.forbidden
      : const FeatureGate().check(
          feature,
          state.home.tier,
          state.home.profile.kind,
          state.role,
        );
  List<Device> get devices => _repos.devices.devicesFor(state.role);
  List<CameraId> get cameras => _repos.cameras.camerasFor(state.role);
  List<HomeAlert> get alerts => _repos.alerts.alertsFor(state.role);
  DeviceCommand send(
    Device d, {
    required bool on,
    bool riskConfirmed = false,
    double? value,
  }) => _repos.devices.send(
    d.id,
    on: on,
    actor: state.role,
    provideEvidence: state.evidence,
    riskConfirmed: riskConfirmed,
    value: value,
  );
  void scene(SceneId scene) => _repos.devices.runScene(scene, state.role);
  void wallSwitch(String id) => _repos.devices.wallSwitch(id);
  void previewCritical() => _repos.alerts.previewCritical();
  void acknowledge(int id) => _repos.alerts.acknowledge(id, state.role);
  void scenario(ScenarioId id) {
    unawaited(ref.read(notificationsProvider).clear());
    state = state.copyWith(
      condition: ViewCondition.normal,
      night: id == ScenarioId.s1,
      role: UserRole.owner,
      evidence: id == ScenarioId.s9 ? false : state.evidence,
    );
    _repos.home.runScenario(id, provideEvidence: state.evidence);
  }

  void stopScenario() => _repos.home.stopScenario();
  void normalizeGas() => _repos.home.normalizeGas();
  void physicalGasReset() => _repos.home.physicalGasReset();
  void testDetector() => _repos.home.testDetector();
  void saveScene(ScenePlan plan) => _repos.devices.saveScene(plan, state.role);
  void setMember(String id, UserRole role, bool active) =>
      _repos.access.setMember(id, role, active, state.role);
  void technicianAccess(bool enabled) =>
      _repos.access.technicianAccess(enabled, state.role);
  void armAlarm(bool armed, {bool riskConfirmed = false}) =>
      _repos.access.armAlarm(armed, state.role, riskConfirmed: riskConfirmed);
}

class NotificationPreferences {
  const NotificationPreferences({
    this.important = true,
    this.info = true,
    this.quiet = false,
  });
  final bool important, info, quiet;
}

final notificationPreferencesProvider =
    NotifierProvider<
      NotificationPreferencesController,
      NotificationPreferences
    >(NotificationPreferencesController.new);

class NotificationPreferencesController
    extends Notifier<NotificationPreferences> {
  @override
  NotificationPreferences build() {
    final p = ref.read(preferencesProvider);
    return NotificationPreferences(
      important: p?.getBool('notifyImportant') ?? true,
      info: p?.getBool('notifyInfo') ?? true,
      quiet: p?.getBool('quietHours') ?? false,
    );
  }

  void update({bool? important, bool? info, bool? quiet}) {
    state = NotificationPreferences(
      important: important ?? state.important,
      info: info ?? state.info,
      quiet: quiet ?? state.quiet,
    );
    final p = ref.read(preferencesProvider);
    unawaited(p?.setBool('notifyImportant', state.important));
    unawaited(p?.setBool('notifyInfo', state.info));
    unawaited(p?.setBool('quietHours', state.quiet));
  }
}
