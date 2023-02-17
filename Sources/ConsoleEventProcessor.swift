import Foundation

public final class ConsoleEventProcessor {
    public typealias Logger = (Any...) -> Void

    private let logger: Logger
    private let prettyPrinted: Bool

    public init(logger: Logger? = nil,
                prettyPrinted: Bool = true) {
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

    public var isTechnical: Bool {
        return true
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
}

private extension Dictionary {
    func prettyJsonString() -> String? {
        if JSONSerialization.isValidJSONObject(self) {
            let data: Data? = try? JSONSerialization.data(withJSONObject: self, options: [.sortedKeys, .prettyPrinted])
            if let data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
}
