import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  //override init() {
   // super.init()
  //  FirebaseApp.configure()
 // }
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
    FirebaseApp.configure() //
    GeneratedPluginRegistrant.register(with: self) // Should be second
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}