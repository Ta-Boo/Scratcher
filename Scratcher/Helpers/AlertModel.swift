import SwiftUI

struct AlertModel: Identifiable {
    var id: String { title }
    var title: String
    var description: String
    var primaryAction: AlertAction?
    var secondaryAction: AlertAction?

    var useCustom = false
}


struct AlertAction {
    enum AlertActionType {
        case normal, cancel, destructive
    }
    var title: String
    var role: ButtonRole?
    var action: (() -> Void)?
}
