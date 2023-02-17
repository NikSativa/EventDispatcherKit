import Foundation

public protocol CustomizableEvent {
    func customized(for name: EventProcessorName) -> CustomizedEvent?
}

public struct CustomizedEvent {
    public let name: EventName
    public let body: any Encodable

    public init(name: EventName,
                body: some Encodable) {
        self.name = name
        self.body = body
    }

    public init(name: String,
                body: some Encodable) {
        self.name = .init(value: name)
        self.body = body
    }
}
