import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/tokens.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';

Future<void> showDemoPanel(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: false,
  builder: (_) => const DemoPanel(),
);

class DemoPanel extends ConsumerWidget {
  const DemoPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .6,
      minChildSize: .35,
      maxChildSize: .93,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: context.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.demoPanel,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: l.close,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Text(l.offlineDemo, style: Theme.of(context).textTheme.bodySmall),
          SectionTitle(l.profile),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in ref.read(repositoriesProvider).home.profiles)
                ChoiceChip(
                  label: Text(l.profileName(p.id)),
                  selected: p.id == s.home.profile.id,
                  onSelected: (_) => c.profile(p.id),
                ),
            ],
          ),
          SectionTitle(l.package),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tier in PackageTier.values)
                ChoiceChip(
                  label: Text(l.tierName(tier)),
                  selected: tier == s.home.tier,
                  onSelected: (_) => c.tier(tier),
                ),
            ],
          ),
          SectionTitle(l.role),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final role in UserRole.values)
                ChoiceChip(
                  label: Text(l.roleName(role)),
                  selected: role == s.role,
                  onSelected: (_) => c.role(role),
                ),
            ],
          ),
          SectionTitle(l.phoneLocation),
          Text(
            l.connectionMatrix,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final (connection, description) in [
            (const DemoConnection(), l.matrixHome),
            (const DemoConnection(internet: false), l.matrixLocal),
            (const DemoConnection(atHome: false), l.matrixRemote),
            (
              const DemoConnection(atHome: false, internet: false),
              l.matrixUnreachable,
            ),
          ])
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.pathName(connection.path)),
              subtitle: Text(description),
              selected: connection.path == s.home.connection.path,
              leading: Icon(
                connection.path == s.home.connection.path
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              onTap: () => c.connection(
                atHome: connection.atHome,
                internet: connection.internet,
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(l.atHome),
                selected: s.home.connection.atHome,
                onSelected: (_) => c.connection(atHome: true),
              ),
              ChoiceChip(
                label: Text(l.outside),
                selected: !s.home.connection.atHome,
                onSelected: (_) => c.connection(atHome: false),
              ),
            ],
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l.homeInternet),
            subtitle: Text(
              s.home.connection.internet ? l.connected : l.disconnected,
            ),
            value: s.home.connection.internet,
            onChanged: (v) => c.connection(internet: v),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l.outsidePackage),
            subtitle: Text(s.showLocked ? l.showLocked : l.hide),
            value: s.showLocked,
            onChanged: c.locked,
          ),
          SectionTitle(l.time),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(l.daytime),
                selected: !s.night,
                onSelected: (_) => c.clock(night: false),
              ),
              ChoiceChip(
                label: Text(l.night),
                selected: s.night,
                onSelected: (_) => c.clock(night: true),
              ),
              ChoiceChip(
                label: const Text('×10'),
                selected: s.speed == 10,
                onSelected: (v) => c.clock(speed: v ? 10 : 1),
              ),
            ],
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l.evidence),
            subtitle: Text(s.evidence ? l.evidencePresent : l.evidenceAbsent),
            value: s.evidence,
            onChanged: c.evidence,
          ),
          SectionTitle(l.screenCondition),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in ViewCondition.values)
                ChoiceChip(
                  label: Text(l.conditionName(v)),
                  selected: s.condition == v,
                  onSelected: (_) => c.condition(v),
                ),
            ],
          ),
          const SizedBox(height: 16),
          BmtCard(
            child: Text(
              l.scenarioResetNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SectionTitle(l.scenarioTitle),
          for (final id in ScenarioId.values) ...[
            OutlinedButton(
              onPressed: () {
                c.scenario(id);
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l.scenarioName(id)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l.scenarioNote(id),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          if (s.home.operation.scenario != null) ...[
            Text(
              l.scenarioName(s.home.operation.scenario!),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${s.home.operation.scenarioRunning ? l.scenarioRunning : l.scenarioComplete} · ${l.scenarioStep} ${s.home.operation.scenarioStep}',
            ),
            if (s.home.operation.scenarioRunning)
              TextButton(
                onPressed: c.stopScenario,
                child: Text(l.stopScenario),
              ),
          ],
          if (s.home.operation.gasDetected)
            OutlinedButton(
              onPressed: s.home.connection.reachable ? c.normalizeGas : null,
              child: Text(l.normalizeGas),
            ),
          if (s.home.operation.gasValveClosed)
            OutlinedButton(
              onPressed:
                  !s.home.operation.gasDetected && s.home.connection.reachable
                  ? c.physicalGasReset
                  : null,
              child: Text(l.physicalReset),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              c.reset();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l.resetDone)));
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(l.reset),
          ),
        ],
      ),
    );
  }
}
