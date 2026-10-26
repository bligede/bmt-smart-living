import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';
import '../home/p0_screens.dart';

class P1Page extends ConsumerWidget {
  const P1Page({super.key, required this.feature, required this.children});
  final Feature feature;
  final List<Widget> children;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(demoProvider);
    final c = ref.read(demoProvider.notifier), l = context.l;
    final gate = c.gate(feature);
    return ReviewPage(
      title: l.featureName(feature),
      children: gate == GateDecision.available
          ? children
          : [
              StateMessage(
                title: gate == GateDecision.forbidden
                    ? l.noPermission
                    : l.featureName(feature),
                icon: Icons.lock_outline_rounded,
              ),
            ],
    );
  }
}
