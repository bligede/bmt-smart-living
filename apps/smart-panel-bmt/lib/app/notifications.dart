import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models.dart';

enum NotificationResult { shown, blocked, denied, unavailable }

final notificationsProvider = Provider<DemoNotifications>(
  (ref) => DemoNotifications(),
);

class DemoNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  int _generation = 0;
  void Function(String, CameraId)? onOpenCamera;
  CameraId? launchCamera;
  String? launchProfile;
  (String, CameraId)? _target(String? payload) {
    final parts = payload?.split('|');
    if (parts == null || parts.length != 2) return null;
    final camera = CameraId.values.where((c) => c.name == parts[1]).firstOrNull;
    return camera == null ? null : (parts[0], camera);
  }

  void _open(String? payload) {
    final target = _target(payload);
    if (target != null) onOpenCamera?.call(target.$1, target.$2);
  }

  static const _feedback = MethodChannel('bmt.demo/feedback');
  bool get _mobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();
  Future<void> initialize({
    required String critical,
    required String important,
    required String info,
  }) async {
    if (!_mobile) return;
    try {
      _ready =
          await _plugin.initialize(
            settings: const InitializationSettings(
              android: AndroidInitializationSettings('ic_stat_home'),
              iOS: DarwinInitializationSettings(
                requestAlertPermission: false,
                requestBadgePermission: false,
                requestSoundPermission: false,
              ),
            ),
            onDidReceiveNotificationResponse: (response) =>
                _open(response.payload),
          ) ??
          false;
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        final target = _target(launch?.notificationResponse?.payload);
        launchProfile = target?.$1;
        launchCamera = target?.$2;
      }
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      for (final channel in [
        AndroidNotificationChannel(
          'bmt_critical',
          critical,
          importance: Importance.max,
        ),
        AndroidNotificationChannel(
          'bmt_important',
          important,
          importance: Importance.high,
        ),
        AndroidNotificationChannel(
          'bmt_info',
          info,
          importance: Importance.defaultImportance,
        ),
      ]) {
        await android?.createNotificationChannel(channel);
      }
    } on PlatformException {
      _ready = false;
    }
  }

  Future<NotificationResult> sample({
    required DemoConnection connection,
    required String title,
    required String body,
    required String channelName,
  }) async {
    if (!connection.phoneNotificationsAvailable) {
      return NotificationResult.blocked;
    }
    if (!_ready) return NotificationResult.unavailable;
    final generation = _generation;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final allowed = defaultTargetPlatform == TargetPlatform.iOS
          ? await _ios?.requestPermissions(
                  alert: true,
                  sound: true,
                  badge: false,
                ) ??
                false
          : await android?.requestNotificationsPermission() ?? false;
      if (!allowed) return NotificationResult.denied;
      if (generation != _generation) return NotificationResult.blocked;
      await _plugin.show(
        id: 100,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          iOS: const DarwinNotificationDetails(presentBadge: false),
          android: AndroidNotificationDetails(
            'bmt_info',
            channelName,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
      );
      if (generation != _generation) await _plugin.cancel(id: 100);
      return NotificationResult.shown;
    } on PlatformException {
      return NotificationResult.unavailable;
    }
  }

  Future<void> emergencyFeedback(bool active) async {
    if (!_mobile) return;
    try {
      await _feedback.invokeMethod<void>(active ? 'start' : 'stop');
    } on PlatformException {
      /* UI remains usable. */
    } on MissingPluginException {
      /* Widget rendering has no native feedback channel. */
    }
  }

  Future<void> clear() async {
    _generation++;
    launchCamera = null;
    launchProfile = null;
    if (_ready) await _plugin.cancelAll();
  }

  Future<NotificationResult> showAlert({
    required HomeAlert alert,
    required String profileId,
    required DemoConnection connection,
    required String title,
    required String body,
    required String channelName,
  }) async {
    if (!connection.phoneNotificationsAvailable) {
      return NotificationResult.blocked;
    }
    if (!_ready) return NotificationResult.unavailable;
    final generation = _generation, id = _generation * 10000 + alert.id;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final allowed = defaultTargetPlatform == TargetPlatform.iOS
          ? (await _ios?.checkPermissions())?.isEnabled
          : await android?.areNotificationsEnabled();
      if (allowed != true) {
        return NotificationResult.denied;
      }
      if (generation != _generation) return NotificationResult.blocked;
      final critical = alert.level == AlertLevel.critical,
          important = alert.level == AlertLevel.important;
      final picture =
          alert.camera == null ||
              defaultTargetPlatform != TargetPlatform.android
          ? null
          : BigPictureStyleInformation(
              ByteArrayAndroidBitmap(
                (await rootBundle.load(
                  'assets/mock/camera-event.png',
                )).buffer.asUint8List(),
              ),
              contentTitle: title,
              summaryText: body,
            );
      String? attachment;
      if (alert.camera != null && defaultTargetPlatform == TargetPlatform.iOS) {
        attachment = await _feedback.invokeMethod<String>('cameraAttachment');
      }
      if (generation != _generation) return NotificationResult.blocked;
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        payload: alert.camera == null
            ? null
            : '$profileId|${alert.camera!.name}',
        notificationDetails: NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentBadge: false,
            threadIdentifier: 'bmt_demo',
            attachments: attachment == null
                ? null
                : [DarwinNotificationAttachment(attachment)],
            interruptionLevel: InterruptionLevel.active,
          ),
          android: AndroidNotificationDetails(
            critical
                ? 'bmt_critical'
                : important
                ? 'bmt_important'
                : 'bmt_info',
            channelName,
            styleInformation: picture,
            importance: critical
                ? Importance.max
                : important
                ? Importance.high
                : Importance.defaultImportance,
            priority: critical
                ? Priority.max
                : important
                ? Priority.high
                : Priority.defaultPriority,
          ),
        ),
      );
      if (generation != _generation) await _plugin.cancel(id: id);
      return NotificationResult.shown;
    } on PlatformException {
      return NotificationResult.unavailable;
    }
  }
}
