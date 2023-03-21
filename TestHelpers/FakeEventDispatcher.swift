import Foundation
import NEventDispatcher
import NSpry

public final class FakeEventDispatcher: EventDispatching, Spryable {
    public enum ClassFunction: String, StringRepresentable {
        case empty
    }

    public enum Function: String, StringRepresentable {
        case sendNamed = "send(_:body:)"
        case send = "send(_:)"
        case setUserId = "set(userId:)"
    }

    public func set(userId: String?) {
        return spryify(arguments: userId)
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
