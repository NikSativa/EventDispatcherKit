import Foundation

#if swift(>=6.0)
public protocol EventDispatching: Sendable {
    func set(userId: String?)

    var isEnabled: Bool { get }

    /// enabled/disable dispatcher
    /// - **not affecting processors individually**
    func set(enabled: Bool)

    /// enabled/disable processor **individually** by name
    func set(enabled: Bool, for name: EventProcessorName)

    func send<B: Encodable & Sendable>(_ name: EventName, body: B, encoder: JSONEncoder)
    func send<E: Event>(_ event: E)
    func send<E: TechnicalEvent>(_ event: E)
    func send<E: CustomizableEvent>(_ event: E)
}

public extension EventDispatching {
    func send<E: Event>(_ event: E) {
        send(E.name, body: event)
    }

    func send<B: Encodable & Sendable>(_ name: EventName, body: B) {
        send(name, body: body, encoder: .init())
    }
}
#else
public protocol EventDispatching {
    func set(userId: String?)

    var isEnabled: Bool { get }

    /// enabled/disable dispatcher
    /// - **not affecting processors individually**
    func set(enabled: Bool)

    /// enabled/disable processor **individually** by name
    func set(enabled: Bool, for name: EventProcessorName)

    func send<B: Encodable>(_ name: EventName, body: B, encoder: JSONEncoder)
    func send<E: Event>(_ event: E)
    func send<E: TechnicalEvent>(_ event: E)
    func send<E: CustomizableEvent>(_ event: E)
}

public extension EventDispatching {
    func send<E: Event>(_ event: E) {
        send(E.name, body: event)
    }

    func send<B: Encodable>(_ name: EventName, body: B) {
        send(name, body: body, encoder: .init())
    }
}
#endif
