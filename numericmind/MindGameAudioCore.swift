import SwiftUI
import Combine
import AVFoundation

@MainActor
final class MindGameAudioCore: ObservableObject {

    static let shared = MindGameAudioCore()

    @Published private(set) var isEnabled: Bool = true

    private var sessionReady: Bool = false
    private var player: AVAudioPlayer?
    private var lastKey: String?

    private init() {}

    func setEnabled(_ value: Bool) {
        isEnabled = value
        if value == false {
            stop()
        }
    }

    func prepare() {
        ensureSession()
    }

    func playTap() {
        play(systemName: "tap")
    }

    func playTick() {
        play(systemName: "tick")
    }

    func playSuccess() {
        play(systemName: "success")
    }

    func playFail() {
        play(systemName: "fail")
    }

    func stop() {
        player?.stop()
        player = nil
        lastKey = nil
    }

    private func play(systemName: String) {
        guard isEnabled else { return }
        ensureSession()

        let key = systemName
        if lastKey == key, player?.isPlaying == true { return }
        lastKey = key

        if let url = Bundle.main.url(forResource: systemName, withExtension: "wav") {
            do {
                let p = try AVAudioPlayer(contentsOf: url)
                p.prepareToPlay()
                p.play()
                player = p
            } catch {
                player = nil
            }
        } else {
            player = nil
        }
    }

    private func ensureSession() {
        guard sessionReady == false else { return }
        sessionReady = true
        do {
            let s = AVAudioSession.sharedInstance()
            try s.setCategory(.ambient, options: [.mixWithOthers])
            try s.setActive(true, options: [])
        } catch {
            sessionReady = false
        }
    }
}
