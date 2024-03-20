import Foundation
import NQueue
import NSpry
import XCTest

@testable import NEventDispatcher
@testable import NEventDispatcherTestHelpers
@testable import NQueueTestHelpers

private extension EventProcessorName {
    static let one: Self = .init(name: "one")
    static let two: Self = .init(name: "two")
    static let three: Self = .init(name: "three")
}

final class EventDispatcherTests: XCTestCase {
    private let regularEventProcessor: FakeEventProcessor = .init()
    private let technicalEventProcessor: FakeEventProcessor = .init()
    private let regular2EventProcessor: FakeEventProcessor = .init()
    private lazy var queue: FakeQueueable = .init()
    private lazy var subject: EventDispatching = {
        let subject: EventDispatching = EventDispatcher(processors: [
            regularEventProcessor,
            technicalEventProcessor,
            regular2EventProcessor
        ],
        queue: queue)
        return subject
    }()

    override func setUp() {
        super.setUp()

        regularEventProcessor.stub(.name).andReturn(EventProcessorName.one)
        regularEventProcessor.stub(.isTechnical).andReturn(false)
        regularEventProcessor.stub(.isEnabled).andReturn(true)

        technicalEventProcessor.stub(.name).andReturn(EventProcessorName.two)
        technicalEventProcessor.stub(.isTechnical).andReturn(true)
        technicalEventProcessor.stub(.isEnabled).andReturn(true)

        regular2EventProcessor.stub(.name).andReturn(EventProcessorName.three)
        regular2EventProcessor.stub(.isTechnical).andReturn(false)
        regular2EventProcessor.stub(.isEnabled).andReturn(true)

        queue.stub(.async).andDo { args in
            typealias VoidClosure = () -> Void
            if let closure = args[0] as? VoidClosure {
                closure()
            }
            return ()
        }
    }

    #if (os(macOS) || os(iOS) || os(visionOS)) && (arch(x86_64) || arch(arm64))
    func test_no_technical_processors() {
        XCTAssertThrowsAssertion {
            _ = EventDispatcher(processors: [self.regularEventProcessor])
        }
    }
    #endif

    func test_no_processors() {
        _ = EventDispatcher(processors: [])
    }

    func test_minimum_one_technical_processor() {
        regularEventProcessor.stub(.setUserId).andReturn()
        regular2EventProcessor.stub(.setUserId).andReturn()
        technicalEventProcessor.stub(.setUserId).andReturn()

        subject.set(userId: "user id")

        XCTAssertHaveReceived(regularEventProcessor, .setUserId, with: "user id")
        XCTAssertHaveReceived(regular2EventProcessor, .setUserId, with: "user id")
        XCTAssertHaveReceived(technicalEventProcessor, .setUserId, with: "user id")
    }

    func test_when_send_empty_event() {
        regularEventProcessor.stub(.send).andReturn()
        regular2EventProcessor.stub(.send).andReturn()
        technicalEventProcessor.stub(.send).andReturn()

        let event = EmptyEvent()
        subject.send(event)

        let eventName: EventName = "empty"
        let properties = Self.testMake()
        XCTAssertHaveReceived(regularEventProcessor, .send, with: eventName, properties)
        XCTAssertHaveReceived(regular2EventProcessor, .send, with: eventName, properties)
        XCTAssertHaveReceived(technicalEventProcessor, .send, with: eventName, properties)
    }

    func test_when_send_simple_event() {
        regularEventProcessor.stub(.send).andReturn()
        regular2EventProcessor.stub(.send).andReturn()
        technicalEventProcessor.stub(.send).andReturn()

        let event = Event(map: ["value": "1"])
        subject.send(event)

        let eventName: EventName = "simple"
        let properties = Self.testMake("1")
        XCTAssertHaveReceived(regularEventProcessor, .send, with: eventName, properties)
        XCTAssertHaveReceived(regular2EventProcessor, .send, with: eventName, properties)
        XCTAssertHaveReceived(technicalEventProcessor, .send, with: eventName, properties)
    }

    func test_when_send_empty_customizable_event() {
        regularEventProcessor.stub(.send).andReturn()
        regular2EventProcessor.stub(.send).andReturn()
        technicalEventProcessor.stub(.send).andReturn()

        let event = EmptyCustomizableEvent()
        subject.send(event)

        let eventName: EventName = "empty customizable"
        let properties = Self.testMake()
        XCTAssertHaveReceived(regularEventProcessor, .send, with: eventName, properties)
        XCTAssertHaveReceived(regular2EventProcessor, .send, with: eventName, properties)
        XCTAssertHaveReceived(technicalEventProcessor, .send, with: eventName, properties)
    }

    func test_when_send_customizable_event() {
        regularEventProcessor.stub(.send).andReturn()
        regular2EventProcessor.stub(.send).andReturn()
        technicalEventProcessor.stub(.send).andReturn()

        let event = CustomizableEvent(map: ["value": "2"])
        subject.send(event)

        let eventName: EventName = "customizable"
        let properties = Self.testMake(["value": "2", "1": "a"])
        let properties2 = Self.testMake(["value": "2", "2": "b"])
        XCTAssertHaveReceived(regularEventProcessor, .send, with: eventName, properties)
        XCTAssertHaveNotReceived(regular2EventProcessor, .send)
        XCTAssertHaveReceived(technicalEventProcessor, .send, with: eventName, properties2)
    }

    func test_when_send_technical_event() {
        regularEventProcessor.stub(.send).andReturn()
        regular2EventProcessor.stub(.send).andReturn()
        technicalEventProcessor.stub(.send).andReturn()

        let event = TechnicalEvent(map: ["value": "3"])
        subject.send(event)

        let eventName: EventName = "technical"
        let properties = Self.testMake("3")
        XCTAssertHaveNotReceived(regularEventProcessor, .send)
        XCTAssertHaveNotReceived(regular2EventProcessor, .send)
        XCTAssertHaveReceived(technicalEventProcessor, .send, with: eventName, properties)
    }
}

private extension EventDispatcherTests {
    struct EmptyEvent: NEventDispatcher.Event, SpryEquatable {
        static var name: EventName {
            return "empty"
        }
    }

    struct Event: NEventDispatcher.Event, SpryEquatable {
        static var name: EventName {
            return "simple"
        }

        let map: [String: String]
    }

    struct TechnicalEvent: NEventDispatcher.TechnicalEvent, SpryEquatable {
        static var name: EventName {
            return "technical"
        }

        let map: [String: String]
    }

    struct EmptyCustomizableEvent: NEventDispatcher.CustomizableEvent, SpryEquatable, Encodable {
        func customized(for name: EventProcessorName) -> CustomizedEvent? {
            return .init(name: "empty customizable", body: self)
        }
    }

    struct CustomizableEvent: NEventDispatcher.CustomizableEvent, SpryEquatable {
        private struct Customizable: Encodable, SpryEquatable {
            let map: [String: String]
        }

        let map: [String: String]

        func customized(for name: EventProcessorName) -> CustomizedEvent? {
            let new: [String: String]
            switch name {
            case .one:
                new = ["1": "a"]
            case .two:
                new = ["2": "b"]
            case .three:
                return nil
            default:
                new = ["3": "c"]
            }

            let merged = map.merging(new) { _, new in
                return new
            }
            let customizable = Customizable(map: merged)
            return .init(name: "customizable",
                         body: customizable)
        }
    }

    static func testMake(_ map: [String: String]) -> [String: [String: String]] {
        return ["map": map]
    }

    static func testMake(_ value: String) -> [String: [String: String]] {
        return testMake(["value": value])
    }

    static func testMake() -> [String: String] {
        return [:]
    }
}
