import Foundation

public protocol EventDispatching {
    func set(userId: String?)

    func send<B: Encodable>(_ name: EventName, body: B)
    func send<E: Event>(_ event: E)
    func send<E: TechnicalEvent>(_ event: E)
    func send<E: CustomizableEvent>(_ event: E)
}

public extension EventDispatching {
    func send<E: Event>(_ event: E) {
        send(E.name, body: event)
    }
}
