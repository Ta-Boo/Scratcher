import SwiftUI
import Logger
import APIClient

struct CardActivationView: View {

    typealias C = Constants
    struct Constants {
        static let topPadding: CGFloat = 40
        static let verticalSpacing: CGFloat = 30
        static let codeSpacing: CGFloat = 12
        static let buttonMinHeight: CGFloat = 50
        static let minimumRequiredVersion: Double = 6.1
    }
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cardState: CardStateHolder
    @State private var activationTask: Task<Void, Error>?
    @State var alert: AlertModel?

    @Inject private var apiClient: APIClient
    private var isActivating: Bool { activationTask != nil }

    private var code: String {
        return cardState.cardState.code
    }

    var body: some View {
        VStack(spacing: C.verticalSpacing) {
            Text("Activate Your Card")
                .font(.largeTitle.bold())
                .padding(.top, C.topPadding)

            VStack(spacing: C.codeSpacing) {
                Text("Code to activate:")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)

                Text(code)
                    .font(.system(.title, design: .monospaced).bold())
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            Spacer()

            Button(action: {
                activationTask = activateCard()
            }) {
                ZStack {
                    if isActivating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Activate Card")
                    }
                }
                .font(.headline.bold())
                .frame(maxWidth: .infinity, minHeight: C.buttonMinHeight)
            }
            .buttonStyle(.primary)
            .disabled(isActivating)
            .padding()
        }
        .padding()
        .background(Color.mainBackground)
        .alert(item: $alert) {
            Alert(title: Text($0.title),
                  message: Text($0.description),
                  dismissButton: .default(Text("OK")))
        }
        .onDisappear {
            let hashValue = activationTask?.hashValue ?? 0
            Logger.log("CardActivationView disappeared, but activation task continues. Task: \(hashValue)", level: .info)
        }
    }

}

//IMO there is no need to use MVVM for such a small app
// MARK: - Logic
extension CardActivationView {
    func activateCard() -> Task<Void, Error> {
        return Task.detached { @MainActor in
            defer {
                activationTask = nil
            }

            do {
                Logger.log("Starting card activation with code: \(code)", level: .info)

                let apiClient = apiClient
                let endpoint = ActivationEndpoint(code: code)
                let response = try await apiClient.requestWithoutAuth(endpoint, responseType: ActivationResponse.self)


                // Parse version and check if greater than minimum required version
                if let version = Double(response.ios), version > C.minimumRequiredVersion {
                    Logger.log("Activation successful! Version \(version) > \(C.minimumRequiredVersion)", level: .info)
                    await MainActor.run {
                        cardState.cardState = .activated(code)
                        dismiss()
                    }
                } else {
                    Logger.log("Activation failed: Version \(response.ios) is not greater than \(C.minimumRequiredVersion)", level: .warning)
                    await MainActor.run {
                        alert = AlertModel(
                            title: "Failure",
                            description: "Card activation failed. Version \(response.ios) does not meet requirements (must be > \(C.minimumRequiredVersion)).",
                        )
                    }
                }
            } catch {
                Logger.log("Activation error: \(error.localizedDescription)", level: .error)
                await MainActor.run {
                    alert = AlertModel(
                        title: "Failure",
                        description: "Something went wrong.",
                    )
                }
            }
        }
    }
}
