import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../labels.dart';
import '../tokens.dart';
import 'surfaces.dart';

class PowerChart extends StatelessWidget {
  const PowerChart({
    super.key,
    required this.values,
    this.reduceMotion = false,
    this.bars = false,
    this.anomaly = false,
    this.maxY = 3.5,
  });
  final List<double> values;
  final bool reduceMotion, bars;
  final bool anomaly;
  final double maxY;
  @override
  Widget build(BuildContext context) {
    final line = context.line, accent = context.accent;
    final titles = FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          interval: maxY > 4 ? 5 : 1,
          getTitlesWidget: (value, meta) => Text(
            context.number(value, decimals: value % 1 == 0 ? 0 : 1),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
    return Semantics(
      label: context.l.powerTrend,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 160,
          child: bars
              ? BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: maxY,
                    titlesData: titles,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 4 ? 5 : 1,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: line, strokeWidth: 1),
                    ),
                    barGroups: [
                      for (var i = 0; i < values.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: values[i],
                              color: accent,
                              width: 10,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        ),
                    ],
                  ),
                  duration: Duration(milliseconds: reduceMotion ? 0 : 220),
                )
              : LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    minX: 0,
                    maxX: (values.length - 1).toDouble(),
                    titlesData: titles,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 4 ? 5 : 1,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: line, strokeWidth: 1),
                    ),
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < values.length; i++)
                            FlSpot(i.toDouble(), values[i]),
                        ],
                        isCurved: true,
                        preventCurveOverShooting: true,
                        color: accent,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: anomaly,
                          checkToShowDot: (spot, _) => spot.y >= 3.0,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 5,
                                color: Theme.of(context).colorScheme.error,
                                strokeWidth: 2,
                                strokeColor: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: context.isDark
                              ? BmtColors.green900
                              : BmtColors.green50,
                        ),
                      ),
                    ],
                  ),
                  duration: Duration(milliseconds: reduceMotion ? 0 : 220),
                ),
        ),
      ),
    );
  }
}

class TankGauge extends StatelessWidget {
  const TankGauge({super.key, required this.percent});
  final int percent;
  @override
  Widget build(BuildContext context) => BmtCard(
    child: Row(
      children: [
        Semantics(
          label: '${context.l.tank} $percent%',
          child: Container(
            width: 72,
            height: 104,
            decoration: BoxDecoration(
              border: Border.all(color: context.accent, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: percent / 100,
                  widthFactor: 1,
                  child: ColoredBox(
                    color: context.isDark
                        ? BmtColors.green900
                        : BmtColors.green50,
                    child: Center(
                      child: Icon(
                        Icons.water_drop_outlined,
                        color: context.accent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l.tank,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$percent%',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${context.l.tankCapacity} 1.000 L',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class CameraIllustration extends CustomPainter {
  const CameraIllustration();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = BmtColors.anchor);
    canvas.drawRect(
      Rect.fromLTWH(0, h * .72, w, h * .28),
      Paint()..color = BmtColors.ink700,
    );
    final building = Path()
      ..moveTo(w * .14, h * .72)
      ..lineTo(w * .14, h * .32)
      ..lineTo(w * .58, h * .2)
      ..lineTo(w * .9, h * .31)
      ..lineTo(w * .9, h * .72)
      ..close();
    canvas.drawPath(building, Paint()..color = BmtColors.secondary);
    canvas.drawRect(
      Rect.fromLTWH(w * .24, h * .4, w * .22, h * .32),
      Paint()..color = BmtColors.ink900,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * .55, h * .36, w * .23, h * .18),
      Paint()..color = BmtColors.mutedDark,
    );
    canvas.drawLine(
      Offset(w * .14, h * .32),
      Offset(w * .58, h * .2),
      Paint()
        ..color = BmtColors.onDark
        ..strokeWidth = 2,
    );
    for (var i = 0; i < 11; i++) {
      canvas.drawLine(
        Offset(w * .08 + i * w * .08, h * .62),
        Offset(w * .08 + i * w * .08, h * .9),
        Paint()
          ..color = BmtColors.ink950
          ..strokeWidth = 3,
      );
    }
    canvas.drawLine(
      Offset(w * .08, h * .64),
      Offset(w * .88, h * .64),
      Paint()
        ..color = BmtColors.ink950
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      Offset(w * .83, h * .28),
      h * .035,
      Paint()..color = BmtColors.green,
    );
  }

  @override
  bool shouldRepaint(CameraIllustration oldDelegate) => false;
}

class CameraTile extends StatelessWidget {
  const CameraTile({
    super.key,
    required this.name,
    required this.time,
    required this.online,
    this.onTap,
  });
  final String name, time;
  final bool online;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label:
        '$name. ${online ? context.l.connected : context.l.unreachable}. ${context.l.simulation}',
    child: Material(
      color: context.panel,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const CustomPaint(painter: CameraIllustration()),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: SmallBadge(
                      context.l.simulation,
                      dark: true,
                      icon: Icons.videocam_outlined,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${online ? context.l.connected : context.l.lastKnown} · $time',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class GuestCodeCard extends StatefulWidget {
  const GuestCodeCard({super.key});
  @override
  State<GuestCodeCard> createState() => _GuestCodeCardState();
}

class _GuestCodeCardState extends State<GuestCodeCard> {
  bool _visible = false;
  @override
  Widget build(BuildContext context) => BmtCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmallBadge(context.l.sampleOnly, icon: Icons.science_outlined),
        const SizedBox(height: 12),
        Text(
          context.l.sampleGuest,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _visible ? '428 619' : '••• •••',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '${context.l.validUntil} ${context.houseDate(DateTime.utc(2026, 10, 27))}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton.icon(
          onPressed: () => setState(() => _visible = !_visible),
          icon: Icon(
            _visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          label: Text(_visible ? context.l.hideCode : context.l.showCode),
        ),
      ],
    ),
  );
}

class GuestWifiQr extends StatelessWidget {
  const GuestWifiQr({super.key, this.version = 1});
  final int version;
  @override
  Widget build(BuildContext context) => BmtCard(
    child: Column(
      children: [
        Text(context.l.wifiQr, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Semantics(
          label: context.l.wifiQr,
          child: QrImageView(
            data:
                'WIFI:T:WPA;S:${context.l.wifiSsid};P:${context.l.wifiPassword}$version;;',
            size: 164,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: BmtColors.ink,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: BmtColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${context.l.wifiSsid} · ${context.l.wifiPassword}$version',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.l.wifiCredentials,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          context.l.qrHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
