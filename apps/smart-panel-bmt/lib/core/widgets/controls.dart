import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/biometric.dart';
import '../../app/providers.dart';
import '../../domain/models.dart';
import '../labels.dart';
import '../tokens.dart';
import 'surfaces.dart';

class CommandLine extends StatelessWidget {
  const CommandLine(this.command, {super.key, this.onRetry});
  final DeviceCommand command;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final c = command, l = context.l;
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                c.phase == CommandPhase.confirmed
                    ? Icons.check_circle_outline_rounded
                    : c.phase == CommandPhase.sent
                    ? Icons.schedule_rounded
                    : Icons.error_outline_rounded,
                size: 18,
                color:
                    c.phase == CommandPhase.failed ||
                        c.phase == CommandPhase.unconfirmed
                    ? Theme.of(context).colorScheme.error
                    : context.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.measuredWatts != null
                      ? '${l.commandName(c.phase)} · ${l.measuredPower} ${c.measuredWatts} W'
                      : l.commandName(c.phase),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (c.phase == CommandPhase.sent) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(minHeight: 2),
          ],
          if (c.failure != CommandFailure.none) ...[
            const SizedBox(height: 6),
            Text(switch (c.failure) {
              CommandFailure.noEvidence => l.noEvidenceReason,
              CommandFailure.unreachable => l.noConnectionReason,
              CommandFailure.noPower => l.noPower,
              CommandFailure.permission => l.noPermission,
              CommandFailure.superseded => l.superseded,
              _ => l.failed,
            }, style: Theme.of(context).textTheme.bodySmall),
            if (onRetry != null)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.tryAgain),
              ),
          ],
        ],
      ),
    );
  }
}

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.device,
    required this.enabled,
    required this.onToggle,
    this.command,
    this.reason,
  });
  final Device device;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final DeviceCommand? command;
  final String? reason;
  @override
  Widget build(BuildContext context) {
    final l = context.l, d = device;
    return BmtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                d.kind == DeviceKind.airConditioner
                    ? Icons.ac_unit_rounded
                    : d.kind == DeviceKind.cloudRobot
                    ? Icons.cleaning_services_outlined
                    : Icons.lightbulb_outline_rounded,
                color: context.accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.deviceName(d.kind),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l.roomName(d.room),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Semantics(
                label: l.deviceName(d.kind),
                child: Switch(
                  value: d.status == DeviceStatus.on,
                  onChanged: enabled && command?.phase != CommandPhase.sent
                      ? onToggle
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SmallBadge(
                !enabled && reason != null ? reason! : l.deviceStatus(d.status),
                icon: !enabled
                    ? Icons.cloud_off_rounded
                    : d.status == DeviceStatus.on
                    ? Icons.check_circle_outline_rounded
                    : Icons.power_settings_new_rounded,
              ),
              SmallBadge(
                d.cloud ? l.cloudDependent : l.local,
                icon: d.cloud ? Icons.cloud_outlined : Icons.home_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l.source}: ${l.sourceName(d.source)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (command != null)
            CommandLine(
              command!,
              onRetry: enabled ? () => onToggle(command!.targetOn) : null,
            ),
        ],
      ),
    );
  }
}

class HoldToConfirm extends StatefulWidget {
  const HoldToConfirm({
    super.key,
    required this.onConfirmed,
    this.enabled = true,
  });
  final VoidCallback onConfirmed;
  final bool enabled;
  @override
  State<HoldToConfirm> createState() => _HoldToConfirmState();
}

