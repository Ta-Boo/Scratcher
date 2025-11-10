import Foundation

protocol CaseHashable: Hashable {}
extension CaseHashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}
