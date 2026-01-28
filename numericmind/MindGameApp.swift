import SwiftUI
import Combine

@main
struct MindGameApp: App {

    @UIApplicationDelegateAdaptor(MindGameFlowDelegate.self) private var flow

    @StateObject private var router = MindGameRouter()
    @StateObject private var launch = MindGameLaunchStore()
    @StateObject private var session = MindGameSessionState()
    @StateObject private var orientation = MindGameOrientationManager()

    var body: some Scene {
        WindowGroup {
            MindGameEntryScreen()
                .environmentObject(router)
                .environmentObject(launch)
                .environmentObject(session)
                .environmentObject(orientation)
        }
    }
}
