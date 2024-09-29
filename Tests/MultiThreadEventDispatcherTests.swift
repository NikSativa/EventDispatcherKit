import Foundation
import SpryKit
import Threading
import XCTest

@testable import EventDispatcherKit

final class MultiThreadEventDispatcherTests: XCTestCase {
    private let processor1: FakeMultiThreadEventProcessor = .init(name: "common")
    private let processor2: FakeMultiThreadEventProcessor = .init(name: "technical", isTechnical: true)

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

        wait(for: expects, timeout: 15)

        let mainEvents: [FakeMultiThreadEventProcessor.Event] = (0...numberOfEvents).map { i in
            return .init(name: NameKind.simple.rawValue, properties: ["key": "\(i) + main"])
        }
        let backgroundEvents: [FakeMultiThreadEventProcessor.Event] = (0...numberOfEvents).map { i in
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

private extension FakeMultiThreadEventProcessor.Event {
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

#if swift(>=6.0)
extension MultiThreadEventDispatcherTests: @unchecked Sendable {}
#endif
