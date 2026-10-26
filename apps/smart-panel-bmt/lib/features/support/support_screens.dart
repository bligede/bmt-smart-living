import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';

import '../shared/feature_page.dart';

class ServiceScreen extends ConsumerStatefulWidget {
  const ServiceScreen({super.key});
  @override
  ConsumerState<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends ConsumerState<ServiceScreen> {
  ServiceCategory _category = ServiceCategory.disruption;
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider), l = context.l;
    return P1Page(
      feature: Feature.service,
      children: [
        Text(l.ticketNote),
        const SizedBox(height: 20),
        RadioGroup<ServiceCategory>(
          groupValue: _category,
          onChanged: (v) => setState(() => _category = v!),
          child: Column(
            children: [
              for (final v in ServiceCategory.values)
                RadioListTile<ServiceCategory>(
                  value: v,
                  title: Text(l.serviceName(v)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: s.home.connection.reachable
              ? () {
                  ref
                      .read(repositoriesProvider)
                      .home
                      .createTicket(_category, s.role);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.ticketSaved)));
                }
              : null,
          icon: const Icon(Icons.add_comment_outlined),
          label: Text(l.createTicket),
        ),
        SectionTitle(l.history),
        if (s.home.p1.tickets.isEmpty) StateMessage(title: l.noData),
        for (final ticket in s.home.p1.tickets.reversed) ...[
          BmtCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMT-DEMO-${ticket.id.toString().padLeft(3, '0')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(l.serviceName(ticket.category)),
                Text('${context.houseTime(ticket.time)} ${l.wita}'),
                Text(l.ticketOpen),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SectionTitle(l.serviceContact),
        const SelectableText('WhatsApp +62 821 4750 8665'),
      ],
    );
  }
}

class SecondContactScreen extends ConsumerWidget {
  const SecondContactScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider), l = context.l;
    return P1Page(
      feature: Feature.secondContacts,
      children: [
        Text(l.secondContactNote),
        const SizedBox(height: 20),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l.family),
          value: s.home.p1.secondContact,
          onChanged: s.home.connection.reachable
              ? (v) => ref
                    .read(repositoriesProvider)
                    .access
                    .setSecondContact(v, s.role)
              : null,
        ),
        Text(s.home.p1.secondContact ? l.contactEnabled : l.contactDisabled),
        if (s.home.p1.secondContact) ...[
          SectionTitle(l.contactAlertCopies),
          for (final a in ref.read(demoProvider.notifier).alerts.reversed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.alertName(a.kind)),
              subtitle: Text('${context.houseTime(a.time)} · ${l.simulation}'),
            ),
        ],
      ],
    );
  }
}
