import Combine
import SwiftUI

struct MindGamePlayContainer: View {

    @EnvironmentObject private var router: MindGameRouter
    @EnvironmentObject private var launch: MindGameLaunchStore
    @EnvironmentObject private var session: MindGameSessionState
    @EnvironmentObject private var orientation: MindGameOrientationManager

    @StateObject private var model = MindGamePlayCoordinator()

    let onReady: () -> Void

    init(onReady: @escaping () -> Void) {
        self.onReady = onReady
    }

    var body: some View {
        let start = launch.restoreResume() ?? launch.playPoint

        ZStack {
            Color.black.ignoresSafeArea()

            MindGamePlayView(
                startPoint: start,
                launch: launch,
                session: session,
                orientation: orientation
            ) {
                model.markReady()
                onReady()
            }
            .opacity(model.fadeIn ? 1 : 0)
            .animation(.easeOut(duration: 0.32), value: model.fadeIn)

            if model.showOverlay {
                loadingOverlay
            }

            Color.black
                .opacity(model.dimLayer)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.22), value: model.dimLayer)
        }
        .onAppear {
            model.onAppear()
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                MindGameLoadingScreen()
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
        }
        .transition(.opacity)
    }
}
