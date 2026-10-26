import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/labels.dart';
import '../core/tokens.dart';
import '../core/widgets/controls.dart';
import '../core/widgets/surfaces.dart';
import '../domain/models.dart';
import '../features/demo/demo_panel.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/home/foundation_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/secondary_screens.dart';
import '../features/home/p0_screens.dart';
import 'providers.dart';
import 'notifications.dart';
import '../features/rental/rental_screens.dart';
import '../features/automations/automations_screen.dart';
import '../features/devices/add_device_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/energy/monthly_report_screen.dart';
import '../features/support/support_screens.dart';
import '../features/guest/guest_screen.dart';
import '../features/camera/camera_timeline.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  final notifications = ref.read(notificationsProvider);
  ref.listen(
    demoProvider.select((s) => (s.role, s.home.members)),
    (_, _) => refresh.value++,
  );
  final router = GoRouter(
    refreshListenable: refresh,
    initialLocation:
        notifications.launchCamera != null &&
            ref
                .read(repositoriesProvider)
                .cameras
                .camerasFor(UserRole.owner)
                .contains(notifications.launchCamera)
        ? '/camera/${notifications.launchCamera!.name}'
        : ref.read(preferencesProvider) != null &&
              ref.read(preferencesProvider)?.getBool('onboardingSeen') != true
        ? '/welcome'
        : '/',
    redirect: (context, state) {
      final role = ref.read(demoProvider).role;
      final revoked =
          role == UserRole.family &&
          !ref
              .read(demoProvider)
              .home
              .members
              .any((m) => m.active && m.role == UserRole.family);
      if ((role == UserRole.guest || role == UserRole.technician || revoked) &&
          state.uri.path != '/') {
        return '/';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(path: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/rooms', builder: (_, _) => const RoomsScreen()),
          GoRoute(path: '/security', builder: (_, _) => const SecurityScreen()),
          GoRoute(path: '/alerts', builder: (_, _) => const AlertsScreen()),
          GoRoute(path: '/more', builder: (_, _) => const MoreScreen()),
        ],
      ),
      GoRoute(
        path: '/foundation/:id',
        builder: (_, state) => FoundationScreen(
          Foundation.values.firstWhere(
            (f) => f.name == state.pathParameters['id'],
            orElse: () => Foundation.electricity,
          ),
        ),
      ),
      GoRoute(path: '/welcome', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/rental', builder: (_, _) => const RentalScreen()),
      GoRoute(path: '/codes', builder: (_, _) => const AccessCodesScreen()),
      GoRoute(
        path: '/automations',
        builder: (_, _) => const AutomationsScreen(),
      ),
      GoRoute(path: '/add-device', builder: (_, _) => const AddDeviceScreen()),
      GoRoute(
        path: '/monthly-report',
        builder: (_, _) => const MonthlyReportScreen(),
      ),
      GoRoute(path: '/service', builder: (_, _) => const ServiceScreen()),
      GoRoute(
        path: '/second-contact',
        builder: (_, _) => const SecondContactScreen(),
      ),
      GoRoute(
        path: '/timeline/:id',
        builder: (_, s) => CameraTimelineScreen(
          CameraId.values.byName(s.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/gallery', builder: (_, _) => const GalleryScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
      GoRoute(path: '/scenes', builder: (_, _) => const ScenesScreen()),
      GoRoute(
        path: '/scene/:id',
        builder: (_, s) =>
            SceneEditorScreen(SceneId.values.byName(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/room/:id',
        builder: (_, s) =>
            RoomDetailScreen(RoomId.values.byName(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/device/:id',
        builder: (_, s) => DeviceDetailScreen(s.pathParameters['id']!),
      ),
      GoRoute(path: '/members', builder: (_, _) => const MembersScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/alert/:id',
        builder: (_, s) =>
            AlertDetailScreen(int.tryParse(s.pathParameters['id']!) ?? -1),
      ),
      GoRoute(
        path: '/camera/:id',
        builder: (_, state) => CameraScreen(
          CameraId.values.firstWhere(
            (c) => c.name == state.pathParameters['id'],
            orElse: () => CameraId.frontGate,
          ),
        ),
      ),
    ],
  );
  ref.onDispose(() {
    notifications.onOpenCamera = null;
    router.dispose();
    refresh.dispose();
  });
  notifications.onOpenCamera = (profile, camera) {
    final s = ref.read(demoProvider);
    if (profile == s.home.profile.id &&
        ref
            .read(repositoriesProvider)
            .cameras
            .camerasFor(s.role)
            .contains(camera)) {
      router.push('/camera/${camera.name}');
    }
  };
  return router;
});

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.path, required this.child});
  final String path;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(demoProvider), l = context.l;
    final guest = s.role == UserRole.guest,
        technician = s.role == UserRole.technician;
    final large = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final showPath = path != '/' || guest || technician;
    final paths = ['/', '/rooms', '/security', '/alerts', '/more'];
    final labels = [l.home, l.rooms, l.security, l.alerts, l.more];
    final icons = [
      Icons.home_outlined,
      Icons.meeting_room_outlined,
      Icons.shield_outlined,
      Icons.notifications_none_rounded,
      Icons.grid_view_rounded,
    ];
    final selected = paths.indexOf(path).clamp(0, 4);
    final count = ref
        .read(demoProvider.notifier)
        .alerts
        .where((a) => !a.acknowledged)
        .length;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: large ? (showPath ? 144 : 112) : 72,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: DemoLogo(onDemo: () => showDemoPanel(context)),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.appName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: BmtColors.onDark),
            ),
            if (showPath) ...[
              const SizedBox(height: 4),
              Text(
                l.pathName(s.home.connection.path),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: BmtColors.onDark),
              ),
            ],
          ],
        ),
        actions: [
          if (!large)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(child: SmallBadge(l.demo, dark: true)),
            ),
        ],
      ),
      body: ConditionView(
        condition: (guest || technician || path == '/more')
            ? s.condition
            : ViewCondition.normal,
        onRetry: () =>
            ref.read(demoProvider.notifier).condition(ViewCondition.normal),
        child: guest
            ? const GuestScreen()
            : technician
            ? const _TechnicianPreview()
            : s.role == UserRole.family &&
                  !s.home.members.any(
                    (m) => m.active && m.role == UserRole.family,
                  )
            ? Center(child: StateMessage(title: l.noPermission))
            : child,
      ),
      bottomNavigationBar: guest || technician
          ? null
          : SafeArea(
              top: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: context.line)),
                ),
                child: large
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              for (var i = 0; i < 5; i++)
                                Expanded(
                                  child: Semantics(
                                    selected: i == selected,
                                    label: labels[i],
                                    button: true,
                                    child: IconButton(
                                      tooltip: labels[i],
                                      onPressed: () => context.go(paths[i]),
                                      color: i == selected
                                          ? context.accent
                                          : context.muted,
                                      icon: Icon(icons[i]),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            child: Text(
                              labels[selected],
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      )
                    : NavigationBar(
                        selectedIndex: selected,
                        onDestinationSelected: (i) => context.go(paths[i]),
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        indicatorColor: context.isDark
                            ? BmtColors.green900
                            : BmtColors.green50,
                        height: 76,
                        labelTextStyle: WidgetStateProperty.resolveWith(
                          (states) => Theme.of(context).textTheme.labelSmall,
                        ),
                        destinations: [
                          for (var i = 0; i < 5; i++)
                            NavigationDestination(
                              icon: i == 3 && count > 0
                                  ? Badge(
                                      label: Text('$count'),
                                      child: Icon(icons[i]),
                                    )
                                  : Icon(icons[i]),
                              label: labels[i],
                            ),
                        ],
                      ),
              ),
            ),
    );
  }
}

class _TechnicianPreview extends ConsumerWidget {
  const _TechnicianPreview();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final s = ref.watch(demoProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.diagnostics, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(l.diagnosticNote),
        const SizedBox(height: 12),
        Text(l.technicianScope),
        if (s.home.operation.technicianUntil != null)
          Text(
            '${l.validUntil} ${context.houseTime(s.home.operation.technicianUntil!)} ${l.wita}',
          ),
        if (!ref.read(repositoriesProvider).access.technicianActive())
          Text(l.accessExpired),
        const SizedBox(height: 24),
        for (final d in ref.read(demoProvider.notifier).devices) ...[
          BmtCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.deviceName(d.kind),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('${l.status}: ${l.deviceStatus(d.status)}'),
                Text(d.cloud ? l.cloudDependent : l.local),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
