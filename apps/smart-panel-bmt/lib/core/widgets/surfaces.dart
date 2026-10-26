import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../labels.dart';
import '../tokens.dart';

class BmtCard extends StatelessWidget {
  const BmtCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color, borderColor;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? context.panel,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor ?? context.line),
    ),
    child: child,
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?trailing,
      ],
    ),
  );
}

class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge(this.path, {super.key, this.onDark = false});
  final ConnectionPath path;
  final bool onDark;
  @override
  Widget build(BuildContext context) {
    final offline =
        path == ConnectionPath.unreachable ||
        path == ConnectionPath.localOffline;
    final color = onDark
        ? BmtColors.onDark
        : offline
        ? context.muted
        : context.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: onDark ? BmtColors.ink700 : context.panel,
        border: Border.all(color: onDark ? BmtColors.ink700 : context.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            offline
                ? Icons.wifi_off_rounded
                : path == ConnectionPath.remote
                ? Icons.public_rounded
                : Icons.home_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.l.pathName(path),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class SmallBadge extends StatelessWidget {
  const SmallBadge(this.text, {super.key, this.icon, this.dark = false});
  final String text;
  final IconData? icon;
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: dark ? BmtColors.ink700 : context.panel,
      border: Border.all(color: dark ? BmtColors.ink700 : context.line),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: dark ? BmtColors.onDark : context.muted),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: dark ? BmtColors.onDark : null,
            ),
          ),
        ),
      ],
    ),
  );
}

class HomeStatusCard extends StatelessWidget {
  const HomeStatusCard({
    super.key,
    required this.snapshot,
    required this.onDetails,
  });
  final HomeSnapshot snapshot;
  final VoidCallback onDetails;
  @override
  Widget build(BuildContext context) {
    final l = context.l, reachable = snapshot.connection.reachable;
    final critical =
        snapshot.operation.gasDetected ||
        snapshot.alerts.any(
          (a) => a.level == AlertLevel.critical && !a.acknowledged,
        );
    final attention =
        !snapshot.connection.internet ||
        snapshot.powerKw >= 2.975 ||
        !snapshot.gasPowered ||
        snapshot.operation.wetSensor ||
        snapshot.operation.gasValveClosed ||
        snapshot.operation.voltageAnomaly;
    final title = !reachable
        ? l.unreachable
        : critical
        ? l.criticalTitle
        : attention
        ? l.needsAttention
        : l.safeHome;
    final reason = !reachable
        ? l.unreachableBanner
        : critical
        ? (snapshot.operation.gasDetected ? l.gasLeak : l.criticalReason)
        : !snapshot.gasPowered
        ? l.gasNoPower
        : snapshot.operation.wetSensor
        ? l.wetLocation
        : snapshot.operation.gasValveClosed
        ? l.gasValveClosed
        : snapshot.operation.voltageAnomaly
        ? l.voltageAlert
        : !snapshot.connection.internet
        ? l.offlineBanner
        : snapshot.powerKw >= 2.975
        ? l.loadWarning
        : l.normalFoundations;
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title. $reason',
      child: BmtCard(
        color: BmtColors.anchor,
        borderColor: BmtColors.anchor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: BmtColors.onDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  !reachable
                      ? Icons.cloud_off_rounded
                      : critical || attention
                      ? Icons.warning_amber_rounded
                      : Icons.verified_user_outlined,
                  color: critical
                      ? BmtColors.dangerDark
                      : attention
                      ? BmtColors.attentionDark
                      : BmtColors.green,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reason,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: BmtColors.onDark),
            ),
            const SizedBox(height: 12),
            Text(
              '${reachable ? l.updated : l.lastKnown} ${context.houseTime(snapshot.time, seconds: true)} ${l.wita}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: BmtColors.mutedDark),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: BmtColors.green,
                  padding: EdgeInsets.zero,
                ),
                onPressed: onDetails,
                label: Text(critical ? l.seeAlert : l.seeStatus),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                iconAlignment: IconAlignment.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData foundationIcon(Foundation f) => switch (f) {
  Foundation.electricity => Icons.bolt_rounded,
  Foundation.water => Icons.water_drop_outlined,
  Foundation.wifi => Icons.wifi_rounded,
  Foundation.gas => Icons.local_fire_department_outlined,
  Foundation.cctv => Icons.videocam_outlined,
};

class FoundationTile extends StatelessWidget {
  const FoundationTile({
    super.key,
    required this.foundation,
    required this.value,
    required this.status,
    this.onTap,
    this.enabled = true,
  });
  final Foundation foundation;
  final String value, status;
  final VoidCallback? onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    child: Material(
      color: context.panel,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: context.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.isDark ? BmtColors.anchor : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  foundationIcon(foundation),
                  color: enabled ? context.accent : context.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l.foundationName(foundation),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(value, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          enabled
                              ? Icons.check_circle_outline_rounded
                              : Icons.cloud_off_rounded,
                          size: 14,
                          color: enabled ? context.accent : context.muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            status,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    ),
  );
}

class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.title,
    this.body,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
  });
  final String title;
  final String? body;
  final IconData icon;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => BmtCard(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: context.muted, size: 32),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Text(
            body!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.muted),
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l.tryAgain),
          ),
        ],
      ],
    ),
  );
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l.loading,
    child: ExcludeSemantics(
      child: BmtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 16, width: 120, color: context.line),
            const SizedBox(height: 16),
            Container(height: 28, width: 180, color: context.line),
            const SizedBox(height: 16),
            Container(height: 12, color: context.line),
          ],
        ),
      ),
    ),
  );
}

class ConditionView extends StatelessWidget {
  const ConditionView({
    super.key,
    required this.condition,
    required this.child,
    required this.onRetry,
    this.name,
  });
  final ViewCondition condition;
  final Widget child;
  final VoidCallback onRetry;
  final String? name;
  @override
  Widget build(BuildContext context) => switch (condition) {
    ViewCondition.loading => const SkeletonCard(),
    ViewCondition.empty => StateMessage(
      title: context.l.noData,
      body: context.l.noDataBody,
    ),
    ViewCondition.error => StateMessage(
      title: context.l.loadError,
      body: context.l.loadErrorBody,
      icon: Icons.error_outline_rounded,
      onRetry: onRetry,
    ),
    ViewCondition.locked => StateMessage(
      title: name ?? context.l.locked,
      icon: Icons.lock_outline_rounded,
    ),
    ViewCondition.disabled => AbsorbPointer(
      child: BmtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmallBadge(context.l.disabled, icon: Icons.block_rounded),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    ),
    ViewCondition.pressed => BmtCard(
      borderColor: context.accent,
      padding: const EdgeInsets.all(4),
      child: child,
    ),
    ViewCondition.normal => child,
  };
}

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.level,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final AlertLevel level;
  final String title, subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      AlertLevel.critical =>
        context.isDark ? BmtColors.dangerDark : BmtColors.danger,
      AlertLevel.important =>
        context.isDark ? BmtColors.attentionDark : BmtColors.attention,
      AlertLevel.info => context.isDark ? BmtColors.infoDark : BmtColors.info,
    };
    final bg = context.isDark
        ? BmtColors.anchor
        : switch (level) {
            AlertLevel.critical => BmtColors.dangerBg,
            AlertLevel.important => BmtColors.attentionBg,
            AlertLevel.info => BmtColors.infoBg,
          };
    return Semantics(
      button: onTap != null,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  level == AlertLevel.info
                      ? Icons.info_outline_rounded
                      : Icons.warning_amber_rounded,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l.levelName(level),
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
