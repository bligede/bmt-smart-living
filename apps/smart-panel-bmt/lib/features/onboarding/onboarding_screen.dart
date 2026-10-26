import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/widgets/surfaces.dart';
import '../../domain/models.dart';
import '../home/p0_screens.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String _profile = 'a';
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final can =
        s.role == UserRole.owner &&
        s.home.connection.atHome &&
        s.home.plnAvailable;
    return ReviewPage(
      title: l.onboarding,
      children: [
        Image.asset(
          'assets/brand/bmt-m-only.png',
          height: 48,
          semanticLabel: l.appName,
        ),
        const SizedBox(height: 24),
        Text(l.appName, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 16),
        Text(l.onboardingNote),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final code in ['id', 'en'])
              ChoiceChip(
                label: Text(code == 'id' ? l.indonesian : l.english),
                selected: s.language == code,
                onSelected: (_) => c.language(code),
              ),
          ],
        ),
        SectionTitle(l.pairing),
        Text(l.pairingNote),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _profile,
          isExpanded: true,
          items: [
            for (final p in ref.read(repositoriesProvider).home.profiles)
              DropdownMenuItem(value: p.id, child: Text(l.profileName(p.id))),
          ],
          onChanged: can ? (v) => setState(() => _profile = v!) : null,
        ),
        const SizedBox(height: 20),
        Center(
          child: Semantics(
            label: l.scanDemoQr,
            child: QrImageView(
              data: 'bmt-demo://profile/$_profile',
              size: 164,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(l.notificationExplain),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: can
              ? () {
                  ref
                      .read(repositoriesProvider)
                      .home
                      .pairHouse(_profile, s.role);
                  ref
                      .read(preferencesProvider)
                      ?.setBool('onboardingSeen', true);
                  context.go('/');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.pairSuccess)));
                }
              : null,
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: Text(l.scanDemoQr),
        ),
        if (!can) Text(l.pairAtHome),
      ],
    );
  }
}
