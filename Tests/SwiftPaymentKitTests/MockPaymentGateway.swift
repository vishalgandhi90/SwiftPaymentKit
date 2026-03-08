import Foundation
@testable import SwiftPaymentKit

final class MockPaymentGateway: PaymentGateway, @unchecked Sendable {
    let name: String
    let supportedMethods: [PaymentMethod]

    var stubbedSession = PaymentSession(checkoutId: "mock-123", gatewayName: "Mock")
    var stubbedResult: PaymentResult = .success(transactionId: "txn-mock-456")
    var stubbedStatus: PaymentStatus = .completed(transactionId: "txn-mock-456")
    var shouldThrowOnInitiate = false
    var shouldThrowOnProcess = false
    var initiateCallCount = 0
    var processCallCount = 0

    init(name: String = "MockGateway", supportedMethods: [PaymentMethod] = [.visa, .mastercard]) {
        self.name = name
        self.supportedMethods = supportedMethods
    }

    func initiatePayment(
        amount: Decimal,
        currency: Currency,
        orderId: String,
        metadata: [String: String]
    ) async throws -> PaymentSession {
        initiateCallCount += 1
        if shouldThrowOnInitiate {
            throw PaymentError.networkError()
        }
        return stubbedSession
    }

    func processPayment(session: PaymentSession) async throws -> PaymentResult {
        processCallCount += 1
        if shouldThrowOnProcess {
            throw PaymentError.cardDeclined
        }
        return stubbedResult
    }

    func verifyPayment(transactionId: String) async throws -> PaymentStatus {
        return stubbedStatus
    }

    func cancelPayment(transactionId: String) async throws -> PaymentStatus {
        return .cancelled
    }
}
