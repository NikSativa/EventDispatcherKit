import Foundation
import Threading

public final class EventDispatcher {
    // json root key when serialized properties are not eqvivalent of EventProcessor.Properties
    // the result will look like **[rootKey: EventProcessor.Properties]**
    #if swift(>=6.0)
    public nonisolated(unsafe) static var rootKey: String = "body"
    #else
    public static var rootKey: String = "body"
    #endif

    private static let defaultQueue: Queueable = Queue.custom(label: "EventDispatcherKit",
                                                              qos: .background,
                                                              attributes: .serial)
    public private(set) var isEnabled: Bool = true
    private let processors: [EventProcessor]
    private let queue: Queueable

    public init(processors: [EventProcessor],
                queue: Queueable? = nil) {
        self.queue = queue ?? Self.defaultQueue
        self.processors = processors

        assert(processors.isEmpty || processors.contains(where: \.isTechnical))
    }

    private func make(with body: some Encodable, encoder: JSONEncoder) throws -> EventProcessor.Properties {
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let value = json as? EventProcessor.Properties {
            return value
        } else {
            return [Self.rootKey: json]
        }
    }
}

// MARK: - EventDispatching

extension EventDispatcher: EventDispatching {
    public func set(userId: String?) {
        queue.async {
            for processor in self.processors {
                processor.set(userId: userId)
            }
        }
    }

    public func set(enabled: Bool) {
        queue.async {
            self.isEnabled = enabled
        }
    }

    public func set(enabled: Bool, for name: EventProcessorName) {
        queue.async {
            for processor in self.processors {
                if processor.name == name {
                    processor.set(enabled: enabled)
                }
            }
        }
    }

    #if swift(>=6.0)
    public func send(_ name: EventName, body: some Encodable & Sendable, encoder: JSONEncoder) {
        queue.async { [self] in
            guard isEnabled else {
                return
            }

            do {
                let props = try make(with: body, encoder: encoder)
                let processors = processors.filter(\.isEnabled)
                for processor in processors {
                    processor.send(name, properties: props)
                }
            } catch {
                assertionFailure("can't serialize \(error.localizedDescription)\nname: \(name)\nbody: \(String(describing: body))")
            }
        }
    }
    #else
    public func send(_ name: EventName, body: some Encodable, encoder: JSONEncoder) {
        queue.async { [self] in
            guard isEnabled else {
                return
            }

            do {
                let props = try make(with: body, encoder: encoder)
                let processors = processors.filter(\.isEnabled)
                for processor in processors {
                    processor.send(name, properties: props)
                }
            } catch {
                assertionFailure("can't serialize \(error.localizedDescription)\nname: \(name)\nbody: \(String(describing: body))")
            }
        }
    }
    #endif

    public func send<Event: TechnicalEvent>(_ event: Event) {
        queue.async { [self] in
            guard isEnabled else {
                return
            }

            do {
                let props = try make(with: event, encoder: event.encoder)
                let processors = processors.filter(\.isTechnicalEnabled)
                for processor in processors {
                    processor.send(Event.name, properties: props)
                }
            } catch {
                assertionFailure("can't serialize \(error.localizedDescription)\nbody: \(String(describing: event))")
            }
        }
    }

    public func send(_ event: some CustomizableEvent) {
        queue.async { [self] in
            guard isEnabled else {
                return
            }

            do {
                let processors = processors.filter(\.isEnabled)
                for processor in processors {
                    if let event = event.customized(for: processor.name) {
                        let props = try make(with: event.body, encoder: event.encoder)
                        processor.send(event.name, properties: props)
                    }
                }
            } catch {
                assertionFailure("can't serialize \(error.localizedDescription)\nbody: \(String(describing: event))")
            }
        }
    }
}

private extension EventProcessor {
    var isTechnicalEnabled: Bool {
        return isTechnical && isEnabled
    }
}

#if swift(>=6.0)
extension EventDispatcher: @unchecked Sendable {}
#endif
