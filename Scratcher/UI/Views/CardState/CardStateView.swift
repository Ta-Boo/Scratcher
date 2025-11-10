import SwiftUI
import Logger

struct CardStateView: View {
    @EnvironmentObject private var navigation: NavigationService
    @EnvironmentObject private var cardStateHolder: CardStateHolder

    var body: some View {
        VStack(spacing: 0) {
            CardView()
                .padding()
            Spacer()
            Button("Scratch card") {
                Logger.log("Tapped scratch card from state: \(cardStateHolder.cardState)")
                navigation.navigate(to: .scratchCard, modally: true)
            }
            .buttonStyle(.secondary)
            .disabled(!cardStateHolder.cardState.isScratchable)
            .padding()

            Button("Activate") {
                Logger.log("Tapped card activation from state: \(cardStateHolder.cardState)")
                navigation.navigate(to: .activation, modally: true)
            }
            .buttonStyle(.primary)
            .disabled(!cardStateHolder.cardState.isActivable)
            .padding()
        }
        .background(Color.mainBackground)
        .environmentObject(cardStateHolder)

    }
}
