import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/tokens.dart';
import '../../core/widgets/surfaces.dart';
import '../../core/widgets/visuals.dart';
import '../../domain/models.dart';
import '../home/foundation_screen.dart';
import '../home/p0_screens.dart';

class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider), l = context.l;
    final report = ref.read(repositoriesProvider).energy.monthlyReport(s.role);
    return ReviewPage(
      title: l.monthlyReport,
      children: report == null
          ? [StateMessage(title: l.noPermission)]
          : [
              Text(
                context.houseDate(report.month),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              BmtCard(
                color: BmtColors.anchor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.monthToDate,
                      style: const TextStyle(color: BmtColors.onDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${context.number(report.currentKwh)} kWh',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: BmtColors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${l.previousMonth}: ${context.number(report.previousKwh)} kWh',
                      style: const TextStyle(color: BmtColors.onDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(l.energyComparison),
              const SizedBox(height: 20),
              PowerChart(
                values: ref
                    .read(repositoriesProvider)
                    .energy
                    .historyFor(s.role, period: ChartPeriod.month),
                bars: true,
                maxY: 20,
              ),
              SectionTitle(l.topConsumers),
              FeaturePreview(
                feature: Feature.applianceRanking,
                child: BmtCard(
                  child: Column(
                    children: [
                      for (final entry in report.byDevice.entries)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l.deviceName(entry.key)),
                          subtitle: Text('${context.number(entry.value)} kWh'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l.energyReportNote),
            ],
    );
  }
}
