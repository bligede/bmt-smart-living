import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/tokens.dart';
import '../../core/widgets/controls.dart';
import '../../core/widgets/surfaces.dart';
import '../../core/widgets/visuals.dart';
import '../../domain/models.dart';
import '../demo/demo_panel.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});
  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  int? _section;
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final examples = <(String, Widget)>[
      (
        l.statusCard,
        HomeStatusCard(snapshot: s.home, onDetails: () => c.previewCritical()),
      ),
      (
        l.connectionChip,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final path in ConnectionPath.values) ConnectionBadge(path),
          ],
        ),
      ),
      (
        l.foundationCard,
        FoundationTile(
          foundation: Foundation.electricity,
          value: '${context.number(s.home.powerKw, decimals: 2)} kW',
          status: l.normal,
          onTap: () {},
        ),
      ),
      (
        l.deviceTile,
        DeviceTile(
          device: Device(
            id: 'preview',
            kind: DeviceKind.mainLight,
            room: RoomId.living,
            capabilities: const {Capability.switchable},
            status: DeviceStatus.on,
          ),
          enabled: true,
          onToggle: (_) => _feedback(l.sampleOnly),
        ),
      ),
      (l.dimmer, const _SliderExample()),
      (l.climateCard, const _ClimateExample()),
      (l.curtainControl, const _SliderExample(curtain: true)),
      (
        l.lockControl,
        BmtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.lockedDoor,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text('${l.battery} 82%'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => showRiskConfirmation(
                  context,
                  title: l.unlockQuestion,
                  consequence: l.unlockConsequence,
                  onConfirmed: () => _feedback(l.confirmed),
                ),
                icon: const Icon(Icons.lock_open_rounded),
                label: Text(l.unlock),
              ),
            ],
          ),
        ),
      ),
      (
        l.scenePills,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final scene in SceneId.values)
              ActionChip(
                label: Text(l.sceneName(scene)),
                onPressed: () => _feedback(l.sampleOnly),
              ),
          ],
        ),
      ),
      (
        l.alertCards,
        Column(
          children: [
            for (final level in AlertLevel.values) ...[
              AlertCard(
                level: level,
                title: l.alertName(switch (level) {
                  AlertLevel.critical => AlertKind.sampleCritical,
                  AlertLevel.important => AlertKind.voltage,
                  AlertLevel.info => AlertKind.lowBattery,
                }),
                subtitle: '14.07 · ${l.simulation}',
                onTap: () => _feedback(l.sampleOnly),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      (
        l.criticalTitle,
        FilledButton.icon(
          onPressed: c.previewCritical,
          icon: const Icon(Icons.warning_amber_rounded),
          label: Text(l.openEmergency),
        ),
      ),
      (
        l.charts,
        BmtCard(
          child: Column(
            children: [
              PowerChart(
                values: s.home.powerHistory,
                reduceMotion: s.reduceMotion,
              ),
              const SizedBox(height: 24),
              PowerChart(
                values: s.home.powerHistory,
                reduceMotion: s.reduceMotion,
                bars: true,
              ),
            ],
          ),
        ),
      ),
      (
        l.powerGauge,
        BmtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.number(s.home.powerKw, decimals: 2)} kW / 3,5 kVA',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: s.home.powerKw / 3.5,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
      (l.tankLevel, TankGauge(percent: s.home.tankPercent)),
      (
        l.cameraTile,
        CameraTile(
          name: l.frontGate,
          time: context.houseTime(s.home.time),
          online: true,
          onTap: () => _feedback(l.simulation),
        ),
      ),
      (l.timeline, const _TimelineExample()),
      (l.guestCode, const GuestCodeCard()),
      (l.guestWifi, const GuestWifiQr()),
      (
        l.roleBadges,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final role in UserRole.values)
              SmallBadge(
                l.roleName(role),
                icon: role == UserRole.owner
                    ? Icons.person_outline_rounded
                    : role == UserRole.technician
                    ? Icons.build_outlined
                    : Icons.people_outline_rounded,
              ),
          ],
        ),
      ),
      (
        l.lockedCard,
        StateMessage(
          title: l.applianceRanking,
          icon: Icons.lock_outline_rounded,
        ),
      ),
      (
        l.screenStates,
        Column(
          children: [
            StateMessage(title: l.noData, body: l.noDataBody),
            const SizedBox(height: 12),
            StateMessage(
              title: l.loadError,
              body: l.loadErrorBody,
              icon: Icons.error_outline_rounded,
              onRetry: () => _feedback(l.sampleOnly),
            ),
            const SizedBox(height: 12),
            const SkeletonCard(),
          ],
        ),
      ),
      (
        l.confirmation,
        HoldToConfirm(onConfirmed: () => _feedback(l.confirmed)),
      ),
      (l.commandFeedback, const _CommandExample()),
      (
        l.demoPanel,
        OutlinedButton.icon(
          onPressed: () => showDemoPanel(context),
          icon: const Icon(Icons.tune_rounded),
          label: Text(l.demoPanel),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.gallery)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              l.gallerySubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            SmallBadge(l.simulation, icon: Icons.science_outlined),
            SectionTitle(l.galleryStates),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final condition in ViewCondition.values)
                  ChoiceChip(
                    label: Text(l.conditionName(condition)),
                    selected: s.galleryCondition == condition,
                    onSelected: (_) => c.galleryCondition(condition),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              key: ValueKey(_section),
              initialValue: _section ?? -1,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.filter),
              items: [
                DropdownMenuItem(value: -1, child: Text(l.all)),
                for (var i = 0; i < examples.length; i++)
                  DropdownMenuItem(value: i, child: Text(examples[i].$1)),
              ],
              onChanged: (v) => setState(() => _section = v == -1 ? null : v),
            ),
            for (var i = 0; i < examples.length; i++)
              if (_section == null || _section == i) ...[
                SectionTitle(examples[i].$1),
                ConditionView(
                  condition: s.galleryCondition,
                  name: examples[i].$1,
                  onRetry: () => c.galleryCondition(ViewCondition.normal),
                  child: examples[i].$2,
                ),
              ],
          ],
        ),
      ),
    );
  }

  void _feedback(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _SliderExample extends StatefulWidget {
  const _SliderExample({this.curtain = false});
  final bool curtain;
  @override
  State<_SliderExample> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<_SliderExample> {
  double _value = .72;
  @override
  Widget build(BuildContext context) => BmtCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              widget.curtain
                  ? Icons.curtains_outlined
                  : Icons.lightbulb_outline_rounded,
              color: context.accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.curtain
                    ? context.l.curtainPosition
                    : context.l.brightness,
              ),
            ),
            Text('${(_value * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
          semanticFormatterCallback: (v) => '${(v * 100).round()}%',
        ),
        if (widget.curtain)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _value = 1),
                child: Text(context.l.open),
              ),
              OutlinedButton(
                onPressed: () => setState(() => _value = 0),
                child: Text(context.l.closed),
              ),
            ],
          ),
      ],
    ),
  );
}

