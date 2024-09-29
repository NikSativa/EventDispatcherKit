import Foundation

public final class ConsoleEventProcessor {
    public typealias Logger = (Any...) -> Void

    public private(set) var isEnabled: Bool = true
    public var isTechnical: Bool

    private let logger: Logger
    private let prettyPrinted: Bool

    public init(logger: Logger? = nil,
                prettyPrinted: Bool = true,
                isTechnical: Bool) {
        self.isTechnical = isTechnical
        self.prettyPrinted = prettyPrinted
        self.logger = logger ?? {
            debugPrint($0)
        }
    }
}

// MARK: - EventProcessor

extension ConsoleEventProcessor: EventProcessor {
    public var name: EventProcessorName {
        return .console
    }

    public func send(_ name: EventName, properties: Properties) {
        if prettyPrinted, let str = properties.prettyJsonString() {
            logger(name, str)
        } else {
            logger(name, properties)
        }
    }

    public func set(userId: String?) {
        logger(userId ?? "nil")
    }

    public func set(enabled: Bool) {
        isEnabled = enabled
    }
}

private extension Dictionary {
    func prettyJsonString() -> String? {
        if JSONSerialization.isValidJSONObject(self) {
            let data: Data? = try? JSONSerialization.data(withJSONObject: self, options: [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes])
            if let data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
}

#if swift(>=6.0)
extension ConsoleEventProcessor: @unchecked Sendable {}
#endif
