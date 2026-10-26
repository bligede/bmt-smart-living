import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/labels.dart';
import '../../core/tokens.dart';
import '../../core/widgets/surfaces.dart';
import '../../core/widgets/visuals.dart';
import '../../domain/models.dart';
import '../home/p0_screens.dart';

class CameraTimelineScreen extends ConsumerStatefulWidget {
  const CameraTimelineScreen(this.camera, {super.key});
  final CameraId camera;
  @override
  ConsumerState<CameraTimelineScreen> createState() =>
      _CameraTimelineScreenState();
}

class _CameraTimelineScreenState extends ConsumerState<CameraTimelineScreen> {
  CameraEventKind? _filter;
  int? _hour, _selected;
  bool _playing = false;
  double _base = 0;
  DateTime? _started;
  double _position(DateTime time) =>
      (_base +
              (_playing && _started != null
                  ? time.difference(_started!).inMilliseconds / 1000
                  : 0))
          .clamp(0, 30);
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref
            .read(repositoriesProvider)
            .cameras
            .recordAccess(widget.camera, ref.read(demoProvider).role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(demoProvider),
        c = ref.read(demoProvider.notifier),
        l = context.l;
    final allowed = c.cameras.contains(widget.camera);
    final gate = c.gate(Feature.recording);
    if (!allowed || gate != GateDecision.available) {
      return ReviewPage(
        title: l.timeline,
        children: [
          StateMessage(
            title: !allowed || gate == GateDecision.forbidden
                ? l.noPermission
                : l.recording,
            icon: Icons.lock_outline_rounded,
          ),
        ],
      );
    }
    final events = ref
        .read(repositoriesProvider)
        .cameras
        .eventsFor(widget.camera, s.role, filter: _filter)
        .where(
          (e) =>
              _hour == null ||
              e.time.toUtc().add(const Duration(hours: 8)).hour == _hour,
        )
        .toList();
    final selected = events.where((e) => e.id == _selected);
    final event = selected.isNotEmpty ? selected.first : events.firstOrNull;
    final pos = _position(s.home.time),
        live = s.home.connection.reachable && s.home.plnAvailable;
    return ReviewPage(
      title: l.timeline,
      children: [
        Text(
          l.cameraName(widget.camera),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(l.recordingNote),
        const SizedBox(height: 16),
        if (widget.camera == CameraId.living && s.home.operation.indoorPrivacy)
          StateMessage(title: l.privacyMode)
        else if (!s.home.plnAvailable)
          StateMessage(title: l.camerasNoPower)
        else if (event != null) ...[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CustomPaint(painter: CameraIllustration()),
                Align(
                  alignment: Alignment(-.8 + pos / 30 * 1.6, .5),
                  child: Icon(
                    event.kind == CameraEventKind.vehicle
                        ? Icons.directions_car_outlined
                        : Icons.directions_walk,
                    color: BmtColors.green,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SmallBadge(l.playback, icon: Icons.movie_outlined),
          const SizedBox(height: 8),
          Text(
            '${context.houseDate(event.time)} · ${context.houseTime(event.time.add(Duration(seconds: pos.floor())), seconds: true)} ${l.wita}',
          ),
          Semantics(
            label: l.position,
            child: Slider(
              value: pos,
              max: 30,
              divisions: 30,
              label: '${pos.floor()} s',
              onChanged: live
                  ? (v) => setState(() {
                      _base = v;
                      _started = s.home.time;
                    })
                  : null,
            ),
          ),
          FilledButton.icon(
            onPressed: live
                ? () => setState(() {
                    if (_playing && pos < 30) {
                      _base = pos;
                      _playing = false;
                    } else {
                      _base = pos >= 30 ? 0 : pos;
                      _started = s.home.time;
                      _playing = true;
                    }
                  })
                : null,
            icon: Icon(_playing && pos < 30 ? Icons.pause : Icons.play_arrow),
            label: Text(_playing && pos < 30 ? l.pause : l.play),
          ),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l.all),
              selected: _filter == null,
              onSelected: (_) => setState(() {
                _filter = null;
                _selected = null;
                _base = 0;
                _playing = false;
              }),
            ),
            for (final kind in CameraEventKind.values)
              if (kind == CameraEventKind.motion ||
                  c.gate(Feature.personDetection) == GateDecision.available)
                ChoiceChip(
                  label: Text(l.eventName(kind)),
                  selected: _filter == kind,
                  onSelected: (_) => setState(() {
                    _filter = kind;
                    _selected = null;
                    _base = 0;
                    _playing = false;
                  }),
                ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _hour == null
              ? l.all
              : '${_hour.toString().padLeft(2, '0')}.00 ${l.wita}',
        ),
        Semantics(
          label: l.timeline,
          child: Slider(
            value: (_hour ?? 14).toDouble(),
            max: 23,
            divisions: 23,
            label: '${_hour ?? 14}.00',
            onChanged: live
                ? (v) => setState(() {
                    _hour = v.round();
                    _selected = null;
                    _base = 0;
                    _playing = false;
                  })
                : null,
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _hour = null),
          child: Text(l.all),
        ),
        if (events.isEmpty) StateMessage(title: l.noData),
        for (final e in events)
          ListTile(
            contentPadding: EdgeInsets.zero,
            selected: e.id == event?.id,
            leading: const Icon(Icons.movie_outlined),
            title: Text(l.eventName(e.kind)),
            subtitle: Text('${context.houseTime(e.time)} ${l.wita}'),
            onTap: live
                ? () => setState(() {
                    _selected = e.id;
                    _base = 0;
                    _playing = false;
                  })
                : null,
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.push('/camera/${widget.camera.name}'),
          icon: const Icon(Icons.videocam_outlined),
          label: Text(l.openLive),
        ),
      ],
    );
  }
}
