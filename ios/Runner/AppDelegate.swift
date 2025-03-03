import UIKit
import Flutter
import CleverTapSDK
import SignedCallSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        CleverTap.setDebugLevel(CleverTapLogLevel.off.rawValue)
        CleverTap.autoIntegrate()
        SignedCall.cleverTapInstance = CleverTap.sharedInstance()
        
        guard let flutterVC = UIApplication.shared.windows.first?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        let navigationController = UINavigationController(rootViewController: flutterVC)
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        
        guard let rootView = window?.rootViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        SignedCall.registerVoIP()
        SignedCall.rootViewController = rootView
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
