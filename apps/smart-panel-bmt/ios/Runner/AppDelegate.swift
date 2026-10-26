import Flutter
import UIKit
import AudioToolbox
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "BMTDemoFeedback")!
    let channel = FlutterMethodChannel(name: "bmt.demo/feedback", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "start":
        // One short foreground cue. System silent/Focus settings remain in control.
        AudioServicesPlayAlertSound(SystemSoundID(1005))
        result(nil)
      case "stop":
        result(nil)
      case "cameraAttachment":
        let key = registrar.lookupKey(forAsset: "assets/mock/camera-event.png")
        guard let source = Bundle.main.url(forResource: key, withExtension: nil) else {
          result(FlutterError(code: "asset_missing", message: "Demo image unavailable", details: nil))
          return
        }
        do {
          // UserNotifications takes ownership of this unique temporary copy.
          let target = FileManager.default.temporaryDirectory
            .appendingPathComponent("bmt-camera-\(UUID().uuidString).png")
          try FileManager.default.copyItem(at: source, to: target)
          result(target.path)
        } catch {
          result(FlutterError(code: "attachment_failed", message: "Demo image unavailable", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
