import UIKit
import Flutter
import PassKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Under the UIScene lifecycle the implicit engine is created before any scene
  /// connects, and `UIApplicationDelegate.window` is nil — so the old
  /// `window?.rootViewController as! FlutterViewController` lookup in
  /// `didFinishLaunchingWithOptions` would have crashed on launch. Plugin
  /// registration and the application-level wallet channel move here instead,
  /// taking the binary messenger from the engine bridge rather than from a view
  /// controller.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "bg.fivekmpark.5kmrun/wallet",
      binaryMessenger: engineBridge.applicationRegistrar.messenger())

    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "isAvailable":
        result(PKPassLibrary.isPassLibraryAvailable())

      case "addToWallet":
        guard let args = call.arguments as? [String: Any],
              let userId = args["userId"] as? Int,
              let userName = args["userName"] as? String,
              let userStatus = args["userStatus"] as? String else {
          result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
          return
        }
        self?.presentWalletPass(userId: userId, userName: userName, userStatus: userStatus,
                                 flutterResult: result)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func presentWalletPass(userId: Int, userName: String, userStatus: String,
                                  flutterResult: @escaping FlutterResult) {
    do {
      let passURL = try WalletPassGenerator.generatePass(
        userId: userId, userName: userName, userStatus: userStatus)

      let passData = try Data(contentsOf: passURL)
      let pass = try PKPass(data: passData)

      guard let passVC = PKAddPassesViewController(pass: pass) else {
        flutterResult(FlutterError(code: "PASS_ERROR", message: "Could not present pass", details: nil))
        return
      }
      passVC.delegate = self

      DispatchQueue.main.async {
        AppDelegate.topViewController()?.present(passVC, animated: true)
      }
      flutterResult(true)
    } catch {
      flutterResult(FlutterError(code: "PASS_ERROR", message: error.localizedDescription, details: "\(error)"))
    }
  }

  /// Windows belong to scenes under the UIScene lifecycle, so the presenting
  /// controller is resolved through the active window scene instead of the old
  /// `self.window?.rootViewController`, which is now always nil.
  private static func topViewController() -> UIViewController? {
    let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene = windowScenes.first { $0.activationState == .foregroundActive } ?? windowScenes.first
    guard let window = scene?.windows.first(where: \.isKeyWindow) ?? scene?.windows.first else {
      return nil
    }
    var top = window.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}

extension AppDelegate: PKAddPassesViewControllerDelegate {
  func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
    controller.dismiss(animated: true)
  }
}
