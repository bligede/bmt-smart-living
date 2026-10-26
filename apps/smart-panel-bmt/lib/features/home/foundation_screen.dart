import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/widgets/surfaces.dart';
import '../../core/widgets/visuals.dart';
import '../../domain/models.dart';
import 'p0_screens.dart';

class FoundationScreen extends ConsumerStatefulWidget {
  const FoundationScreen(this.foundation, {super.key});
  final Foundation foundation;
  @override
  ConsumerState<FoundationScreen> createState() => _FoundationScreenState();
}

class _FoundationScreenState extends ConsumerState<FoundationScreen> {
  ChartPeriod _period = ChartPeriod.day;
  Foundation get foundation => widget.foundation;
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        h = s.home,
        l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.foundationName(foundation))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ConnectionBadge(h.connection.path),
          ),
          const SizedBox(height: 20),
          ConditionView(
            condition: s.condition,
            onRetry: () => c.condition(ViewCondition.normal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: switch (foundation) {
                Foundation.electricity => [
                  BmtCard(
                    color: const Color(0xFF282828),
                    borderColor: const Color(0xFF282828),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.currentPower,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: const Color(0xFFF2F4F3)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${context.number(h.powerKw, decimals: 2)} kW',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: const Color(0xFF04FB2D)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${l.voltage} ${context.number(h.voltage)} V · ${l.installedPower} 3.500 VA',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFFF2F4F3)),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: h.powerKw / 3.5,
                          color: const Color(0xFF04FB2D),
                          backgroundColor: const Color(0xFF4A4848),
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(l.consumption),
                  Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      _metric(
                        context,
                        l.today,
                        '${context.number(h.todayKwh, decimals: 1)} kWh',
                      ),
                      _metric(
                        context,
                        l.thisMonth,
                        '${context.number(h.profile.monthKwh)} kWh',
                      ),
                    ],
                  ),
                  SectionTitle(l.powerTrend),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in ChartPeriod.values)
                        ChoiceChip(
                          label: Text(
                            p == ChartPeriod.day
                                ? l.today
                                : p == ChartPeriod.week
                                ? l.thisWeek
                                : l.thisMonth,
                          ),
                          selected: p == _period,
                          onSelected: (_) => setState(() => _period = p),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_period == ChartPeriod.day ? 'kW' : 'kWh'),
                  if (h.operation.scenario == ScenarioId.s6)
                    BmtCard(child: Text(l.graphMarker)),
                  if (h.powerKw >= 2.975) Text(l.loadWarning),
                  const SizedBox(height: 16),
                  PowerChart(
                    maxY: _period == ChartPeriod.day ? 3.5 : 20,
                    anomaly: h.operation.scenario == ScenarioId.s6,
                    values: ref
                        .read(repositoriesProvider)
                        .energy
                        .historyFor(s.role, period: _period),
                    reduceMotion: s.reduceMotion,
                  ),
                  const SizedBox(height: 16),
                  FeaturePreview(
                    feature: Feature.circuits,
                    child: BmtCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.circuits,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            h.operation.scenario == ScenarioId.s6
                                ? l.circuitKitchen
                                : l.circuitSockets,
                          ),
                          const SizedBox(height: 8),
                          Text(l.circuitLights),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeaturePreview(
                    feature: Feature.applianceRanking,
                    child: BmtCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.applianceRanking,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(l.rankingSample),
                          if (h.operation.loadShed) Text(l.loadShed),
                          for (final d in c.devices.where(
                            (d) =>
                                d.kind == DeviceKind.waterHeater ||
                                d.kind == DeviceKind.kitchenCircuit,
                          ))
                            TextButton(
                              onPressed: () => context.push('/device/${d.id}'),
                              child: Text(l.deviceName(d.kind)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                Foundation.water => [
                  if (h.profile.hasTank) TankGauge(percent: h.tankPercent),
                  Text(l.tankCapacity),
                  SectionTitle(l.today),
                  _metric(context, l.consumption, '${h.profile.waterLitres} L'),
                  const SizedBox(height: 20),
                  BmtCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h.operation.wetSensor ? l.wetLocation : l.noLeak),
                        const SizedBox(height: 8),
                        Text(
                          h.operation.abnormalFlow &&
                                  !h.operation.waterValveClosed
                              ? l.abnormalFlow
                              : l.waterSummary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FeaturePreview(
                    feature: Feature.waterZones,
                    child: BmtCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.waterZoneValues),
                          const SizedBox(height: 12),
                          Text('${l.quality}: 142 ppm · ${l.good}'),
                          for (final d in c.devices.where(
                            (d) => d.kind == DeviceKind.pump,
                          ))
                            TextButton(
                              onPressed: () => context.push('/device/${d.id}'),
                              child: Text(l.pump),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeaturePreview(
                    feature: Feature.waterValve,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (h.operation.waterValveClosed)
                          BmtCard(child: Text(l.twoSources)),
                        const SizedBox(height: 12),
                        for (final d in c.devices.where(
                          (d) => d.kind == DeviceKind.waterValve,
                        ))
                          DeviceControl(d, detailLink: true),
                      ],
                    ),
                  ),
                ],
                Foundation.wifi => [
                  BmtCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.connection.internet ? l.connected : l.disconnected,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${h.profile.wifiDevices} ${l.devices} · ${l.latency} 18 ms',
                        ),
                        const SizedBox(height: 8),
                        Text(l.wifiNetworkSample),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FeaturePreview(
                    feature: Feature.guestWifi,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GuestWifiQr(version: h.operation.wifiVersion),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: h.connection.reachable
                              ? () => showDialog<void>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: Text(l.rotateWifi),
                                    content: Text(l.wifiRotateRisk),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: Text(l.cancel),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          ref
                                              .read(repositoriesProvider)
                                              .guests
                                              .rotateWifi(s.role);
                                          Navigator.pop(dialogContext);
                                        },
                                        child: Text(l.save),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                          child: Text(l.rotateWifi),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeaturePreview(
                    feature: Feature.guestRotation,
                    child: BmtCard(child: Text(l.rotationSample)),
                  ),
                ],
                Foundation.gas => [
                  BmtCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          !h.gasPowered
                              ? l.gasNoPower
                              : h.operation.gasDetected
                              ? l.gasLeak
                              : l.safe,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(l.detectorExplanation),
                        const SizedBox(height: 12),
                        Text(l.lastTest),
                        if (h.gasPowered)
                          Text(
                            h.operation.gasDetected ? l.gasDetected : l.gasZero,
                          ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: h.connection.reachable && h.gasPowered
                              ? () {
                                  c.testDetector();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l.detectorTestDone)),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.volume_up_outlined),
                          label: Text(l.testAlarm),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FeaturePreview(
                    feature: Feature.gasActions,
                    child: BmtCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.operation.gasActionsApplied
                                ? l.gasActionsApplied
                                : l.gasActions,
                          ),
                          const SizedBox(height: 12),
                          Text(l.gasSimulationOnly),
                          Text(l.safetyPending),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeaturePreview(
                    feature: Feature.gasValve,
                    child: BmtCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.operation.gasValveClosed
                                ? l.gasValveClosed
                                : l.gasValveOpen,
                          ),
                          const SizedBox(height: 12),
                          Text(l.s2ResetNote),
                        ],
                      ),
                    ),
                  ),
                  SectionTitle(l.history),
                  for (final e
                      in h.history.reversed
                          .where(
                            (e) => {
                              AuditAction.gasDetected,
                              AuditAction.gasActions,
                              AuditAction.gasValveClosed,
                              AuditAction.gasNormal,
                              AuditAction.physicalReset,
                            }.contains(e.action),
                          )
                          .take(8))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.auditName(e.action!)),
                      subtitle: Text(
                        '${context.houseTime(e.time)} · ${l.sourceName(e.source)}',
                      ),
                    ),
                ],
                Foundation.cctv => [
                  if (c.cameras.contains(CameraId.living))
                    FeaturePreview(
                      feature: Feature.recording,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.privacyMode),
                        value: h.operation.indoorPrivacy,
                        onChanged: h.connection.reachable
                            ? (v) => ref
                                  .read(repositoriesProvider)
                                  .cameras
                                  .setIndoorPrivacy(v, s.role)
                            : null,
                      ),
                    ),
                  for (final camera in c.cameras) ...[
                    CameraTile(
                      name: l.cameraName(camera),
                      time: context.houseTime(h.time, seconds: true),
                      online: h.connection.reachable && h.plnAvailable,
                      onTap: () => context.push('/camera/${camera.name}'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (c.cameras.isEmpty)
                    StateMessage(
                      title: l.noPermission,
                      icon: Icons.lock_outline_rounded,
                    ),
                  BmtCard(child: Text(l.motionEvent)),
                  const SizedBox(height: 12),
                  FeaturePreview(
                    feature: Feature.recording,
                    child: BmtCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.recordingSummary),
                          Text(l.doorbellEvent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FeaturePreview(
                    feature: Feature.personDetection,
                    child: BmtCard(child: Text(l.personZone)),
                  ),
                ],
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(value, style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}

class FeaturePreview extends ConsumerWidget {
  const FeaturePreview({super.key, required this.feature, required this.child});
  final Feature feature;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        gate = ref.read(demoProvider.notifier).gate(feature);
    if (gate == GateDecision.forbidden) return const SizedBox.shrink();
    if (gate == GateDecision.locked) {
      return s.showLocked
          ? StateMessage(
              title: context.l.featureName(feature),
              icon: Icons.lock_outline_rounded,
            )
          : const SizedBox.shrink();
    }
    return child;
  }
}
