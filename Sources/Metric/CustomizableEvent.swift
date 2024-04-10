import Foundation

public protocol CustomizableEvent {
    func customized(for name: EventProcessorName) -> CustomizedEvent?
}

public struct CustomizedEvent {
    public let name: EventName
    public let body: any Encodable
    public let encoder: JSONEncoder

    public init(name: EventName,
                body: some Encodable,
                encoder: JSONEncoder = .init()) {
        self.name = name
        self.body = body
        self.encoder = encoder
    }

    public init(name: String,
                body: some Encodable,
                encoder: JSONEncoder = .init()) {
        self.name = .init(value: name)
        self.body = body
        self.encoder = encoder
    }
}
