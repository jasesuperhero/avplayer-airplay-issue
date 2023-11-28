import SwiftUI
import AVFoundation
import MediaPlayer
import Combine

enum MediaAssets {
    static let first = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!
    static let second = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!
}

struct ContentView: View {
    @StateObject var vm = ViewModel()

    var body: some View {
        VStack {
            VStack {
                Text("Current Player:")
                Text("status: \(vm.player.status.rawValue)").font(.subheadline)
                Text("timeControlStatus: \(vm.player.timeControlStatus.rawValue)").font(.subheadline)
                Text("rate: \(vm.player.rate)").font(.subheadline)
                Text("items: \(vm.player.items().count)").font(.subheadline)
            }

            if let next = vm.next {
                Text("Next player exists")
            } else {
                Text("Next player is empty")
            }

            HStack {
                AirPlayButton()
                    .frame(width: 40, height: 40)
            }

            HStack {
                if vm.player.rate > 0.0 {
                    Button("Pause") { vm.pause() }
                        .buttonStyle(.bordered)
                } else {
                    Button("Play") { vm.play() }
                        .buttonStyle(.bordered)
                }
            }

            Button("🔥 Create next player") {
                // 🔥🔥🔥: With this the sound disappears
                vm.next = AVQueuePlayer.make(items: [
                    AVPlayerItem(url: MediaAssets.first)
                ])
            }
            .buttonStyle(.bordered)

            HStack {
                Text("\(vm.currentTime)")
                Slider(
                    value: .init(get: { vm.currentTime }, set: { _ in }),
                    in: 0...vm.duration + 1,
                    onEditingChanged: { _ in }
                )
                Text("\(vm.duration)")
            }
            Spacer()
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: AVPlayer.didInitPlayerNotification)) { _ in
            print("!: did create new player notification")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                vm.next?.insert(AVPlayerItem(url: MediaAssets.first), after: nil)
            }
            if AVAudioSession.sharedInstance()
                .currentRoute
                .outputs
                .contains(where: { $0.portType == .airPlay })
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vm.player.seek(
                        to: vm.player.currentTime(),
                        toleranceBefore: .zero,
                        toleranceAfter: .zero
                    )

                    print("!: did toggle player")
                }
            }
        }
    }
}

class ViewModel: ObservableObject {
    var player: AVQueuePlayer {
        didSet {
            cancellables = Set()
        }
    }

    @Published var isPlaying = false
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0

    var next: AVQueuePlayer? = AVQueuePlayer(items: [AVPlayerItem(url: MediaAssets.first)])
    var cancellables = Set<AnyCancellable>()
    private let session = AVAudioSession.sharedInstance()

    init() {
        self.player = AVQueuePlayer.make(items: [
            AVPlayerItem(url: MediaAssets.first),
            AVPlayerItem(url: MediaAssets.second),
        ])
        self.player.actionAtItemEnd = .advance

        try? session.setActive(true)
        try? session.setCategory(.playback)

        subscribe()
    }

    func subscribe() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        player.periodicTimePublisher(forInterval: interval, queue: .main)
            .sink { [weak self] time in
                guard let self else { return }

                self.currentTime = time.seconds

                Task { @MainActor in
                    if let duration = try await self.player.currentItem?.asset.load(.duration) {
                        self.duration = duration.seconds
                    }
                }
            }
            .store(in: &cancellables)
    }

    lazy var items: [URL] = [
        MediaAssets.first,
        MediaAssets.second,
    ]

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func next(_ next: AVQueuePlayer) {
        player = next
        self.next = nil
        subscribe()
        player.play()

        objectWillChange.send()
    }
}

extension AVQueuePlayer {
    static func make(items: [AVPlayerItem]) -> AVQueuePlayer {
        let p = AVQueuePlayer(items: items)
        p.allowsExternalPlayback = false // This is valuable!

        return p
    }
}
