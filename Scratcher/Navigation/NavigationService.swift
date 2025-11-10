import SwiftUI
import Combine

enum AppRoute: Hashable, Identifiable {
    case scratchCard
    case activation

    var id: Int { hashValue }
}

enum AppRoot {
    case cardState
}

class NavigationService: ObservableObject {

    @Published var path = NavigationPath()
    @Published var modalPath: NavigationPath = NavigationPath()
    @Published var presentedRoute: AppRoute?
    @Published var currentRoot: AppRoot = .cardState

    func navigate(to route: AppRoute, modally: Bool = false) {
        if modally {
            presentedRoute = route
            modalPath = NavigationPath()
        } else if presentedRoute != nil {
            modalPath.append(route)
        } else {
            path.append(route)
        }
    }

    func pop() {
        if presentedRoute != nil {
            modalPath.removeLast()
        } else if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func dismiss() {
        presentedRoute = nil
        modalPath = NavigationPath()
    }

    func clear() {
        dismiss()
        popToRoot()
    }

    func changeRoot(to root: AppRoot) {
        clear()
        currentRoot = root
    }
}

struct RootNavigationView: View {
    @StateObject private var navigationService = NavigationService()
    @StateObject var cardState: CardStateHolder = CardStateHolder()

    var body: some View {
        navigationView
            .sheet(item: Binding<AppRoute?>(
                get: { navigationService.presentedRoute },
                set: { _ in navigationService.dismiss() }
            )) { route in
                NavigationStack(
                    path: $navigationService.modalPath
                ) {
                    routeDestination(route)
                        .presentationBackground(Color.mainBackground)
                        .background(Color.mainBackground.ignoresSafeArea())
                        .shadow(radius: 0)

                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") { //TODO: Localize
                                    navigationService.dismiss()
                                }
                            }
                        }
                        .navigationDestination(for: AppRoute.self) { subRoute in
                            routeDestination(subRoute)
                                .background(Color.mainBackground.ignoresSafeArea())
                                .presentationBackground(Color.mainBackground)
                        }
                }
            }
            .environmentObject(navigationService)
            .environmentObject(cardState)
    }

    @ViewBuilder
    var navigationView: some View {
        NavigationStack(path: $navigationService.path) {
            rootView
                .navigationDestination(for: AppRoute.self) { route in
                    routeDestination(route)
                }
        }
        .accentColor(.accent)
    }

    @ViewBuilder
    var rootView: some View {
        switch navigationService.currentRoot {
        case .cardState:
            CardStateView()
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: AppRoute) -> some View {
        switch route {
        case .activation:
            CardActivationView()
        case .scratchCard:
            CardScratchView()
        }
    }
}
