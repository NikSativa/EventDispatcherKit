import Foundation
import EventDispatcherKit
import SpryKit

public final class FakeEventDispatcher: EventDispatching, Spryable {
    public enum ClassFunction: String, StringRepresentable {
        case empty
    }

    public enum Function: String, StringRepresentable {
        case isEnabled
        case setIsEnabled = "set(enabled:)"
        case setIsEnabledWithName = "set(enabled:for:)"

        case sendNamed = "send(_:body:)"
        case send = "send(_:)"
        case setUserId = "set(userId:)"
    }

    public func set(userId: String?) {
        return spryify(arguments: userId)
    }

    public var isEnabled: Bool {
        return spryify()
    }

    public func set(enabled: Bool) {
        return spryify(arguments: enabled)
    }

    public func set(enabled: Bool, for name: EventProcessorName) {
        return spryify(arguments: enabled, name)
    }

    public func send(_ name: EventName, body: some Encodable) {
        return spryify(arguments: name, body)
    }

    public func send(_ event: some Event) {
        return spryify(arguments: event)
    }

    public func send(_ event: some CustomizableEvent) {
        return spryify(arguments: event)
    }

    public func send(_ event: some TechnicalEvent) {
        return spryify(arguments: event)
    }
}