class _HoldToConfirmState extends State<HoldToConfirm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  bool _completed = false;
  Offset? _pointerOrigin;
  @override
  void initState() {
    super.initState();
    _progress.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_completed) {
        _completed = true;
        HapticFeedback.mediumImpact();
        widget.onConfirmed();
      }
    });
  }

  void _start() {
    if (widget.enabled) {
      _completed = false;
      _progress.forward(from: 0);
    }
  }

  void _cancel() {
    if (mounted && !_completed) _progress.reset();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: widget.enabled,
    label: context.l.holdToConfirm,
    hint: context.l.holdHint,
    onLongPress: widget.enabled ? _start : null,
    child: Listener(
      onPointerDown: widget.enabled
          ? (event) {
              _pointerOrigin = event.position;
              _start();
            }
          : null,
      onPointerMove: (event) {
        if (_pointerOrigin != null &&
            (event.position - _pointerOrigin!).distance > 12) {
          _pointerOrigin = null;
          _cancel();
        }
      },
      onPointerUp: (_) => _cancel(),
      onPointerCancel: (_) => _cancel(),
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) => Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            color: widget.enabled ? context.accent : context.panel,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress.value,
                    child: Container(
                      color: context.isDark ? BmtColors.onDark : BmtColors.safe,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    heightFactor: 1,
                    child: Text(
                      context.l.holdToConfirm,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: widget.enabled
                            ? (context.isDark ? BmtColors.ink950 : Colors.white)
                            : context.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showRiskConfirmation(
  BuildContext context, {
  required String title,
  required String consequence,
  required VoidCallback onConfirmed,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => _RiskConfirmation(
    title: title,
    consequence: consequence,
    onConfirmed: onConfirmed,
  ),
);

class _RiskConfirmation extends ConsumerStatefulWidget {
  const _RiskConfirmation({
    required this.title,
    required this.consequence,
    required this.onConfirmed,
  });
  final String title, consequence;
  final VoidCallback onConfirmed;
  @override
  ConsumerState<_RiskConfirmation> createState() => _RiskConfirmationState();
}

class _RiskConfirmationState extends ConsumerState<_RiskConfirmation> {
  bool _busy = false, _failed = false, _completed = false;
  late final BiometricConfirmation _auth;
  late final (String, PackageTier, UserRole) _scope;
  @override
  void initState() {
    super.initState();
    _auth = ref.read(biometricProvider);
    final s = ref.read(demoProvider);
    _scope = (s.home.profile.id, s.home.tier, s.role);
  }

  @override
  void dispose() {
    if (_busy) unawaited(_auth.cancel());
    super.dispose();
  }

  void _confirm() {
    if (_completed || !mounted) return;
    final s = ref.read(demoProvider);
    if ((s.home.profile.id, s.home.tier, s.role) != _scope ||
        !s.home.connection.reachable) {
      Navigator.pop(context);
      return;
    }
    _completed = true;
    Navigator.pop(context);
    widget.onConfirmed();
  }

  Future<void> _biometric() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    final confirmed = await _auth.confirm(
      context.l.biometricReason,
      title: context.l.biometric,
      cancel: context.l.cancel,
    );
    if (!mounted) return;
    if (confirmed) {
      _busy = false;
      _confirm();
    } else {
      setState(() {
        _busy = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_open_rounded, color: context.accent, size: 32),
        const SizedBox(height: 16),
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(widget.consequence),
        const SizedBox(height: 24),
        HoldToConfirm(enabled: !_busy, onConfirmed: _confirm),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _busy ? null : _biometric,
          icon: const Icon(Icons.fingerprint),
          label: Text(_busy ? context.l.authInProgress : context.l.biometric),
        ),
        const SizedBox(height: 8),
        Text(context.l.biometricNote),
        if (_failed) Text(context.l.biometricFallback),
        const SizedBox(height: 8),
        Text(context.l.holdHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l.cancel),
          ),
        ),
      ],
    ),
  );
}

class DemoLogo extends StatefulWidget {
  const DemoLogo({super.key, required this.onDemo});
  final VoidCallback onDemo;
  @override
  State<DemoLogo> createState() => _DemoLogoState();
}

class _DemoLogoState extends State<DemoLogo> {
  Timer? _timer;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l.appName,
    hint: context.l.demoLogoHint,
    onLongPress: widget.onDemo,
    child: Listener(
      onPointerDown: (_) {
        _timer?.cancel();
        _timer = Timer(const Duration(seconds: 2), widget.onDemo);
      },
      onPointerUp: (_) => _timer?.cancel(),
      onPointerCancel: (_) => _timer?.cancel(),
      child: SizedBox(
        width: 56,
        height: 48,
        child: Center(
          child: Image.asset(
            'assets/brand/bmt-m-only.png',
            width: 40,
            height: 26,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ),
    ),
  );
}
