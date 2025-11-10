//Created by Tobiáš Hládek on 09/11/2025.
// 

import SwiftUI

@main
struct ScratcherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
        }
    }
}
