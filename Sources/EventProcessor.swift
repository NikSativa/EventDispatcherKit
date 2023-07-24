import Foundation

public protocol EventProcessor {
    var name: EventProcessorName { get }
    var isTechnical: Bool { get }
    var isEnabled: Bool { get }

    typealias Properties = [String: Any]
    func send(_ name: EventName, properties: Properties)

    func set(userId: String?)
    func set(enabled: Bool)
}

public extension EventProcessor {
    var isTechnical: Bool {
        return false
    }
}
