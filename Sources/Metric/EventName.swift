import Foundation

public struct EventName: Hashable {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}

// MARK: - Codable

extension EventName: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - RawRepresentable

public extension EventName {
    init<R: RawRepresentable>(_ value: R)
        where R.RawValue == String {
        self.value = value.rawValue
    }
}

// MARK: - ExpressibleByStringInterpolation

extension EventName: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self.value = value
    }
}

// MARK: - CustomStringConvertible

extension EventName: CustomStringConvertible {
    public var description: String {
        return value
    }
}

// MARK: - CustomDebugStringConvertible

extension EventName: CustomDebugStringConvertible {
    public var debugDescription: String {
        return value
    }
}

#if swift(>=6.0)
extension EventName: Sendable {}
#endif
