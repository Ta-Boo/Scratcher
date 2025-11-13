import SwiftUI
import Logger

///Similar  behaviour can be achieved with .task modifier(without explicit canceling,) in case you want to run it on appear. SInce i was not sure i implemented it with button action.
struct CardScratchView: View {

    typealias C = Constants
    struct Constants {
        static let verticalSpacing: CGFloat = 30
        static let cornerRadius: CGFloat = 8
        static let buttonMinHeight: CGFloat = 50
        static let scratchDuration: TimeInterval = 2.0
        static let codeLength: Int = 6
    }
    @EnvironmentObject var cardState: CardStateHolder
    @State private var scratchTask: Task<Void, Error>?

    private var isScratching: Bool { scratchTask != nil }
    private var revealedCode: String? {
        switch cardState.cardState {
        case .scratched(let code):
            return code
        default:
            return nil
        }
    }


    var body: some View {
        VStack(spacing: C.verticalSpacing) {
            if let code = revealedCode {
                VStack {
                    Text("Congratulations! Your code is:")
                        .font(.headline)
                    Text(code)
                        .font(.system(.title, design: .monospaced).bold())
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: C.cornerRadius))
                }
            } else {
                scratchButton
            }
        }
        .padding()
        .onDisappear {
            onDisappear()
        }

    }

    private var scratchButton: some View {
        Button(action: {
            scratchTask = startScratching()
        }) {
            ZStack {
                if isScratching {
                    ProgressView()
                } else {
                    Text("Scratch to Reveal")
                }
            }
            .font(.headline.bold())
            .frame(maxWidth: .infinity, minHeight: C.buttonMinHeight)
        }
        .buttonStyle(.primary)
        .disabled(isScratching)
    }
}

//MARK: Logic
extension CardScratchView {
    private func startScratching() -> Task<Void, Error> {
        return Task {
            defer { scratchTask = nil }
            do {
                try await Task.sleep(for: .seconds(C.scratchDuration))
                await MainActor.run {
                    cardState.cardState = .scratched(UUID().uuidString)
                }
            } catch is CancellationError {
                Logger.log("Scratch task was cancelled.", level: .info)
            } catch {
                Logger.log("Unexpected error during scratching: \(error)", level: .error)
            }
        }
    }

    private func onDisappear() {
        let hashValue = scratchTask?.hashValue ?? 0
        Logger.log("CardScratchView disappeared, cancelling scratch task if active. Task: \(hashValue)", level: .info)
        scratchTask?.cancel()
    }
}
