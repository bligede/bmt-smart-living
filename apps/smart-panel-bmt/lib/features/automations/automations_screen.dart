import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';
import '../home/foundation_screen.dart';

import '../shared/feature_page.dart';

class AutomationsScreen extends ConsumerWidget {
  const AutomationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        l = context.l,
        c = ref.read(demoProvider.notifier);
    final repo = ref.read(repositoriesProvider).devices;
    return P1Page(
      feature: Feature.automations,
      children: [
        Text(l.automationNote),
        const SizedBox(height: 20),
        for (final rule in s.home.p1.rules) ...[
          FeaturePreview(
            feature: rule.feature,
            child: BmtCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.automationName(rule.kind)),
                    value: rule.enabled,
                    onChanged:
                        s.home.connection.reachable &&
                            c.gate(rule.feature) == GateDecision.available
                        ? (v) => repo.saveAutomation(
                            rule.copyWith(enabled: v),
                            s.role,
                          )
                        : null,
                  ),
                  Text(switch (rule.kind) {
                    AutomationKind.vacantAc => l.vacantAcNote,
                    AutomationKind.humidFan => l.humidFanNote,
                    AutomationKind.scheduledHeater => l.heaterNote,
                  }),
                  if (rule.kind == AutomationKind.scheduledHeater)
                    TextButton.icon(
                      icon: const Icon(Icons.schedule_rounded),
                      label: Text(
                        '${rule.hour.toString().padLeft(2, '0')}.${rule.minute.toString().padLeft(2, '0')} ${l.wita}',
                      ),
                      onPressed: s.home.connection.reachable
                          ? () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: rule.hour,
                                  minute: rule.minute,
                                ),
                              );
                              if (time != null) {
                                repo.saveAutomation(
                                  rule.copyWith(
                                    hour: time.hour,
                                    minute: time.minute,
                                  ),
                                  s.role,
                                );
                              }
                            }
                          : null,
                    ),
                  if (rule.lastRun != null)
                    Text(
                      '${l.history}: ${context.houseTime(rule.lastRun!)} ${l.wita}',
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: rule.enabled && s.home.connection.reachable
                        ? () => repo.simulateAutomation(rule.kind, s.role)
                        : null,
                    child: Text(l.simulateTrigger),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
