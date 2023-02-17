import Foundation
import NEventDispatcher
import NSpry

public final class FakeEventProcessor: EventProcessor, Spryable {
    public enum ClassFunction: String, StringRepresentable {
        case empty
    }

    public enum Function: String, StringRepresentable {
        case name
        case isTechnical
        case send = "send(_:properties:)"
        case setUserId = "set(userId:)"
    }

    public func set(userId: String?) {
        return spryify(arguments: userId)
    }

    public var name: EventProcessorName {
        return spryify()
    }

    public var isTechnical: Bool {
        return spryify()
    }

    public func send(_ name: EventName, properties: Properties) {
        return spryify(arguments: name, properties)
    }
}
