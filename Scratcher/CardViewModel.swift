import Combine

@MainActor
final class CardStateHolder: ObservableObject {
    @Published var cardState: CardState = .unscratched
}
