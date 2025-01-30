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

    func send(_ name: EventName, body: some Encodable & Sendable, encoder: JSONEncoder)
    func send(_ event: some Event)
    func send(_ event: some TechnicalEvent)
    func send(_ event: some CustomizableEvent)
}

public extension EventDispatching {
    func send<E: Event>(_ event: E) {
        send(E.name, body: event)
    }

    func send(_ name: EventName, body: some Encodable & Sendable) {
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

    func send(_ name: EventName, body: some Encodable, encoder: JSONEncoder)
    func send(_ event: some Event)
    func send(_ event: some TechnicalEvent)
    func send(_ event: some CustomizableEvent)
}

public extension EventDispatching {
    func send<E: Event>(_ event: E) {
        send(E.name, body: event)
    }

    func send(_ name: EventName, body: some Encodable) {
        send(name, body: body, encoder: .init())
    }
}
#endif
