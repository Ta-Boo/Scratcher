import SwiftUI
import Logger

struct CardStateView: View {
    typealias C = Constants
    struct Constants {
        static let spacing: CGFloat = 0
    }
    @EnvironmentObject private var navigation: NavigationService
    @EnvironmentObject private var cardStateHolder: CardStateHolder

    var body: some View {
        VStack(spacing: C.spacing) {
            CardView()
                .padding()
                .accessibilityElement(children: .contain)
                .accessibilityLabel(cardAccessibilityLabel)
            Spacer()
            Button("Scratch card") {
                Logger.log("Tapped scratch card from state: \(cardStateHolder.cardState)")
                navigation.navigate(to: .scratchCard, modally: true)
            }
            .buttonStyle(.secondary)
            .disabled(!cardStateHolder.cardState.isScratchable)
            .accessibilityLabel("Scratch card")
            .accessibilityHint(cardStateHolder.cardState.isScratchable ? "Double tap to reveal your scratch card code" : "Card already scratched")
            .padding()

            Button("Activate") {
                Logger.log("Tapped card activation from state: \(cardStateHolder.cardState)")
                navigation.navigate(to: .activation, modally: true)
            }
            .buttonStyle(.primary)
            .disabled(!cardStateHolder.cardState.isActivable)
            .accessibilityLabel("Activate card")
            .accessibilityHint(cardStateHolder.cardState.isActivable ? "Double tap to activate your card with the revealed code" : activationHint)
            .padding()
        }
        .background(Color.mainBackground)
        .environmentObject(cardStateHolder)
    }

    private var cardAccessibilityLabel: String {
        switch cardStateHolder.cardState {
        case .unscratched:
            return "Scratch card, not yet scratched"
        case .scratched(let code):
            return "Scratch card, revealed code: \(code), ready to activate"
        case .activated(let code):
            return "Scratch card, activated with code: \(code)"
        }
    }

    private var activationHint: String {
        switch cardStateHolder.cardState {
        case .unscratched:
            return "Scratch the card first to reveal the code"
        case .activated:
            return "Card already activated"
        default:
            return ""
        }
    }
}
