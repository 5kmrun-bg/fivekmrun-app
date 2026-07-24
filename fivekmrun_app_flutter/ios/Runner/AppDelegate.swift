import UIKit
import Flutter
import PassKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "bg.fivekmpark.5kmrun/wallet",
                                       binaryMessenger: controller.binaryMessenger)

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

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
        self.window?.rootViewController?.present(passVC, animated: true)
      }
      flutterResult(true)
    } catch {
      flutterResult(FlutterError(code: "PASS_ERROR", message: error.localizedDescription, details: "\(error)"))
    }
  }
}

extension AppDelegate: PKAddPassesViewControllerDelegate {
  func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
    controller.dismiss(animated: true)
  }
}
