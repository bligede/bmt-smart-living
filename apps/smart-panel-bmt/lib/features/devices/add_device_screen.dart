import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';

import '../shared/feature_page.dart';

class AddDeviceScreen extends ConsumerStatefulWidget {
  const AddDeviceScreen({super.key});
  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  PairingCandidate _candidate = PairingCandidate.localRelay;
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider), l = context.l;
    final repo = ref.read(repositoriesProvider).devices,
        result = repo.compatibility(_candidate);
    final labels = [
      l.compatLocal,
      l.compatFeedback,
      l.compatOffline,
      l.compatIntegration,
    ];
    final can =
        s.home.connection.atHome &&
        s.home.connection.reachable &&
        s.home.plnAvailable &&
        result.supported &&
        (!result.cloud ||
            (ref.read(demoProvider.notifier).gate(Feature.cloudDevice) ==
                    GateDecision.available &&
                s.home.connection.internet));
    return P1Page(
      feature: Feature.addDevice,
      children: [
        Text(l.pairAtHome),
        const SizedBox(height: 20),
        RadioGroup<PairingCandidate>(
          groupValue: _candidate,
          onChanged: (v) => setState(() => _candidate = v!),
          child: Column(
            children: [
              for (final candidate in PairingCandidate.values)
                RadioListTile<PairingCandidate>(
                  value: candidate,
                  title: Text(switch (candidate) {
                    PairingCandidate.localRelay => l.candidateLocal,
                    PairingCandidate.cloudRobot => l.candidateCloud,
                    PairingCandidate.unsupported => l.candidateUnsupported,
                  }),
                ),
            ],
          ),
        ),
        SectionTitle(l.compatibility),
        BmtCard(
          child: Column(
            children: [
              for (var i = 0; i < labels.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    result.checks[i]
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                  ),
                  title: Text(labels[i]),
                  subtitle: Text(result.checks[i] ? l.passed : l.notPassed),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          result.local
              ? l.local
              : result.cloud
              ? l.cloudPairNote
              : l.unsupportedNote,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: can
              ? () {
                  final added = repo.addDevice(_candidate, s.role);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(added ? l.addSuccess : l.addFailed)),
                  );
                }
              : null,
          icon: const Icon(Icons.add_rounded),
          label: Text(l.addDevice),
        ),
        const SizedBox(height: 12),
        Text(l.unsupportedNote),
      ],
    );
  }
}
