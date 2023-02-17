import Foundation
import Nimble
import NQueue
import NSpry
import NSpry_Nimble
import Quick

@testable import NEventDispatcher
@testable import NEventDispatcherTestHelpers
@testable import NQueueTestHelpers

private extension EventProcessorName {
    static let one: Self = .init(name: "one")
    static let two: Self = .init(name: "two")
    static let three: Self = .init(name: "three")
}

final class EventDispatcherSpec: QuickSpec {
    override func spec() {
        describe("EventDispatcher") {
            describe("no technical processors") {
                it("should throw assertion") {
                    expect {
                        let processor = FakeEventProcessor()
                        processor.stub(.isTechnical).andReturn(false)
                        _ = EventDispatcher(processors: [processor])
                    }.to(throwAssertion())
                }
            }

            describe("no processors") {
                it("should not throw assertion") {
                    expect {
                        _ = EventDispatcher(processors: [])
                    }.toNot(throwAssertion())
                }
            }

            describe("minimum one technical processor") {
                var subject: EventDispatching!
                var regularEventProcessor: FakeEventProcessor!
                var technicalEventProcessor: FakeEventProcessor!
                var regular2EventProcessor: FakeEventProcessor!
                var queue: FakeQueueable!

                beforeEach {
                    regularEventProcessor = .init()
                    regularEventProcessor.stub(.name).andReturn(EventProcessorName.one)
                    regularEventProcessor.stub(.isTechnical).andReturn(false)
                    regularEventProcessor.stub(.send).andReturn()

                    technicalEventProcessor = .init()
                    technicalEventProcessor.stub(.name).andReturn(EventProcessorName.two)
                    technicalEventProcessor.stub(.isTechnical).andReturn(true)
                    technicalEventProcessor.stub(.send).andReturn()

                    regular2EventProcessor = .init()
                    regular2EventProcessor.stub(.name).andReturn(EventProcessorName.three)
                    regular2EventProcessor.stub(.isTechnical).andReturn(false)
                    regular2EventProcessor.stub(.send).andReturn()

                    queue = .init()
                    queue.stub(.async).andDo { args in
                        typealias VoidClosure = () -> Void
                        if let closure = args[0] as? VoidClosure {
                            closure()
                        }
                        return ()
                    }
                    subject = EventDispatcher(processors: [
                        regularEventProcessor,
                        technicalEventProcessor,
                        regular2EventProcessor
                    ],
                    queue: queue)
                }

                context("when setting user id") {
                    beforeEach {
                        regularEventProcessor.stub(.setUserId).andReturn()
                        regular2EventProcessor.stub(.setUserId).andReturn()
                        technicalEventProcessor.stub(.setUserId).andReturn()
                        subject.set(userId: "user id")
                    }

                    it("should send to every processor") {
                        expect(regularEventProcessor).to(haveReceived(.setUserId, with: "user id"))
                        expect(regular2EventProcessor).to(haveReceived(.setUserId, with: "user id"))
                        expect(technicalEventProcessor).to(haveReceived(.setUserId, with: "user id"))
                    }
                }

                context("when send empty event") {
                    beforeEach {
                        let event = EmptyEvent()
                        subject.send(event)
                    }

                    it("should send to every processor") {
                        expect(regularEventProcessor).to(haveReceived(.send, with: "empty" as EventName, [:]))
                        expect(regular2EventProcessor).to(haveReceived(.send, with: "empty" as EventName, [:]))
                        expect(technicalEventProcessor).to(haveReceived(.send, with: "empty" as EventName, [:]))
                    }
                }

                context("when send simple event") {
                    beforeEach {
                        let event = Event(map: ["value": "1"])
                        subject.send(event)
                    }

                    it("should send to every processor") {
                        expect(regularEventProcessor).to(haveReceived(.send, with: "simple" as EventName, Self.testMake("1")))
                        expect(regular2EventProcessor).to(haveReceived(.send, with: "simple" as EventName, Self.testMake("1")))
                        expect(technicalEventProcessor).to(haveReceived(.send, with: "simple" as EventName, Self.testMake("1")))
                    }
                }

                context("when send empty customizable event") {
                    beforeEach {
                        let event = EmptyCustomizableEvent()
                        subject.send(event)
                    }

                    it("should send to every processor") {
                        expect(regularEventProcessor).to(haveReceived(.send, with: "empty customizable" as EventName, [:]))
                        expect(regular2EventProcessor).to(haveReceived(.send, with: "empty customizable" as EventName, [:]))
                        expect(technicalEventProcessor).to(haveReceived(.send, with: "empty customizable" as EventName, [:]))
                    }
                }

                context("when send customizable event") {
                    beforeEach {
                        let event = CustomizableEvent(map: ["value": "2"])
                        subject.send(event)
                    }

                    it("should send to every processor, exclude named 'three'") {
                        expect(regularEventProcessor).to(haveReceived(.send, with: "customizable" as EventName, Self.testMake(["value": "2", "1": "a"])))
                        expect(regular2EventProcessor).toNot(haveReceived(.send))
                        expect(technicalEventProcessor).to(haveReceived(.send, with: "customizable" as EventName, Self.testMake(["value": "2", "2": "b"])))
                    }
                }

                context("when send customizable event") {
                    beforeEach {
                        let event = CustomizableEvent(map: ["value": "2"])
                        subject.send(event)
                    }

                    it("should send to every processor, exclude named 'three'") {
                        expect(regularEventProcessor).to(haveReceived(.send, with: "customizable" as EventName, Self.testMake(["value": "2", "1": "a"])))
                        expect(regular2EventProcessor).toNot(haveReceived(.send))
                        expect(technicalEventProcessor).to(haveReceived(.send, with: "customizable" as EventName, Self.testMake(["value": "2", "2": "b"])))
                    }
                }

                context("when send technical event") {
                    beforeEach {
                        let event = TechnicalEvent(map: ["value": "3"])
                        subject.send(event)
                    }

                    it("should send to technical processor") {
                        expect(regularEventProcessor).toNot(haveReceived(.send))
                        expect(regular2EventProcessor).toNot(haveReceived(.send))
                        expect(technicalEventProcessor).to(haveReceived(.send, with: "technical" as EventName, Self.testMake("3")))
                    }
                }
            }
        }
    }
}

private extension EventDispatcherSpec {
    private struct EmptyEvent: NEventDispatcher.Event, SpryEquatable {
        static var name: EventName {
            return "empty"
        }
    }

    private struct Event: NEventDispatcher.Event, SpryEquatable {
        static var name: EventName {
            return "simple"
        }

        let map: [String: String]
    }

    private struct TechnicalEvent: NEventDispatcher.TechnicalEvent, SpryEquatable {
        static var name: EventName {
            return "technical"
        }

        let map: [String: String]
    }

    private struct EmptyCustomizableEvent: NEventDispatcher.CustomizableEvent, SpryEquatable, Encodable {
        func customized(for name: EventProcessorName) -> CustomizedEvent? {
            return .init(name: "empty customizable", body: self)
        }
    }

    private struct CustomizableEvent: NEventDispatcher.CustomizableEvent, SpryEquatable {
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
        return Self.testMake(["value": value])
    }
}
