import Foundation

#if swift(>=6.0)
public protocol Event: Encodable, Sendable, CustomDebugStringConvertible {
    static var name: EventName { get }
    var encoder: JSONEncoder { get }
}
#else
public protocol Event: Encodable, CustomDebugStringConvertible {
    static var name: EventName { get }
    var encoder: JSONEncoder { get }
}
#endif

public extension Event {
    var encoder: JSONEncoder {
        return .init()
    }
}

// MARK: - CustomStringConvertible

public extension Event {
    var description: String {
        return Self.name.description
    }
}

// MARK: - CustomDebugStringConvertible

public extension Event {
    var debugDescription: String {
        return Self.name.debugDescription
    }
}
