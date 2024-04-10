import EventDispatcherKit
import Foundation
import SpryKit

// MARK: - CustomizedEvent + Equatable, SpryEquatable

extension CustomizedEvent: Equatable, SpryEquatable {
    public static func ==(lhs: CustomizedEvent, rhs: CustomizedEvent) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }

        let lPrettyBody = lhs.prettyBody
        if lPrettyBody == nil {
            return false
        }

        let rPrettyBody = rhs.prettyBody
        return lPrettyBody == rPrettyBody
    }
}

private extension CustomizedEvent {
    var prettyBody: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        if let data = try? encoder.encode(body) {
            let str = String(data: data, encoding: .utf8)
            return str
        }
        return nil
    }
}
