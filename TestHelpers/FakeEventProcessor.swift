import Foundation
import EventDispatcherKit
import SpryKit

public final class FakeEventProcessor: EventProcessor, Spryable {
    public enum ClassFunction: String, StringRepresentable {
        case empty
    }

    public enum Function: String, StringRepresentable {
        case name
        case isEnabled
        case isTechnical
        case send = "send(_:properties:)"
        case setUserId = "set(userId:)"
        case setIsEnabled = "set(enabled:)"
    }

    public func set(userId: String?) {
        return spryify(arguments: userId)
    }

    public func set(enabled: Bool) {
        return spryify(arguments: enabled)
    }

    public var name: EventProcessorName {
        return spryify()
    }

    public var isTechnical: Bool {
        return spryify()
    }

    public var isEnabled: Bool {
        return spryify()
    }

    public func send(_ name: EventName, properties: Properties) {
        return spryify(arguments: name, properties)
    }
}
