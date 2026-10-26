import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/tokens.dart';
import '../../core/widgets/controls.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l,
        h = s.home;
    final devices = c.devices;
    final large = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Semantics(
          button: true,
          child: InkWell(
            onTap: () => _chooseHome(context, ref),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.profileName(h.profile.id),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const Icon(Icons.expand_more_rounded),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l.tierName(h.tier)} · ${l.roleName(s.role)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (!large) ...[
                    const SizedBox(width: 12),
                    ConnectionBadge(h.connection.path),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (large) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ConnectionBadge(h.connection.path),
          ),
        ],
        const SizedBox(height: 20),
        if (!h.connection.internet) ...[
          BmtCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.wifi_off_rounded, color: context.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    h.connection.reachable
                        ? l.offlineBanner
                        : l.unreachableBanner,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ConditionView(
          condition: s.condition,
          onRetry: () => c.condition(ViewCondition.normal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeStatusCard(
                snapshot: h,
                onDetails: () => context.go('/alerts'),
              ),
              if (!h.plnAvailable) ...[
                const SizedBox(height: 16),
                BmtCard(child: Text('${l.powerOutage}. ${l.backup90}')),
              ],
              if (h.alerts.any((a) => a.kind == AlertKind.powerRestored)) ...[
                const SizedBox(height: 16),
                BmtCard(child: Text(l.restorationSummary)),
              ],
              SectionTitle(l.quickScenes),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final scene in SceneId.values)
                    ActionChip(
                      label: Text(l.sceneName(scene)),
                      onPressed: h.connection.reachable && h.plnAvailable
                          ? () {
                              c.scene(scene);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l.sceneApplied)),
                              );
                            }
                          : null,
                    ),
                ],
              ),
              SectionTitle(l.foundations),
              for (final f in Foundation.values) ...[
                FoundationTile(
                  foundation: f,
                  value: _foundationValue(context, f, h, c.cameras.length),
                  status: !h.connection.reachable
                      ? l.lastKnown
                      : (!h.plnAvailable ||
                            f == Foundation.gas && !h.gasPowered)
                      ? l.noPower
                      : f == Foundation.water && h.operation.wetSensor
                      ? l.needsAttention
                      : f == Foundation.gas && h.operation.gasDetected
                      ? l.critical
                      : l.normal,
                  enabled: h.connection.reachable,
                  onTap: () => context.push('/foundation/${f.name}'),
                ),
                const SizedBox(height: 8),
              ],
              SectionTitle(
                l.favourites,
                trailing: TextButton(
                  onPressed: () => context.go('/rooms'),
                  child: Text(l.allDevices),
                ),
              ),
              for (final d in devices.where(
                (d) =>
                    d.kind == DeviceKind.mainLight ||
                    d.kind == DeviceKind.airConditioner,
              )) ...[
                DeviceTile(
                  device: d,
                  enabled:
                      h.connection.canControl(cloud: d.cloud) &&
                      d.status != DeviceStatus.noPower,
                  command: h.commandFor(d.id),
                  reason: !h.connection.canControl(cloud: d.cloud)
                      ? l.unreachable
                      : null,
                  onToggle: (on) => c.send(d, on: on),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            l.offlineDemo,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  String _foundationValue(
    BuildContext context,
    Foundation f,
    HomeSnapshot h,
    int cameras,
  ) => switch (f) {
    Foundation.electricity => '${context.number(h.powerKw, decimals: 2)} kW',
    Foundation.water =>
      h.profile.hasTank
          ? '${context.l.tank} ${h.tankPercent}%'
          : '${h.profile.waterLitres} L',
    Foundation.wifi => '${h.profile.wifiDevices} ${context.l.devices}',
    Foundation.gas =>
      !h.gasPowered
          ? context.l.gasNoPower
          : h.operation.gasDetected
          ? context.l.gasLeak
          : h.operation.gasValveClosed
          ? context.l.gasValveClosed
          : context.l.safe,
    Foundation.cctv =>
      !h.plnAvailable
          ? context.l.camerasNoPower
          : '$cameras ${context.l.camerasOnline}',
  };
  void _chooseHome(BuildContext context, WidgetRef ref) =>
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (_) => Consumer(
          builder: (context, ref, _) {
            final s = ref.watch(demoProvider),
                c = ref.read(demoProvider.notifier),
                l = context.l;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.chooseHome,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ConditionView(
                    condition: s.condition,
                    onRetry: () => c.condition(ViewCondition.normal),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final p
                            in ref.read(repositoriesProvider).home.profiles)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              p.kind == HouseKind.rental
                                  ? Icons.villa_outlined
                                  : Icons.home_outlined,
                            ),
                            title: Text(l.profileName(p.id)),
                            subtitle: Text(l.tierName(p.tier)),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              c.profile(p.id);
                              Navigator.pop(context);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}
