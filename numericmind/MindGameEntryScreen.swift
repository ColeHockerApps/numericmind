import SwiftUI
import Combine

struct MindGameEntryScreen: View {

    @EnvironmentObject private var router: MindGameRouter
    @EnvironmentObject private var launch: MindGameLaunchStore
    @EnvironmentObject private var session: MindGameSessionState
    @EnvironmentObject private var orientation: MindGameOrientationManager

    @State private var showLoading: Bool = true
    @State private var minTimePassed: Bool = false
    @State private var surfaceReady: Bool = false
    @State private var pendingPoint: URL? = nil
    @State private var didApplyRule: Bool = false

    var body: some View {
        ZStack {
            MindGamePlayContainer {
                surfaceReady = true
                applyOrientationIfPossible()
                tryFinishLoading()
            }
            .opacity(showLoading ? 0 : 1)
            .animation(.easeOut(duration: 0.35), value: showLoading)

            if showLoading {
                MindGameLoadingScreen()
                    .transition(.opacity)
                    .onAppear {
                    }
            }
        }
        .onAppear {

            orientation.allowFlexible()

            showLoading = true
            minTimePassed = false
            surfaceReady = false
            pendingPoint = nil
            didApplyRule = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                minTimePassed = true
                applyOrientationIfPossible()
                tryFinishLoading()
            }
        }
        .onReceive(orientation.$activeValue) { next in
            pendingPoint = next
            applyOrientationIfPossible()
        }
    }

    private func applyOrientationIfPossible() {
        print(
            minTimePassed,
            surfaceReady,
            didApplyRule,
            pendingPoint?.absoluteString ?? "nil"
        )

        guard didApplyRule == false else { return }
        guard minTimePassed && surfaceReady else { return }
        guard let next = pendingPoint else { return }

        if isSame(next, launch.playPoint) {
            MindGameFlowDelegate.shared?.lockPortrait()
        } else {
            MindGameFlowDelegate.shared?.allowFlexible()
        }

        didApplyRule = true
    }

    private func tryFinishLoading() {
        print(
            minTimePassed,
            surfaceReady
        )

        guard minTimePassed && surfaceReady else { return }

        withAnimation(.easeOut(duration: 0.35)) {
            showLoading = false
        }
    }

    private func isSame(_ a: URL, _ b: URL) -> Bool {
        normalize(a) == normalize(b)
    }

    private func normalize(_ u: URL) -> String {
        var s = u.absoluteString
        while s.count > 1, s.hasSuffix("/") { s.removeLast() }
        return s
    }
}
