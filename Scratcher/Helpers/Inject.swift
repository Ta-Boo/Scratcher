//Created by Tobiáš Hládek on 10/11/2025.
// 


import Swinject

@propertyWrapper
public struct Inject<Value> {
    public private(set) var wrappedValue: Value

    public init() {
        self.init(name: nil, resolver: nil)
    }

    public init(name: String? = nil, resolver: Resolver? = nil) {
        guard let resolver = resolver ?? InjectSettings.resolver else {
            fatalError("Make sure InjectSettings.resolver is set!")
        }

        guard let value = resolver.resolve(Value.self, name: name) else {
            fatalError("Could not resolve non-optional \(Value.self)")
        }

        wrappedValue = value
    }

    public init<Wrapped>(name: String? = nil, resolver: Resolver? = nil) where Value == Wrapped? {
        guard let resolver = resolver ?? InjectSettings.resolver else {
            fatalError("Make sure InjectSettings.resolver is set!")
        }

        wrappedValue = resolver.resolve(Wrapped.self, name: name)
    }
}

public struct InjectSettings {
    public static var resolver: Resolver?
}

public protocol Resolver {
    func resolve<T>(_ type: T.Type, name: String?) -> T?
}

struct FatalErrorUtil {
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
    static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure

    static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        fatalErrorClosure = closure
    }

    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}

func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
}

extension Container: Resolver {
}
