import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../app/notifications.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/tokens.dart';
import '../../core/widgets/controls.dart';
import '../../core/widgets/surfaces.dart';
import '../../core/widgets/visuals.dart';
import '../../domain/models.dart';
import '../demo/demo_panel.dart';
import 'foundation_screen.dart';
import 'p0_screens.dart';

final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l.rooms, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        ConditionView(
          condition: s.condition,
          onRetry: () => c.condition(ViewCondition.normal),
          child: Column(
            children: [
              for (final room in s.home.profile.rooms) ...[
                BmtCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            room == RoomId.bedroom
                                ? Icons.bed_outlined
                                : Icons.meeting_room_outlined,
                            color: context.accent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l.roomName(room),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => context.push('/room/${room.name}'),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l.roomDetail),
                      ),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text('${l.temperature} 26°'),
                          Text('${l.humidity} 68%'),
                          Text(
                            '${c.devices.where((d) => d.room == room && d.status == DeviceStatus.on).length} ${l.activeDevices}',
                          ),
                        ],
                      ),
                      for (final d in c.devices.where(
                        (d) =>
                            d.room == room &&
                            {
                              DeviceKind.mainLight,
                              DeviceKind.readingLight,
                              DeviceKind.porchLight,
                              DeviceKind.airConditioner,
                            }.contains(d.kind),
                      )) ...[
                        const SizedBox(height: 16),
                        DeviceTile(
                          device: d,
                          enabled:
                              s.home.connection.canControl(cloud: d.cloud) &&
                              d.status != DeviceStatus.noPower,
                          reason: !s.home.connection.canControl(cloud: d.cloud)
                              ? l.unreachable
                              : null,
                          command: s.home.commandFor(d.id),
                          onToggle: (on) => c.send(d, on: on),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final locks = c.devices.where((d) => d.kind == DeviceKind.doorLock);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l.security, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        ConditionView(
          condition: s.condition,
          onRetry: () => c.condition(ViewCondition.normal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: Text(l.awayMode),
                    avatar: const Icon(Icons.logout_rounded, size: 18),
                    onPressed:
                        s.home.connection.reachable && s.home.plnAvailable
                        ? () => c.scene(SceneId.away)
                        : null,
                  ),
                  ActionChip(
                    label: Text(l.sleepMode),
                    avatar: const Icon(Icons.bedtime_outlined, size: 18),
                    onPressed:
                        s.home.connection.reachable && s.home.plnAvailable
                        ? () => c.scene(SceneId.night)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FeaturePreview(
                feature: Feature.doorLock,
                child: locks.isEmpty
                    ? const SizedBox.shrink()
                    : _LockCard(locks.first),
              ),
              SectionTitle(l.cctv),
              TextButton.icon(
                onPressed: s.home.connection.reachable
                    ? c.previewCritical
                    : null,
                icon: const Icon(Icons.warning_amber_outlined),
                label: Text(l.criticalPreview),
              ),
              FeaturePreview(
                feature: Feature.gate,
                child: Column(
                  children: [
                    for (final d in c.devices.where(
                      (d) => d.kind == DeviceKind.gateMotor,
                    ))
                      DeviceControl(d, detailLink: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FeaturePreview(
                feature: Feature.alarm,
                child: BmtCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        s.home.operation.alarmArmed
                            ? l.alarmArmed
                            : l.alarmDisarmed,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed:
                            s.home.connection.reachable && s.home.plnAvailable
                            ? () {
                                if (s.home.operation.alarmArmed) {
                                  showRiskConfirmation(
                                    context,
                                    title: l.disarmAlarm,
                                    consequence: l.riskConsequence,
                                    onConfirmed: () =>
                                        c.armAlarm(false, riskConfirmed: true),
                                  );
                                } else {
                                  c.armAlarm(true);
                                }
                              }
                            : null,
                        child: Text(
                          s.home.operation.alarmArmed
                              ? l.disarmAlarm
                              : l.armAlarm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BmtCard(child: Text(l.sensorClosed)),
              const SizedBox(height: 20),
              for (final camera in c.cameras) ...[
                CameraTile(
                  name: l.cameraName(camera),
                  time: context.houseTime(s.home.time, seconds: true),
                  online: s.home.connection.reachable && s.home.plnAvailable,
                  onTap: () => context.push('/camera/${camera.name}'),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LockCard extends ConsumerWidget {
  const _LockCard(this.device);
  final Device device;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final unlocked = device.status == DeviceStatus.on;
    return BmtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                unlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                color: context.accent,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.doorLock,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            unlocked ? l.unlockedDoor : l.lockedDoor,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${l.battery} 82% · ${l.local}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text('${l.source}: ${l.sourceName(device.source)}'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  s.home.connection.reachable &&
                      s.home.commandFor(device.id)?.phase != CommandPhase.sent
                  ? () => showRiskConfirmation(
                      context,
                      title: unlocked ? l.lock : l.unlockQuestion,
                      consequence: unlocked
                          ? l.lockedDoor
                          : l.unlockConsequence,
                      onConfirmed: () =>
                          c.send(device, on: !unlocked, riskConfirmed: true),
                    )
                  : null,
              icon: Icon(
                unlocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
              ),
              label: Text(unlocked ? l.lock : l.unlock),
            ),
          ),
          if (s.home.commandFor(device.id) != null)
            CommandLine(s.home.commandFor(device.id)!),
        ],
      ),
    );
  }
}

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});
  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertLevel? _filter;
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final alerts = c.alerts
        .where((a) => _filter == null || a.level == _filter)
        .toList()
        .reversed;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l.alerts, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l.all),
              selected: _filter == null,
              onSelected: (_) => setState(() => _filter = null),
            ),
            for (final level in AlertLevel.values)
              ChoiceChip(
                label: Text(l.levelName(level)),
                selected: _filter == level,
                onSelected: (_) => setState(() => _filter = level),
              ),
          ],
        ),
        const SizedBox(height: 20),
        ConditionView(
          condition: s.condition,
          onRetry: () => c.condition(ViewCondition.normal),
          child: Column(
            children: [
              if (alerts.isEmpty)
                StateMessage(
                  title: l.noAlerts,
                  body: l.noAlertsBody,
                  icon: Icons.notifications_none_rounded,
                ),
              for (final a in alerts) ...[
                AlertCard(
                  level: a.level,
                  title: l.alertName(a.kind),
                  subtitle:
                      '${context.houseTime(a.time)} · ${a.acknowledged ? l.allRead : l.simulation}',
                  onTap: () => context.push('/alert/${a.id}'),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l.more, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        BmtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallBadge(l.reviewBuild, icon: Icons.science_outlined),
              const SizedBox(height: 12),
              Text(l.p0Notice, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push('/gallery'),
                icon: const Icon(Icons.widgets_outlined),
                label: Text(l.viewGallery),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FeaturePreview(
          feature: Feature.automations,
          child: _entry(
            context,
            Icons.auto_mode,
            l.featureName(Feature.automations),
            () => context.push('/automations'),
          ),
        ),
        FeaturePreview(
          feature: Feature.addDevice,
          child: _entry(
            context,
            Icons.add_circle_outline,
            l.featureName(Feature.addDevice),
            () => context.push('/add-device'),
          ),
        ),
        FeaturePreview(
          feature: Feature.rental,
          child: _entry(
            context,
            Icons.holiday_village_outlined,
            l.featureName(Feature.rental),
            () => context.push('/rental'),
          ),
        ),
        FeaturePreview(
          feature: Feature.accessCodes,
          child: _entry(
            context,
            Icons.key_outlined,
            l.featureName(Feature.accessCodes),
            () => context.push('/codes'),
          ),
        ),
        FeaturePreview(
          feature: Feature.energy,
          child: _entry(
            context,
            Icons.bar_chart_rounded,
            l.monthlyReport,
            () => context.push('/monthly-report'),
          ),
        ),
        FeaturePreview(
          feature: Feature.service,
          child: _entry(
            context,
            Icons.support_agent,
            l.featureName(Feature.service),
            () => context.push('/service'),
          ),
        ),
        FeaturePreview(
          feature: Feature.secondContacts,
          child: _entry(
            context,
            Icons.contact_phone_outlined,
            l.featureName(Feature.secondContacts),
            () => context.push('/second-contact'),
          ),
        ),
        if (ref.watch(demoProvider).role == UserRole.owner)
          _entry(
            context,
            Icons.qr_code_scanner_rounded,
            l.pairing,
            () => context.push('/welcome'),
          ),
        _entry(
          context,
          Icons.auto_awesome_outlined,
          l.scenes,
          () => context.push('/scenes'),
        ),
        if (ref.watch(demoProvider).role == UserRole.owner)
          _entry(
            context,
            Icons.people_outline,
            l.members,
            () => context.push('/members'),
          ),
        _entry(
          context,
          Icons.notifications_outlined,
          l.notificationSettings,
          () => context.push('/notifications'),
        ),
        _entry(
          context,
          Icons.tune_rounded,
          l.demoPanel,
          () => showDemoPanel(context),
        ),
        _entry(
          context,
          Icons.palette_outlined,
          l.settings,
          () => context.push('/settings'),
        ),
        _entry(
          context,
          Icons.history_rounded,
          l.history,
          () => context.push('/history'),
        ),
        _entry(
          context,
          Icons.info_outline_rounded,
          l.about,
          () => context.push('/about'),
        ),
      ],
    );
  }

  Widget _entry(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback tap,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 8),
    leading: Icon(icon, color: context.accent),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: tap,
  );
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    return ReviewPage(
      title: l.settings,
      children: [
        SectionTitle(l.theme),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (mode, name) in [
              (ThemeMode.light, l.light),
              (ThemeMode.dark, l.dark),
              (ThemeMode.system, l.system),
            ])
              ChoiceChip(
                label: Text(name),
                selected: s.theme == mode,
                onSelected: (_) => c.theme(mode),
              ),
          ],
        ),
        SectionTitle(l.language),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l.indonesian),
              selected: s.language == 'id',
              onSelected: (_) => c.language('id'),
            ),
            ChoiceChip(
              label: Text(l.english),
              selected: s.language == 'en',
              onSelected: (_) => c.language('en'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l.reduceMotion),
          value: s.reduceMotion,
          onChanged: c.motion,
        ),
        SectionTitle(l.notifications),
        Text(l.offlineDemo, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await ref
                .read(notificationsProvider)
                .sample(
                  connection: s.home.connection,
                  title: l.notificationTitle,
                  body: l.notificationBody,
                  channelName: l.info,
                );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(switch (result) {
                  NotificationResult.shown => l.notificationSent,
                  NotificationResult.blocked => l.notificationBlocked,
                  _ => l.notificationDenied,
                }),
              ),
            );
          },
          icon: const Icon(Icons.notifications_outlined),
          label: Text(l.notificationTest),
        ),
      ],
    );
  }
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l, info = ref.watch(packageInfoProvider).asData?.value;
    const build = String.fromEnvironment('BUILD_TIME');
    final parsed = DateTime.tryParse(build);
    return ReviewPage(
      title: l.about,
      children: [
        BmtCard(
          color: BmtColors.anchor,
          borderColor: BmtColors.anchor,
          child: Center(
            child: Image.asset(
              'assets/brand/bmt-logo-green.png',
              height: 144,
              semanticLabel: l.appName,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(l.appName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(l.localService),
        const SizedBox(height: 12),
        Text(
          '${l.version} ${info?.version ?? '0.1.0'}+${info?.buildNumber ?? '1'}',
        ),
        const SizedBox(height: 8),
        Text(
          '${l.buildTime}: ${parsed == null ? l.buildTimeUnknown : '${context.houseDate(parsed)} ${context.houseTime(parsed)} ${l.wita}'}',
        ),
        const SizedBox(height: 20),
        BmtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.offlineDemo),
              const SizedBox(height: 12),
              Text(l.notProof),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => showLicensePage(
            context: context,
            applicationName: l.appName,
            applicationVersion: info?.version ?? '0.1.0',
          ),
          child: Text(l.licences),
        ),
      ],
    );
  }
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider), l = context.l;
    return ReviewPage(
      title: l.history,
      children: [
        if (s.home.history.isEmpty)
          StateMessage(title: l.noHistory, body: l.noDataBody),
        for (final e in s.home.history.reversed) ...[
          BmtCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.action != null
                      ? l.auditName(e.action!)
                      : e.device != null
                      ? l.deviceName(e.device!)
                      : e.scene != null
                      ? l.sceneName(e.scene!)
                      : l.cameraAccess,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${context.houseTime(e.time)} · ${l.sourceName(e.source)}',
                ),
                if (e.phase != null)
                  Text(
                    l.commandName(e.phase!),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (e.camera != null) Text(l.cameraName(e.camera!)),
                if (e.path != null) Text(l.pathName(e.path!)),
                if (e.alert != null) Text(l.alertName(e.alert!)),
                if (e.targetOn != null) Text(e.targetOn! ? l.on : l.off),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen(this.camera, {super.key});
  final CameraId camera;
  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref
            .read(repositoriesProvider)
            .cameras
            .recordAccess(widget.camera, ref.read(demoProvider).role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final allowed = c.cameras.contains(widget.camera);
    return ReviewPage(
      title: allowed ? l.cameraName(widget.camera) : l.cctv,
      children: [
        if (!allowed)
          StateMessage(title: l.noPermission, icon: Icons.lock_outline_rounded)
        else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SmallBadge(
                s.home.connection.reachable && s.home.plnAvailable
                    ? l.live
                    : l.lastKnown,
                icon: Icons.circle_outlined,
              ),
              SmallBadge(l.simulation),
              ConnectionBadge(s.home.connection.path),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.camera == CameraId.living &&
              s.home.operation.indoorPrivacy)
            StateMessage(title: l.privacyMode)
          else if (!s.home.plnAvailable)
            StateMessage(title: l.camerasNoPower)
          else
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: CustomPaint(painter: CameraIllustration()),
            ),
          const SizedBox(height: 16),
          Text(
            '${context.houseDate(s.home.time)} · ${context.houseTime(s.home.time, seconds: true)} ${l.wita}',
          ),
          const SizedBox(height: 12),
          SmallBadge(l.audioOff, icon: Icons.volume_off_outlined),
          const SizedBox(height: 16),
          Text(l.cameraAccess, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          FeaturePreview(
            feature: Feature.recording,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/timeline/${widget.camera.name}'),
              icon: const Icon(Icons.history_rounded),
              label: Text(l.openTimeline),
            ),
          ),
        ],
      ],
    );
  }
}
