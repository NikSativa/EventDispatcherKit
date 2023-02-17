import Foundation

public protocol Event: Encodable, CustomStringConvertible, CustomDebugStringConvertible {
    static var name: EventName { get }
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
