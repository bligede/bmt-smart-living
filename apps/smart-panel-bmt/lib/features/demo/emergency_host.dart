import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../app/notifications.dart';
import '../../core/labels.dart';
import '../../core/tokens.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';

class EmergencyHost extends ConsumerWidget {
  const EmergencyHost({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    ref.listen(demoProvider, (previous, next) {
      final oldIds = previous?.home.alerts.map((a) => a.id).toSet() ?? <int>{};
      final prefs = ref.read(notificationPreferencesProvider);
      final hour = next.home.time.toUtc().add(const Duration(hours: 8)).hour;
      for (final alert
          in ref
              .read(demoProvider.notifier)
              .alerts
              .where((a) => !oldIds.contains(a.id))) {
        if (alert.level != AlertLevel.critical &&
            ((prefs.quiet && (hour >= 22 || hour < 7)) ||
                (alert.level == AlertLevel.important && !prefs.important) ||
                (alert.level == AlertLevel.info && !prefs.info))) {
          continue;
        }
        unawaited(
          ref
              .read(notificationsProvider)
              .showAlert(
                alert: alert,
                profileId: next.home.profile.id,
                connection: next.home.connection,
                title: l.alertName(alert.kind),
                body:
                    '${l.simulation} · ${context.houseTime(alert.time)} ${l.wita}',
                channelName: l.levelName(alert.level),
              ),
        );
      }
    });
    ref.watch(demoProvider);
    final alerts = ref
        .read(demoProvider.notifier)
        .alerts
        .where((a) => a.level == AlertLevel.critical && !a.acknowledged);
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(offstage: alerts.isNotEmpty, child: child),
        if (alerts.isNotEmpty)
          Positioned.fill(
            child: EmergencyPreview(
              key: ValueKey(alerts.first.id),
              alert: alerts.first,
            ),
          ),
      ],
    );
  }
}

class EmergencyPreview extends ConsumerStatefulWidget {
  const EmergencyPreview({super.key, required this.alert});
  final HomeAlert alert;
  @override
  ConsumerState<EmergencyPreview> createState() => _EmergencyPreviewState();
}

class _EmergencyPreviewState extends ConsumerState<EmergencyPreview> {
  late final DemoNotifications _notifications;
  @override
  void initState() {
    super.initState();
    _notifications = ref.read(notificationsProvider);
    _notifications.emergencyFeedback(true);
  }

  @override
  void dispose() {
    _notifications.emergencyFeedback(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.isDark ? BmtColors.ink950 : BmtColors.dangerBg,
        body: SafeArea(
          child: FocusScope(
            autofocus: true,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.criticalTitle.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.alertName(widget.alert.kind),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.alert.kind == AlertKind.gasLeak
                            ? l.gasSimulationOnly
                            : l.criticalPreviewBody,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${context.houseTime(widget.alert.time)} ${l.wita}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                BmtCard(child: Text(l.safetyPending)),
                if (widget.alert.kind == AlertKind.gasLeak) ...[
                  const SizedBox(height: 16),
                  if (ref.watch(demoProvider).home.operation.gasActionsApplied)
                    BmtCard(child: Text(l.gasActionsApplied)),
                  if (ref.watch(demoProvider).home.operation.gasValveClosed)
                    BmtCard(child: Text(l.gasValveClosed)),
                ],
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.contactPreview))),
                  icon: const Icon(Icons.phone_outlined),
                  label: Text(l.externalContact),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => ref
                      .read(demoProvider.notifier)
                      .acknowledge(widget.alert.id),
                  child: Text(l.acknowledge),
                ),
                const SizedBox(height: 12),
                Text(
                  l.acknowledgeNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
