import Foundation

public struct PaymentConfiguration: Sendable {
    public enum Environment: Sendable {
        case sandbox
        case production
    }

    public let environment: Environment
    public let merchantId: String
    public let timeoutInterval: TimeInterval
    public let maxRetryCount: Int

    public init(
        environment: Environment = .sandbox,
        merchantId: String = "",
        timeoutInterval: TimeInterval = 30,
        maxRetryCount: Int = 2
    ) {
        self.environment = environment
        self.merchantId = merchantId
        self.timeoutInterval = timeoutInterval
        self.maxRetryCount = maxRetryCount
    }
}
