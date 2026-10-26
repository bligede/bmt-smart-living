import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/widgets/controls.dart';
import '../../core/widgets/visuals.dart';
import '../../domain/models.dart';
import '../home/foundation_screen.dart';

class GuestScreen extends ConsumerWidget {
  const GuestScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final devices = c.devices
        .where(
          (d) => {
            DeviceKind.mainLight,
            DeviceKind.airConditioner,
          }.contains(d.kind),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.guestWelcome, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(l.profileName(s.home.profile.id)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final lang in ['id', 'en'])
              ChoiceChip(
                label: Text(lang == 'id' ? l.indonesian : l.english),
                selected: s.language == lang,
                onSelected: (_) => c.language(lang),
              ),
          ],
        ),
        const SizedBox(height: 24),
        for (final (icon, title, action) in <(IconData, String, VoidCallback?)>[
          (
            Icons.lightbulb_outline_rounded,
            l.lights,
            devices.any(
                  (d) =>
                      d.kind == DeviceKind.mainLight &&
                      d.status != DeviceStatus.noPower &&
                      d.status != DeviceStatus.unreachable,
                )
                ? () {
                    final d = c.devices.firstWhere(
                      (d) => d.kind == DeviceKind.mainLight,
                    );
                    c.send(d, on: d.status != DeviceStatus.on);
                  }
                : null,
          ),
          (
            Icons.wb_twilight_rounded,
            l.ambience,
            s.home.connection.reachable && s.home.plnAvailable
                ? () => c.scene(SceneId.guest)
                : null,
          ),
          (
            Icons.ac_unit_rounded,
            l.climate,
            devices.any(
                  (d) =>
                      d.kind == DeviceKind.airConditioner &&
                      d.status != DeviceStatus.noPower &&
                      d.status != DeviceStatus.unreachable,
                )
                ? () {
                    final d = c.devices.firstWhere(
                      (d) => d.kind == DeviceKind.airConditioner,
                    );
                    c.send(d, on: d.status != DeviceStatus.on);
                  }
                : null,
          ),
          (
            Icons.help_outline_rounded,
            l.help,
            () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l.help),
                content: SingleChildScrollView(child: Text(l.guestHelp)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l.close),
                  ),
                ],
              ),
            ),
          ),
        ]) ...[
          OutlinedButton.icon(
            onPressed: action,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(72),
            ),
            icon: Icon(icon, size: 28),
            label: Text(title),
          ),
          const SizedBox(height: 16),
        ],
        for (final d in devices) ...[
          Text('${l.deviceName(d.kind)} · ${l.deviceStatus(d.status)}'),
          if (s.home.commandFor(d.id) != null)
            CommandLine(
              s.home.commandFor(d.id)!,
              onRetry:
                  s.home.connection.reachable &&
                      d.status != DeviceStatus.noPower
                  ? () => c.send(d, on: s.home.commandFor(d.id)!.targetOn)
                  : null,
            ),
          const SizedBox(height: 12),
        ],
        FeaturePreview(
          feature: Feature.guestWifi,
          child: GuestWifiQr(version: s.home.operation.wifiVersion),
        ),
      ],
    );
  }
}
