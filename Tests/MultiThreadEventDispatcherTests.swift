import Foundation
import SpryKit
import Threading
import XCTest

@testable import EventDispatcherKit
@testable import EventDispatcherKitTestHelpers
@testable import ThreadingTestHelpers

final class MultiThreadEventDispatcherTests: XCTestCase {
    private let processor1: FakeEventProcessor = .init(name: "common")
    private let processor2: FakeEventProcessor = .init(name: "technical", isTechnical: true)

    private lazy var subject: EventDispatching = {
        return EventDispatcher(processors: [processor1, processor2])
    }()

    func test_simple_event() {
        let event = Event.testMake(.one)
        subject.send(event)

        wait()
        XCTAssertEqual(processor1.events, [.testMake(name: .simple, variant: .one)])
        XCTAssertEqual(processor2.events, [.testMake(name: .simple, variant: .one)])
    }

    func test_tech_event() {
        let event = TechnicalEvent.testMake(.one)
        subject.send(event)

        wait()
        XCTAssertEqual(processor1.events, [])
        XCTAssertEqual(processor2.events, [.testMake(name: .technical, variant: .one)])
    }

    func test_multi_event() {
        let numberOfEvents = 1000

        var expects: [XCTestExpectation] = []
        for i in 0...numberOfEvents {
            let exp = expectation(description: "Event background \(i)")
            expects.append(exp)

            Queue.background.asyncAfter(deadline: .now() + 0.1) {
                let event = Event(key: "\(i) + background")
                self.subject.send(event)
                exp.fulfill()
            }
        }

        for i in 0...numberOfEvents {
            let exp = expectation(description: "Event background \(i)")
            expects.append(exp)

            Queue.main.asyncAfter(deadline: .now() + 0.1) {
                let event = Event(key: "\(i) + main")
                self.subject.send(event)
                exp.fulfill()
            }
        }

        wait(for: expects, timeout: 5)

        let mainEvents: [FakeEventProcessor.Event] = (0...numberOfEvents).map { i in
            return .init(name: NameKind.simple.rawValue, properties: ["key": "\(i) + main"])
        }
        let backgroundEvents: [FakeEventProcessor.Event] = (0...numberOfEvents).map { i in
            return .init(name: NameKind.simple.rawValue, properties: ["key": "\(i) + background"])
        }

        let events = Set(mainEvents + backgroundEvents)
        XCTAssertEqual(processor1.events.count, mainEvents.count + backgroundEvents.count)
        XCTAssertEqual(events.count, mainEvents.count + backgroundEvents.count)

        XCTAssertEqual(Set(processor1.events), events)
        XCTAssertEqual(Set(processor2.events), events)
    }
}

private extension MultiThreadEventDispatcherTests {
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

    struct Event: EventDispatcherKit.Event, Hashable, SpryEquatable {
        static let name: EventName = NameKind.simple.rawValue
        let key: String
    }

    struct TechnicalEvent: EventDispatcherKit.TechnicalEvent, SpryEquatable {
        static let name: EventName = NameKind.technical.rawValue
        let key: String
    }

    func wait(timeout: TimeInterval = 1) {
        let exp = expectation(description: "wait")
        exp.isInverted = true
        wait(for: [exp], timeout: timeout)
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

private extension FakeEventProcessor.Event {
    static func testMake(name: MultiThreadEventDispatcherTests.NameKind = .simple,
                         variant: MultiThreadEventDispatcherTests.Variant = .one) -> Self {
        return .init(name: name.rawValue,
                     properties: ["key": variant.rawValue])
    }
}

private extension MultiThreadEventDispatcherTests.Event {
    static func testMake(_ variant: MultiThreadEventDispatcherTests.Variant = .one) -> Self {
        return .init(key: variant.rawValue)
    }
}

private extension MultiThreadEventDispatcherTests.TechnicalEvent {
    static func testMake(_ variant: MultiThreadEventDispatcherTests.Variant = .one) -> Self {
        return .init(key: variant.rawValue)
    }
}
