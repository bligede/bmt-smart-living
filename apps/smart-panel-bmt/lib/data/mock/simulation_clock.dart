import 'dart:async';

/// One virtual clock for the house, with monotonic real ticks for command deadlines.
class SimulationClock {
  SimulationClock({DateTime? start})
    : now = start ?? DateTime.utc(2026, 10, 25, 6, 5);
  DateTime now;
  int speed = 1;
  int realMilliseconds = 0;
  int virtualMilliseconds = 0;
  Timer? _timer;
  final _ticks = StreamController<int>.broadcast(sync: true);
  Stream<int> get ticks => _ticks.stream;
  void start() => _timer ??= Timer.periodic(
    const Duration(milliseconds: 100),
    (_) => advance(100),
  );
  void advance(int milliseconds) {
    if (milliseconds <= 0) return;
    realMilliseconds += milliseconds;
    virtualMilliseconds += milliseconds * speed;
    now = now.add(Duration(milliseconds: milliseconds * speed));
    _ticks.add(milliseconds);
  }

  void reset({bool night = false}) {
    now = DateTime.utc(2026, 10, 25, night ? 12 : 6, 5);
    realMilliseconds = 0;
    virtualMilliseconds = 0;
  }

  void dispose() {
    _timer?.cancel();
    _ticks.close();
  }
}

class ScenarioStep {
  const ScenarioStep(this.after, this.action);
  final Duration after;
  final void Function() action;
}

/// Reset/stop invalidates pending steps, including resets from inside an action.
class ScenarioRunner {
  ScenarioRunner(this.clock) {
    _subscription = clock.ticks.listen(_tick);
  }
  final SimulationClock clock;
  late final StreamSubscription<int> _subscription;
  List<ScenarioStep> _steps = [];
  int _startedAt = 0;
  int _generation = 0;
  bool get running => _steps.isNotEmpty;
  void run(List<ScenarioStep> steps) {
    stop();
    _startedAt = clock.virtualMilliseconds;
    _steps = List.of(steps)..sort((a, b) => a.after.compareTo(b.after));
    _tick(0);
  }

  void _tick(int _) {
    final generation = _generation;
    while (_steps.isNotEmpty &&
        clock.virtualMilliseconds - _startedAt >=
            _steps.first.after.inMilliseconds) {
      final step = _steps.removeAt(0);
      step.action();
      if (generation != _generation) return;
    }
  }

  void stop() {
    _generation++;
    _steps.clear();
  }

  void dispose() {
    stop();
    _subscription.cancel();
  }
}
