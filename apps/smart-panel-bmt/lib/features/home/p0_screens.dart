import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/widgets/controls.dart';
import '../../core/widgets/visuals.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';

class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider), c = ref.read(demoProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ConnectionBadge(s.home.connection.path),
          ),
          const SizedBox(height: 20),
          ConditionView(
            condition: s.condition,
            onRetry: () => c.condition(ViewCondition.normal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class RoomDetailScreen extends ConsumerWidget {
  const RoomDetailScreen(this.room, {super.key});
  final RoomId room;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(demoProvider);
    final c = ref.read(demoProvider.notifier), l = context.l;
    final devices = c.devices.where((d) => d.room == room).toList();
    return ReviewPage(
      title: l.roomName(room),
      children: [
        Text('${l.temperature} 26° · ${l.humidity} 68%'),
        const SizedBox(height: 16),
        if (devices.isEmpty) StateMessage(title: l.noData, body: l.noDataBody),
        for (final d in devices) ...[
          DeviceControl(d, detailLink: true),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class DeviceDetailScreen extends ConsumerWidget {
  const DeviceDetailScreen(this.id, {super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final matches = c.devices.where((d) => d.id == id);
    if (matches.isEmpty) {
      return ReviewPage(
        title: l.deviceDetail,
        children: [StateMessage(title: l.noPermission)],
      );
    }
    final d = matches.first;
    return ReviewPage(
      title: l.deviceName(d.kind),
      children: [
        DeviceControl(d),
        const SizedBox(height: 20),
        BmtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.roomName(d.room)),
              const SizedBox(height: 8),
              Text(d.cloud ? l.cloudDependent : l.local),
              const SizedBox(height: 8),
              Text(l.deviceModel),
              Text(l.deviceBrand),
              Text('${l.signal}: ${l.good}'),
              const SizedBox(height: 8),
              Text(
                '${l.deviceLastSeen}: ${context.houseTime(s.home.time)} ${l.wita}',
              ),
              if (d.kind == DeviceKind.doorLock) Text('${l.battery} 82%'),
              if (d.kind == DeviceKind.doorSensor) ...[
                Text('${l.battery}: ${s.home.p1.batteryPercent}%'),
                Text(
                  '${l.batteryEstimate}: ${s.home.p1.batteryDays} ${l.days}',
                ),
              ],
              if (d.oneWay) Text(l.oneWayNote),
              if (d.kind == DeviceKind.kitchenPlug)
                Text(
                  '${l.consumption}: ${context.number(d.status == DeviceStatus.off || d.status == DeviceStatus.noPower ? 0 : d.value)} W',
                ),
            ],
          ),
        ),
        SectionTitle(l.deviceHistory),
        for (final e
            in s.home.history.reversed
                .where((e) => e.device == d.kind)
                .take(20))
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              e.phase == null ? l.deviceName(d.kind) : l.commandName(e.phase!),
            ),
            subtitle: Text(
              '${context.houseTime(e.time)} · ${l.sourceName(e.source)}${e.targetOn == null ? '' : ' · ${e.targetOn! ? l.on : l.off}'}',
            ),
          ),
        if (!s.home.history.any((e) => e.device == d.kind))
          StateMessage(title: l.noHistory),
      ],
    );
  }
}

class DeviceControl extends ConsumerStatefulWidget {
  const DeviceControl(this.device, {super.key, this.detailLink = false});
  final Device device;
  final bool detailLink;
  @override
  ConsumerState<DeviceControl> createState() => _DeviceControlState();
}

class _DeviceControlState extends ConsumerState<DeviceControl> {
  double? _value;
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l,
        d = widget.device;
    final command = s.home.commandFor(d.id), on = d.status == DeviceStatus.on;
    final enabled =
        s.home.connection.canControl(cloud: d.cloud) &&
        d.status != DeviceStatus.noPower &&
        command?.phase != CommandPhase.sent;
    final sensor = d.capabilities.contains(Capability.sensor);
    final risk =
        d.capabilities.contains(Capability.lock) ||
        d.kind == DeviceKind.waterValve ||
        d.kind == DeviceKind.alarmSiren ||
        d.kind == DeviceKind.kitchenCircuit ||
        d.kind == DeviceKind.waterHeater;
    void send(bool target, {double? value}) {
      if (risk) {
        showRiskConfirmation(
          context,
          title: l.riskAction,
          consequence: d.kind == DeviceKind.kitchenCircuit
              ? l.circuitRisk
              : d.kind == DeviceKind.waterValve
              ? (target ? l.valveConsequence : l.valveCloseConsequence)
              : l.riskConsequence,
          onConfirmed: () =>
              c.send(d, on: target, riskConfirmed: true, value: value),
        );
      } else {
        c.send(d, on: target, value: value);
      }
    }

    final adjustable =
        d.capabilities.contains(Capability.dimmer) ||
        d.capabilities.contains(Capability.climate) ||
        d.capabilities.contains(Capability.curtain);
    final climate = d.capabilities.contains(Capability.climate),
        curtain = d.capabilities.contains(Capability.curtain);
    final current = (_value ?? d.value).clamp(
      climate ? 16.0 : 0.0,
      climate ? 30.0 : 100.0,
    );
    return BmtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.deviceName(d.kind),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            d.status == DeviceStatus.noPower ||
                    d.status == DeviceStatus.unreachable ||
                    d.status == DeviceStatus.lowBattery
                ? l.deviceStatus(d.status)
                : sensor
                ? (d.kind == DeviceKind.leakSensor
                      ? (s.home.operation.wetSensor
                            ? l.wetLocation
                            : l.sensorDry)
                      : l.sensorClosed)
                : d.kind == DeviceKind.waterValve ||
                      d.kind == DeviceKind.gateMotor
                ? (on ? l.openState : l.closedState)
                : curtain
                ? '${l.curtainPosition}: ${context.number(d.value)}%'
                : d.capabilities.contains(Capability.lock)
                ? (on ? l.unlockedDoor : l.lockedDoor)
                : l.deviceStatus(d.status),
          ),
          Text(
            '${l.source}: ${l.sourceName(d.source)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (!sensor) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: enabled ? () => send(!on) : null,
              icon: Icon(
                d.capabilities.contains(Capability.lock)
                    ? Icons.lock_outline
                    : Icons.power_settings_new,
              ),
              label: Text(
                d.kind == DeviceKind.waterValve ||
                        d.kind == DeviceKind.gateMotor
                    ? (on ? l.close : l.open)
                    : d.capabilities.contains(Capability.lock)
                    ? (on ? l.lock : l.unlock)
                    : curtain
                    ? (on ? l.close : l.open)
                    : (on ? l.turnOff : l.turnOn),
              ),
            ),
          ],
          if (adjustable) ...[
            const SizedBox(height: 12),
            Text(
              '${climate
                  ? l.temperature
                  : curtain
                  ? l.curtainPosition
                  : l.brightness}: ${context.number(current)}${climate ? '°C' : '%'}',
            ),
            Slider(
              value: current,
              min: climate ? 16 : 0,
              max: climate ? 30 : 100,
              divisions: climate ? 14 : 100,
              label: context.number(current),
              onChanged: enabled ? (v) => setState(() => _value = v) : null,
              onChangeEnd: enabled
                  ? (v) {
                      send(curtain ? v > 0 : true, value: v);
                      setState(() => _value = null);
                    }
                  : null,
            ),
          ],
          if (command != null)
            CommandLine(
              command,
              onRetry: enabled
                  ? () => send(command.targetOn, value: command.targetValue)
                  : null,
            ),
          if (!enabled)
            Text(
              l.deviceStatus(d.status),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (widget.detailLink)
            TextButton.icon(
              onPressed: () => context.push('/device/${d.id}'),
              icon: const Icon(Icons.arrow_forward),
              label: Text(l.deviceDetail),
            ),
        ],
      ),
    );
  }
}

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    return ReviewPage(
      title: l.scenes,
      children: [
        Text(l.scheduleLocal),
        const SizedBox(height: 20),
        for (final p in s.home.scenes) ...[
          BmtCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.sceneName(p.id),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('${l.lights}: ${p.lightsOn ? l.on : l.off}'),
                if (c.gate(Feature.climate) == GateDecision.available)
                  Text('${l.climate}: ${p.acOn ? l.on : l.off}'),
                if (p.scheduled)
                  Text(
                    '${l.schedule}: ${TimeOfDay(hour: p.hour, minute: p.minute).format(context)} ${l.wita}',
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: s.home.connection.reachable
                          ? () => c.scene(p.id)
                          : null,
                      child: Text(l.runScene),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push('/scene/${p.id.name}'),
                      child: Text(l.editScene),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class SceneEditorScreen extends ConsumerStatefulWidget {
  const SceneEditorScreen(this.scene, {super.key});
  final SceneId scene;
  @override
  ConsumerState<SceneEditorScreen> createState() => _SceneEditorState();
}

class _SceneEditorState extends ConsumerState<SceneEditorScreen> {
  late bool _lights, _ac, _curtain, _scheduled;
  late TimeOfDay _time;
  @override
  void initState() {
    super.initState();
    final p = ref
        .read(demoProvider)
        .home
        .scenes
        .firstWhere((p) => p.id == widget.scene);
    _lights = p.lightsOn;
    _ac = p.acOn;
    _curtain = p.curtainOpen;
    _scheduled = p.scheduled;
    _time = TimeOfDay(hour: p.hour, minute: p.minute);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    return ReviewPage(
      title: l.editScene,
      children: [
        Text(
          l.sceneName(widget.scene),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.lightsOn),
          value: _lights,
          onChanged: (v) => setState(() => _lights = v),
        ),
        if (c.gate(Feature.climate) == GateDecision.available)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.acOn),
            value: _ac,
            onChanged: (v) => setState(() => _ac = v),
          ),
        if (c.gate(Feature.curtains) == GateDecision.available)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.curtainOpen),
            value: _curtain,
            onChanged: (v) => setState(() => _curtain = v),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.schedule),
          value: _scheduled,
          onChanged: (v) => setState(() => _scheduled = v),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.scheduleTime),
          subtitle: Text('${_time.format(context)} ${l.wita}'),
          trailing: const Icon(Icons.schedule),
          onTap: () async {
            final t = await showTimePicker(
              context: context,
              initialTime: _time,
            );
            if (t != null && mounted) setState(() => _time = t);
          },
        ),
        Text(l.scheduleLocal),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: s.home.connection.reachable
              ? () {
                  c.saveScene(
                    ScenePlan(
                      widget.scene,
                      lightsOn: _lights,
                      acOn: _ac,
                      curtainOpen: _curtain,
                      scheduled: _scheduled,
                      hour: _time.hour,
                      minute: _time.minute,
                    ),
                  );
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/scenes');
                  }
                }
              : null,
          child: Text(l.save),
        ),
      ],
    );
  }
}

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    if (c.gate(Feature.members) != GateDecision.available) {
      return ReviewPage(
        title: l.members,
        children: [StateMessage(title: l.noPermission)],
      );
    }
    final until = s.home.operation.technicianUntil;
    return ReviewPage(
      title: l.members,
      children: [
        FilledButton.icon(
          onPressed: s.home.connection.reachable
              ? () => ref
                    .read(repositoriesProvider)
                    .access
                    .inviteMember(UserRole.family, s.role)
              : null,
          icon: const Icon(Icons.person_add_outlined),
          label: Text(l.inviteMember),
        ),
        const SizedBox(height: 16),
        for (final m in s.home.members) ...[
          BmtCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.id == 'owner'
                      ? l.memberOwner
                      : m.id == 'family'
                      ? l.memberFamily
                      : m.id == 'technician'
                      ? l.memberTechnician
                      : '${l.demoMember} ${m.id.split('-').last}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(l.roleName(m.role)),
                const SizedBox(height: 8),
                if (m.id == 'owner') Text(l.memberActive),
                if (m.id != 'owner' && m.id != 'technician')
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(m.active ? l.memberActive : l.memberInactive),
                    value: m.active,
                    onChanged: s.home.connection.reachable
                        ? (v) => c.setMember(m.id, m.role, v)
                        : null,
                  ),
                if (m.id != 'owner' && m.id != 'technician')
                  DropdownButtonFormField<UserRole>(
                    key: ValueKey('${m.id}-${m.role}'),
                    initialValue: m.role,
                    decoration: InputDecoration(labelText: l.changeRole),
                    items: [
                      for (final role in [
                        UserRole.family,
                        UserRole.guest,
                        UserRole.technician,
                      ])
                        DropdownMenuItem(
                          value: role,
                          child: Text(l.roleName(role)),
                        ),
                    ],
                    onChanged: s.home.connection.reachable
                        ? (role) {
                            if (role != null) c.setMember(m.id, role, m.active);
                          }
                        : null,
                  ),
                if (m.id == 'technician') ...[
                  Text(l.technicianScope),
                  const SizedBox(height: 12),
                  Text(
                    until == null
                        ? l.accessExpired
                        : '${l.validUntil} ${context.houseTime(until)} ${l.wita}',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: s.home.connection.reachable
                        ? () => c.technicianAccess(until == null)
                        : null,
                    child: Text(until == null ? l.grant : l.revoke),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(notificationPreferencesProvider),
        c = ref.read(notificationPreferencesProvider.notifier),
        l = context.l;
    return ReviewPage(
      title: l.notificationSettings,
      children: [
        Text(l.criticalAlways),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.notifyImportant),
          value: p.important,
          onChanged: (v) => c.update(important: v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.notifyInfo),
          value: p.info,
          onChanged: (v) => c.update(info: v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.quietHours),
          value: p.quiet,
          onChanged: (v) => c.update(quiet: v),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.push('/settings'),
          child: Text(l.notificationTest),
        ),
      ],
    );
  }
}

