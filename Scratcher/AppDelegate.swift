import Logger
import UIKit
import Swinject
import APIClient

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Logger.log("Application did finish launching. Launch options: \(String(describing: launchOptions))")
        registerInjects()
        return true
    }



    func applicationWillTerminate(_ application: UIApplication) {
        Logger.log("Application willTerminate")

    }
}

extension AppDelegate {
    func registerInjects() {
        let container = Container()
        InjectSettings.resolver = container

        container.register(APIClient.self) { _ in
            APIClient(url: "https://api.o2.sk")
        }
    }
}

