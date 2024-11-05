import EventDispatcherKit
import SpryKit
import Threading

final class FakeMultiThreadEventProcessor: EventProcessor {
    struct Event: Hashable, SpryEquatable {
        let name: EventName
        let properties: [String: String]
    }

    @Atomic(mutex: AnyMutex.pthread(.recursive), read: .async, write: .sync)
    private(set) var events: [Event] = []
    let name: EventProcessorName
    let isTechnical: Bool
    let isEnabled: Bool

    init(name: String,
         isTechnical: Bool = false,
         isEnabled: Bool = true) {
        self.name = .init(name: name)
        self.isTechnical = isTechnical
        self.isEnabled = isEnabled
    }

    func send(_ name: EventName, properties: Properties) {
        $events.mutate { events in
            let event: Event = .init(name: name, properties: properties as! [String: String])
            events.append(event)
        }
    }

    func set(userId _: String?) {
        fatalError("nothing to test")
    }

    func set(enabled: Bool) {
        fatalError("nothing to test")
    }
}

#if swift(>=6.0)
extension FakeMultiThreadEventProcessor: @unchecked Sendable {}
extension FakeMultiThreadEventProcessor.Event: Sendable {}
#endif
