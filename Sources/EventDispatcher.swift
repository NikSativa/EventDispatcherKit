import Foundation
import NQueue

public final class EventDispatcher {
    /// json root key when serialized properties are not eqvivalent of EventProcessor.Properties
    /// the result will look like **[rootKey: EventProcessor.Properties]**
    public static var rootKey: String = "body"

    private static let defaultQueue: Queueable = Queue.custom(label: "NEventDispatcher",
                                                              qos: .background,
                                                              attributes: .serial)
    private let processors: [EventProcessor]
    private let queue: Queueable

    public init(processors: [EventProcessor],
                queue: Queueable? = nil) {
        self.queue = queue ?? Self.defaultQueue
        self.processors = processors

        assert(processors.isEmpty || processors.contains(where: \.isTechnical))
    }

    private func make(with body: some Encodable) throws -> EventProcessor.Properties {
        let data = try JSONEncoder().encode(body)
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

    public func send(_ name: EventName, body: some Encodable) {
        queue.async { [self] in
            do {
                let props = try make(with: body)
                for processor in processors {
                    processor.send(name, properties: props)
                }
            } catch {
                assertionFailure("can't serialize \(error.localizedDescription)\nname: \(name)\nbody: \(String(describing: body))")
            }
        }
    }

    public func send<Event: TechnicalEvent>(_ event: Event) {
        queue.async { [self] in
            do {
                let props = try make(with: event)
                let processors = processors.filter(\.isTechnical)
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
            do {
                for processor in processors {
                    if let event = event.customized(for: processor.name) {
                        let props = try make(with: event.body)
                        processor.send(event.name, properties: props)
                    }
                }
            } catch {
                assertionFailure("can't serialize \(error.localizedDescription)\nbody: \(String(describing: event))")
            }
        }
    }
}
