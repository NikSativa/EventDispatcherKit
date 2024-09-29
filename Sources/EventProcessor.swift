import Foundation

#if swift(>=6.0)
public protocol EventProcessor: Sendable {
    var name: EventProcessorName { get }
    var isTechnical: Bool { get }
    var isEnabled: Bool { get }

    typealias Properties = [String: Any]
    func send(_ name: EventName, properties: Properties)

    func set(userId: String?)
    func set(enabled: Bool)
}
#else
public protocol EventProcessor {
    var name: EventProcessorName { get }
    var isTechnical: Bool { get }
    var isEnabled: Bool { get }

    typealias Properties = [String: Any]
    func send(_ name: EventName, properties: Properties)

    func set(userId: String?)
    func set(enabled: Bool)
}
#endif

public extension EventProcessor {
    var isTechnical: Bool {
        return false
    }
}
