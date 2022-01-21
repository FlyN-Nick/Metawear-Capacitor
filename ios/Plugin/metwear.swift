import Foundation

@objc public class metwear: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
