import Foundation

#if swift(>=6.0)
public protocol CustomizableEvent: Sendable {
    func customized(for name: EventProcessorName) -> CustomizedEvent?
}
#else
public protocol CustomizableEvent {
    func customized(for name: EventProcessorName) -> CustomizedEvent?
}
#endif

public struct CustomizedEvent {
    #if swift(>=6.0)
    public typealias Body = Encodable & Sendable
    #else
    public typealias Body = Encodable
    #endif

    public let name: EventName
    public let body: any Body
    public let encoder: JSONEncoder

    public init(name: EventName,
                body: some Body,
                encoder: JSONEncoder = .init()) {
        self.name = name
        self.body = body
        self.encoder = encoder
    }

    public init(name: String,
                body: some Body,
                encoder: JSONEncoder = .init()) {
        self.name = .init(value: name)
        self.body = body
        self.encoder = encoder
    }
}

#if swift(>=6.0)
extension CustomizedEvent: Sendable {}
#endif
