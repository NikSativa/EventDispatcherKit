import Foundation
import Nimble
import NQueue
import NSpry
import NSpry_Nimble
import Quick

@testable import NEventDispatcher
@testable import NEventDispatcherTestHelpers
@testable import NQueueTestHelpers

final class MutiThreadEventDispatcherSpec: QuickSpec {
    override func spec() {
        describe("MutiThreadEventDispatcher") {
            var subject: EventDispatching!
            var processor1: FakeEventProcessor!
            var processor2: FakeEventProcessor!

            beforeEach {
                processor1 = .init(name: "common")
                processor2 = .init(name: "technical", isTechnical: true)
                subject = EventDispatcher(processors: [processor1, processor2])
            }

            describe("simple event") {
                beforeEach {
                    let event = Event.testMake(.one)
                    subject.send(event)
                }

                it("should send to engine") {
                    await expect(processor1.events).toEventually(equal([.testMake(name: .simple, variant: .one)]))
                    await expect(processor2.events).toEventually(equal([.testMake(name: .simple, variant: .one)]))
                }
            }

            describe("tech event") {
                beforeEach {
                    let event = TechnicalEvent.testMake(.one)
                    subject.send(event)
                }

                it("should send to engine") {
                    await expect(processor1.events).toEventually(beEmpty())
                    await expect(processor2.events).toEventually(equal([.testMake(name: .technical, variant: .one)]))
                }
            }

            describe("multi events") {
                let numberOfEvents = 1000

                beforeEach {
                    Queue.background.asyncAfter(deadline: .now() + 0.1) {
                        for i in 0...numberOfEvents {
                            let event = Event(key: "\(i) + background")
                            subject.send(event)
                        }
                    }

                    Queue.main.asyncAfter(deadline: .now() + 0.1) {
                        for i in 0...numberOfEvents {
                            let event = Event(key: "\(i) + main")
                            subject.send(event)
                        }
                    }
                }

                it("should send to engine") {
                    let mainEvents: [FakeEventProcessor.Event] = (0...numberOfEvents).map { i in
                        return .init(name: NameKind.simple.rawValue, properties: ["key": "\(i) + main"])
                    }
                    let backgroundEvents: [FakeEventProcessor.Event] = (0...numberOfEvents).map { i in
                        return .init(name: NameKind.simple.rawValue, properties: ["key": "\(i) + background"])
                    }
                    let events = Set(mainEvents + backgroundEvents)

                    await expect(processor1.events.count).toEventually(equal(mainEvents.count + backgroundEvents.count))
                    expect(processor1.events.count) == events.count

                    expect(Set(processor1.events)) == events
                    expect(Set(processor2.events)) == events

                    // print(processor1.events.compactMap(\.properties["key"]))
                }
            }
        }
    }
}

private extension MutiThreadEventDispatcherSpec {
    enum NameKind: EventName {
        case simple = "simple event name"
        case technical = "technical event name"
    }

    enum Variant: String {
        case one
        case two
        case three
        case four
    }

    struct Event: NEventDispatcher.Event, Hashable, SpryEquatable {
        static let name: EventName = NameKind.simple.rawValue
        let key: String
    }

    struct TechnicalEvent: NEventDispatcher.TechnicalEvent, SpryEquatable {
        static let name: EventName = NameKind.technical.rawValue
        let key: String
    }
}

private final class FakeEventProcessor: EventProcessor {
    struct Event: Hashable, SpryEquatable {
        let name: EventName
        let properties: [String: String]
    }

    @Atomic(mutex: Mutex.pthread(.recursive), read: .async, write: .sync)
    private(set) var events: [Event] = []
    let name: EventProcessorName
    let isTechnical: Bool

    init(name: String,
         isTechnical: Bool = false) {
        self.name = .init(name: name)
        self.isTechnical = isTechnical
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
}

private extension FakeEventProcessor.Event {
    static func testMake(name: MutiThreadEventDispatcherSpec.NameKind = .simple,
                         variant: MutiThreadEventDispatcherSpec.Variant = .one) -> Self {
        return .init(name: name.rawValue,
                     properties: ["key": variant.rawValue])
    }
}

private extension MutiThreadEventDispatcherSpec.Event {
    static func testMake(_ variant: MutiThreadEventDispatcherSpec.Variant = .one) -> Self {
        return .init(key: variant.rawValue)
    }
}

private extension MutiThreadEventDispatcherSpec.TechnicalEvent {
    static func testMake(_ variant: MutiThreadEventDispatcherSpec.Variant = .one) -> Self {
        return .init(key: variant.rawValue)
    }
}
