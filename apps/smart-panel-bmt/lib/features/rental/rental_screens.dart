import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/tokens.dart';
import '../../core/widgets/controls.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';
import '../home/foundation_screen.dart';

import '../shared/feature_page.dart';

class RentalScreen extends ConsumerWidget {
  const RentalScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider), h = s.home, l = context.l;
    final repo = ref.read(repositoriesProvider).guests;
    final codes = repo.codesFor(s.role);
    final staying = codes.where((c) => c.id == h.p1.checkedInCode);
    final upcoming =
        codes.where((c) => !c.revoked && c.from.isAfter(h.time)).toList()
          ..sort((a, b) => a.from.compareTo(b.from));
    final report = h.p1.report;
    final results = report == null
        ? <DeviceCommand>[]
        : h.commands.where((c) => report.commandIds.contains(c.id)).toList();
    return P1Page(
      feature: Feature.rental,
      children: [
        BmtCard(
          color: BmtColors.anchor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.profileName(h.profile.id),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: BmtColors.onDark),
              ),
              const SizedBox(height: 12),
              Text(
                staying.isEmpty
                    ? l.vacant
                    : '${l.occupied} · ${l.guestExample} ${staying.first.guest}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: BmtColors.onDark),
              ),
              if (staying.isNotEmpty)
                Text(
                  '${l.checkOut}: ${context.houseDate(staying.first.until)} ${context.houseTime(staying.first.until)}',
                  style: const TextStyle(color: BmtColors.onDark),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (upcoming.isNotEmpty)
          Text(
            '${l.nextStay}: ${l.guestExample} ${upcoming.first.guest} · ${context.houseDate(upcoming.first.from)} ${context.houseTime(upcoming.first.from)}',
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push('/codes'),
          icon: const Icon(Icons.key_outlined),
          label: Text(l.accessCodes),
        ),
        const SizedBox(height: 20),
        FeaturePreview(
          feature: Feature.rentalReset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: h.connection.internet && h.connection.reachable
                    ? () => showRiskConfirmation(
                        context,
                        title: l.checkOut,
                        consequence: l.checkoutConsequence,
                        onConfirmed: () =>
                            repo.checkout(s.role, riskConfirmed: true),
                      )
                    : null,
                icon: const Icon(Icons.logout_rounded),
                label: Text(l.checkOut),
              ),
              const SizedBox(height: 12),
              Text(l.checkoutInternet),
              if (report != null) ...[
                SectionTitle(l.checkoutReport),
                BmtCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${context.houseTime(report.time)} ${l.wita}'),
                      Text('${l.codesRevoked}: ${report.revokedCount}'),
                      Text('${l.wifiVersion}: ${report.wifiVersion}'),
                      const SizedBox(height: 12),
                      Text(
                        results.any((c) => c.phase == CommandPhase.sent)
                            ? l.commandsPending
                            : results.length == report.commandIds.length &&
                                  results.every(
                                    (c) => c.phase == CommandPhase.confirmed,
                                  )
                            ? l.commandsComplete
                            : l.commandsIncomplete,
                      ),
                      for (final command in results) ...[
                        const SizedBox(height: 8),
                        Text(
                          l.deviceName(
                            h.devices
                                .firstWhere((d) => d.id == command.deviceId)
                                .kind,
                          ),
                        ),
                        CommandLine(command),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class AccessCodesScreen extends ConsumerStatefulWidget {
  const AccessCodesScreen({super.key});
  @override
  ConsumerState<AccessCodesScreen> createState() => _AccessCodesScreenState();
}

class _AccessCodesScreenState extends ConsumerState<AccessCodesScreen> {
  int _guest = 1;
  DateTime? _from, _until;
  Future<void> _date(bool start) async {
    final now = ref.read(demoProvider).home.time,
        initial = (start ? _from : _until) ?? now;
    final local = initial.toUtc().add(const Duration(hours: 8));
    final day = await showDatePicker(
      context: context,
      initialDate: local,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year, now.month + 2, 1),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: local.hour, minute: local.minute),
    );
    if (time == null || !mounted) return;
    setState(() {
      final value = DateTime.utc(
        day.year,
        day.month,
        day.day,
        time.hour - 8,
        time.minute,
      );
      if (start) {
        _from = value;
      } else {
        _until = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider), l = context.l, h = s.home;
    final repo = ref.read(repositoriesProvider).guests,
        can = repo.canIssueCode(s.role);
    final codes = repo.codesFor(s.role).reversed;
    final from = _from ?? h.time,
        until = _until ?? h.time.add(const Duration(days: 2));
    return P1Page(
      feature: Feature.accessCodes,
      children: [
        Text(l.codeLocalNote),
        const SizedBox(height: 16),
        BmtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _guest,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.guest),
                items: [
                  for (var i = 1; i <= 3; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text('${l.guestExample} $i'),
                    ),
                ],
                onChanged: can ? (v) => setState(() => _guest = v!) : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: can ? () => _date(true) : null,
                child: Text(
                  '${l.validFrom}\n${context.houseDate(from)} · ${context.houseTime(from)} ${l.wita}',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: can ? () => _date(false) : null,
                child: Text(
                  '${l.validUntil}\n${context.houseDate(until)} · ${context.houseTime(until)} ${l.wita}',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(l.codeRangeNote),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: can
                    ? () {
                        final code = repo.issueCode(
                          _guest,
                          from,
                          until,
                          s.role,
                        );
                        if (code == null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(l.codeFailed)));
                        }
                      }
                    : null,
                icon: const Icon(Icons.add_rounded),
                label: Text(l.issueCode),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (codes.isEmpty) StateMessage(title: l.noData),
        for (final code in codes) ...[
          BmtCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${l.guestExample} ${code.guest}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  code.value,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${context.houseDate(code.from)} ${context.houseTime(code.from)} →\n${context.houseDate(code.until)} ${context.houseTime(code.until)} ${l.wita}',
                ),
                const SizedBox(height: 12),
                Text(
                  code.revoked
                      ? l.revokedCode
                      : code.validAt(h.time)
                      ? l.activeCode
                      : h.time.isBefore(code.from)
                      ? l.upcomingCode
                      : l.expiredCode,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: can && !code.revoked
                      ? () => showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l.codePreview),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.codePreviewNote),
                                  const SizedBox(height: 16),
                                  SelectableText(
                                    '${l.guestExample} ${code.guest}\n${code.value}\n${context.houseDate(code.from)} ${context.houseTime(code.from)} → ${context.houseDate(code.until)} ${context.houseTime(code.until)} ${l.wita}',
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: '${l.simulation} · ${code.value}',
                                    ),
                                  );
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l.copiedCode)),
                                  );
                                },
                                child: Text(l.copyCode),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(l.close),
                              ),
                            ],
                          ),
                        )
                      : null,
                  child: Text(l.codePreview),
                ),
                OutlinedButton(
                  onPressed: can && code.validAt(h.time)
                      ? () => showRiskConfirmation(
                          context,
                          title: l.simulateKeypad,
                          consequence: l.keypadConsequence,
                          onConfirmed: () => repo.useCode(
                            code.id,
                            s.role,
                            riskConfirmed: true,
                          ),
                        )
                      : null,
                  child: Text(l.simulateKeypad),
                ),
                TextButton(
                  onPressed: can && !code.revoked
                      ? () => showRiskConfirmation(
                          context,
                          title: l.revokeCode,
                          consequence: l.revokedCode,
                          onConfirmed: () => repo.revokeCode(code.id, s.role),
                        )
                      : null,
                  child: Text(l.revokeCode),
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
