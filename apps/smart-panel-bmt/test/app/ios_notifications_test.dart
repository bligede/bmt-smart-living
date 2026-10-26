import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_panel_bmt/app/notifications.dart';
import 'package:smart_panel_bmt/domain/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  const feedback = MethodChannel('bmt.demo/feedback');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  bool allowed = true;
  Completer<bool>? pendingPermission;
  late DemoNotifications notifications;

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    allowed = true;
    pendingPermission = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'initialize':
          return true;
        case 'getNotificationAppLaunchDetails':
          return {
            'notificationLaunchedApp': true,
            'notificationResponse': {
              'payload': 'c|gate',
              'notificationResponseType': 0,
            },
          };
        case 'requestPermissions':
          return pendingPermission?.future ?? allowed;
        case 'checkPermissions':
          return {'isEnabled': allowed};
        default:
          return null;
      }
    });
    messenger.setMockMethodCallHandler(feedback, (call) async {
      calls.add(call);
      return call.method == 'cameraAttachment' ? '/mock/bmt-camera.png' : null;
    });
    notifications = DemoNotifications();
    await notifications.initialize(
      critical: 'Kritis',
      important: 'Penting',
      info: 'Info',
    );
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(feedback, null);
    debugDefaultTargetPlatformOverride = null;
  });
  Future<NotificationResult> sample() => notifications.sample(
    connection: const DemoConnection(),
    title: 'Demo',
    body: 'Simulasi',
    channelName: 'Info',
  );
  Future<NotificationResult> camera() => notifications.showAlert(
    alert: HomeAlert(
      id: 1,
      kind: AlertKind.values.first,
      level: AlertLevel.critical,
      time: DateTime(2026),
      camera: CameraId.gate,
    ),
    profileId: 'c',
    connection: const DemoConnection(),
    title: 'Demo',
    body: 'Simulasi',
    channelName: 'Kritis',
  );

  test(
    'iOS does not prompt at launch and restores camera notification target',
    () {
      final args = calls.first.arguments as Map;
      expect(args['requestAlertPermission'], isFalse);
      expect(args['requestSoundPermission'], isFalse);
      expect(args['requestBadgePermission'], isFalse);
      expect(args['requestCriticalPermission'], isFalse);
      expect(notifications.launchProfile, 'c');
      expect(notifications.launchCamera, CameraId.gate);
    },
  );
  test('iOS denial and offline routes never show an OS notification', () async {
    allowed = false;
    expect(await sample(), NotificationResult.denied);
    expect(await camera(), NotificationResult.denied);
    expect(
      await notifications.sample(
        connection: const DemoConnection(internet: false),
        title: 'Demo',
        body: '',
        channelName: '',
      ),
      NotificationResult.blocked,
    );
    expect(calls.where((c) => c.method == 'show'), isEmpty);
  });
  test(
    'iOS camera attachment and routing retain ordinary alert delivery',
    () async {
      expect(await camera(), NotificationResult.shown);
      final args =
          calls.singleWhere((c) => c.method == 'show').arguments as Map;
      expect(args['payload'], 'c|gate');
      final platform = args['platformSpecifics'] as Map;
      expect(
        (platform['attachments'] as List).single['filePath'],
        '/mock/bmt-camera.png',
      );
      expect(platform['interruptionLevel'], InterruptionLevel.active.index);
    },
  );
  test(
    'changing role while iOS permission is pending cancels the sample',
    () async {
      pendingPermission = Completer<bool>();
      final result = sample();
      await Future<void>.delayed(Duration.zero);
      await notifications.clear();
      pendingPermission!.complete(true);
      expect(await result, NotificationResult.blocked);
      expect(calls.where((c) => c.method == 'show'), isEmpty);
      expect(notifications.launchCamera, isNull);
    },
  );
  test(
    'iOS feedback uses the native channel and permission errors are recoverable',
    () async {
      await notifications.emergencyFeedback(true);
      await notifications.emergencyFeedback(false);
      expect(
        calls.where((c) => c.method == 'start' || c.method == 'stop').length,
        2,
      );
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'unavailable'),
      );
      expect(await sample(), NotificationResult.unavailable);
    },
  );
}