class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen(this.id, {super.key});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final matches = c.alerts.where((a) => a.id == id);
    if (matches.isEmpty) {
      return ReviewPage(
        title: l.alertDetail,
        children: [StateMessage(title: l.noData)],
      );
    }
    final a = matches.first, o = s.home.operation;
    final active = switch (a.kind) {
      AlertKind.gasLeak => o.gasDetected,
      AlertKind.waterLeak => o.wetSensor,
      AlertKind.powerOutage => !s.home.plnAvailable,
      AlertKind.voltage => o.voltageAnomaly,
      AlertKind.lowBattery => s.home.devices.any(
        (d) =>
            d.kind == DeviceKind.doorSensor &&
            d.status == DeviceStatus.lowBattery,
      ),
      _ => false,
    };
    return ReviewPage(
      title: l.alertDetail,
      children: [
        SmallBadge(l.levelName(a.level)),
        const SizedBox(height: 16),
        Text(
          l.alertName(a.kind),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          '${context.houseDate(a.time)} ${context.houseTime(a.time)} ${l.wita}',
        ),
        const SizedBox(height: 16),
        Text(active ? l.activeSource : l.resolvedSource),
        if (a.kind == AlertKind.gasLeak) ...[
          const SizedBox(height: 16),
          Text(l.safetyPending),
          Text(l.gasSimulationOnly),
          if (o.gasActionsApplied) Text(l.gasActionsApplied),
          if (o.gasValveClosed) Text(l.gasValveClosed),
        ],
        if (a.kind == AlertKind.waterLeak) ...[
          Text(l.wetLocation),
          if (o.abnormalFlow) Text(l.abnormalFlow),
          if (o.waterValveClosed) Text(l.twoSources),
        ],
        if (a.kind == AlertKind.powerOutage) Text(l.backup90),
        if (a.kind == AlertKind.lowBattery) ...[
          Text('${l.battery}: ${s.home.p1.batteryPercent}%'),
          Text('${l.batteryEstimate}: ${s.home.p1.batteryDays} ${l.days}'),
          OutlinedButton(
            onPressed: () => context.push('/device/door-sensor'),
            child: Text(l.doorSensor),
          ),
        ],
        if (a.camera != null && c.cameras.contains(a.camera)) ...[
          const SizedBox(height: 16),
          const AspectRatio(
            aspectRatio: 16 / 9,
            child: CustomPaint(painter: CameraIllustration()),
          ),
          OutlinedButton.icon(
            onPressed: () => context.push('/camera/${a.camera!.name}'),
            icon: const Icon(Icons.videocam_outlined),
            label: Text(l.openLive),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: !a.acknowledged && s.home.connection.reachable
              ? () => c.acknowledge(a.id)
              : null,
          child: Text(a.acknowledged ? l.alreadyAcknowledged : l.acknowledge),
        ),
        const SizedBox(height: 12),
        Text(l.acknowledgeNote),
      ],
    );
  }
}
