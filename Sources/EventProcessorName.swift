import Foundation

public struct EventProcessorName: Equatable {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    public static func generate(for type: (some Any).Type) -> EventProcessorName {
        return .init(name: String(reflecting: type))
    }
}

// MARK: - names

public extension EventProcessorName {
    static let console: EventProcessorName = .generate(for: ConsoleEventProcessor.self)
}

// MARK: - Codable

extension EventProcessorName: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.name = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

// MARK: - RawRepresentable

public extension EventProcessorName {
    init<R: RawRepresentable>(_ name: R)
        where R.RawValue == String {
        self.name = name.rawValue
    }
}

// MARK: - ExpressibleByStringInterpolation

extension EventProcessorName: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self.name = value
    }
}

// MARK: - CustomStringConvertible

extension EventProcessorName: CustomStringConvertible {
    public var description: String {
        return name
    }
}

// MARK: - CustomDebugStringConvertible

extension EventProcessorName: CustomDebugStringConvertible {
    public var debugDescription: String {
        return name
    }
}

#if swift(>=6.0)
extension EventProcessorName: Sendable {}
#endif
