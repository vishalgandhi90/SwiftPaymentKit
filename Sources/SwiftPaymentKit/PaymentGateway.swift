import Foundation

// MARK: - Core Protocol

/// A protocol that all payment gateway implementations must conform to.
public protocol PaymentGateway: Sendable {
    var name: String { get }
    var supportedMethods: [PaymentMethod] { get }

    func initiatePayment(
        amount: Decimal,
        currency: Currency,
        orderId: String,
        metadata: [String: String]
    ) async throws -> PaymentSession

    func processPayment(
        session: PaymentSession
    ) async throws -> PaymentResult

    func verifyPayment(transactionId: String) async throws -> PaymentStatus
    func cancelPayment(transactionId: String) async throws -> PaymentStatus
}

// MARK: - Payment Session

public struct PaymentSession: Sendable {
    public let checkoutId: String
    public let gatewayName: String
    public let metadata: [String: String]

    public init(checkoutId: String, gatewayName: String, metadata: [String: String] = [:]) {
        self.checkoutId = checkoutId
        self.gatewayName = gatewayName
        self.metadata = metadata
    }
}

// MARK: - Payment Result

public enum PaymentResult: Sendable {
    case success(transactionId: String)
    case pending(checkoutId: String)
    case cancelled
    case failed(PaymentError)
}

// MARK: - Payment Status

public enum PaymentStatus: Sendable {
    case completed(transactionId: String)
    case pending
    case failed(reason: String)
    case refunded
    case cancelled
}

// MARK: - Payment Error

public enum PaymentError: Error, Sendable {
    case insufficientFunds
    case cardDeclined
    case networkError(underlying: Error? = nil)
    case providerError(code: String, message: String)
    case userCancelled
    case timeout
    case invalidConfiguration(String)
    case gatewayNotFound(PaymentMethod)

    public var isRetryable: Bool {
        switch self {
        case .networkError, .timeout:
            return true
        case .providerError:
            return true
        default:
            return false
        }
    }

    public var userMessage: String {
        switch self {
        case .insufficientFunds:
            return "Insufficient funds. Please try a different payment method."
        case .cardDeclined:
            return "Your card was declined. Please check your details or contact your bank."
        case .networkError:
            return "Connection issue. Please check your internet and try again."
        case .providerError(_, let message):
            return message
        case .userCancelled:
            return "Payment was cancelled."
        case .timeout:
            return "Payment timed out. Please try again."
        case .invalidConfiguration(let detail):
            return "Configuration error: \(detail)"
        case .gatewayNotFound(let method):
            return "Payment method \(method) is not available."
        }
    }
}

// MARK: - Currency

public enum Currency: String, Sendable, CaseIterable {
    case SAR, AED, USD, EUR, GBP, KWD, BHD, QAR, OMR, EGP, INR
}
