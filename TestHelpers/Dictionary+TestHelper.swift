import EventDispatcherKit
import Foundation

public extension Dictionary {
    static func ==(lhs: Dictionary, rhs: Dictionary) -> Bool {
        let lJson: Data? = JSONSerialization.data(from: lhs)
        let rJson: Data? = JSONSerialization.data(from: rhs)
        return lJson == rJson && lJson != nil
    }

    static func !=(lhs: Dictionary, rhs: Dictionary) -> Bool {
        return !(lhs == rhs)
    }
}

private extension JSONSerialization {
    static func data(from object: Any) -> Data? {
        guard JSONSerialization.isValidJSONObject(object) else {
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .prettyPrinted])
    }
}
