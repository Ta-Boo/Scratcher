import SwiftUI

enum CardState: Equatable {
    case unscratched
    case scratched(String)
    case activated(String)
    var isScratchable: Bool {
        switch self {
        case .scratched, .activated:
            return false
        case .unscratched:
            return true
        }
    }
    var isActivable: Bool {
        switch self {
        case .unscratched, .activated:
            return false
        case .scratched:
            return true
        }
    }
    var code: String {

        switch self {
        case .scratched(let code), .activated(let code):
            return code
        case .unscratched:
            return "*** *** ***"
        }
    }

}

struct CardView: View {
    typealias C = Constants
    struct Constants {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Double = 0.6
        static let gradientTopOpacity: Double = 0.8
        static let gradientBottomOpacity: Double = 0.5
        static let shadowOffsetY: CGFloat = 2
        static let shadowOffsetX: CGFloat = 0
        static let cardHeight: Double = (UIScreen.main.bounds.height * 0.25)
    }
    @EnvironmentObject var currentState: CardStateHolder

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: C.cornerRadius)
                .fill(
                    Gradient(
                        colors: [
                            .indigo.opacity(C.gradientTopOpacity),
                            .indigo.opacity(C.gradientBottomOpacity)
                        ]
                    )
                )
                .shadow(
                    color: Color.accent.opacity(C.shadowOpacity),
                    radius: C.shadowRadius,
                    x: C.shadowOffsetX,
                    y: C.shadowOffsetY
                )
            Text(currentState.cardState.code)
                .font(.title.bold())
                .padding()
                .foregroundStyle(Color.textPrimary)
            stateView
        }
        .frame(maxHeight: C.cardHeight)
    }

    @ViewBuilder
    var stateView: some View {
        switch currentState.cardState {
        case .scratched:
            Image(.scratch)
                .resizable()
                .scaledToFill()
                .foregroundStyle(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: C.cornerRadius))
        case .unscratched:
            RoundedRectangle(cornerRadius: C.cornerRadius)
                .fill(.indigo)

        case .activated:
            Group {
                RoundedRectangle(cornerRadius: C.cornerRadius)
                    .fill(Color.clear)
                    .strokeBorder(Color.green, lineWidth: 4)

                VStack {
                    Spacer()
                    Label("Activated", systemImage: "checkmark")
                        .font(.body)
                        .foregroundColor(.green)
                }
                .padding()
            }
        }

    }

}
