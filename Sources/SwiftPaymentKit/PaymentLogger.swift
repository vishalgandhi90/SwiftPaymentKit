import Foundation

public enum PaymentLogLevel: Int, Sendable, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3

    public static func < (lhs: PaymentLogLevel, rhs: PaymentLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public protocol PaymentLogger: Sendable {
    func log(_ message: String, level: PaymentLogLevel)
}

public final class ConsolePaymentLogger: PaymentLogger, @unchecked Sendable {
    private let minimumLevel: PaymentLogLevel

    public init(minimumLevel: PaymentLogLevel = .debug) {
        self.minimumLevel = minimumLevel
    }

    public func log(_ message: String, level: PaymentLogLevel) {
        guard level >= minimumLevel else { return }
        let prefix: String
        switch level {
        case .debug:   prefix = "[DEBUG]"
        case .info:    prefix = "[INFO]"
        case .warning: prefix = "[WARN]"
        case .error:   prefix = "[ERROR]"
        }
        print("[SwiftPaymentKit] \(prefix) \(message)")
    }
}
