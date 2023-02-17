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

    public func send<B: Encodable>(_ name: EventName, body: B) {
        return spryify(arguments: name, body)
    }

    public func send<M: Event>(_ event: M) {
        return spryify(arguments: event)
    }

    public func send<M: CustomizableEvent>(_ event: M) {
        return spryify(arguments: event)
    }

    public func send<M: TechnicalEvent>(_ event: M) {
        return spryify(arguments: event)
    }
}