class _ClimateExample extends StatefulWidget {
  const _ClimateExample();
  @override
  State<_ClimateExample> createState() => _ClimateExampleState();
}

class _ClimateExampleState extends State<_ClimateExample> {
  int _temperature = 24;
  bool _on = false;
  @override
  Widget build(BuildContext context) => BmtCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.ac_unit_rounded, color: context.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l.airConditioner,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Switch(value: _on, onChanged: (v) => setState(() => _on = v)),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            '$_temperature°',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              tooltip: context.l.temperature,
              onPressed: _temperature > 16
                  ? () => setState(() => _temperature--)
                  : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            Text(context.l.temperature),
            IconButton.filledTonal(
              tooltip: context.l.temperature,
              onPressed: _temperature < 30
                  ? () => setState(() => _temperature++)
                  : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SmallBadge(context.l.sent, icon: Icons.schedule_rounded),
        const SizedBox(height: 8),
        Text(
          context.l.waitingEvidence,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _TimelineExample extends StatefulWidget {
  const _TimelineExample();
  @override
  State<_TimelineExample> createState() => _TimelineExampleState();
}

class _TimelineExampleState extends State<_TimelineExample> {
  double _hour = 14;
  @override
  Widget build(BuildContext context) => BmtCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_hour.floor().toString().padLeft(2, '0')}.00 · ${context.l.playback}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: _hour,
          min: 0,
          max: 23,
          divisions: 23,
          onChanged: (v) => setState(() => _hour = v),
        ),
        SmallBadge(context.l.motion, icon: Icons.directions_walk_rounded),
      ],
    ),
  );
}

class _CommandExample extends ConsumerWidget {
  const _CommandExample();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        d = c.devices.first;
    final command = s.home.commandFor(d.id);
    return BmtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l.deviceName(d.kind),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (command != null) CommandLine(command),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: s.home.connection.reachable
                ? () => c.send(d, on: d.status != DeviceStatus.on)
                : null,
            child: Text(context.l.sampleAction),
          ),
          OutlinedButton(
            onPressed: () => c.wallSwitch(d.id),
            child: Text(context.l.wallSwitchAction),
          ),
        ],
      ),
    );
  }
}
