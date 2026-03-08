import XCTest
@testable import SwiftPaymentKit

final class PaymentManagerTests: XCTestCase {

    func testRegisterGateway() async {
        let manager = PaymentManager()
        let gateway = MockPaymentGateway(supportedMethods: [.visa, .mada])
        await manager.register(gateway)

        let methods = await manager.availableMethods()
        XCTAssertTrue(methods.contains(.visa))
        XCTAssertTrue(methods.contains(.mada))
    }

    func testProcessPaymentSuccess() async throws {
        let manager = PaymentManager()
        let gateway = MockPaymentGateway()
        gateway.stubbedResult = .success(transactionId: "txn-001")
        await manager.register(gateway)

        let result = try await manager.processPayment(
            method: .visa,
            amount: 99.99,
            currency: .SAR,
            orderId: "order-001"
        )

        if case .success(let txnId) = result {
            XCTAssertEqual(txnId, "txn-001")
        } else {
            XCTFail("Expected success result")
        }
    }

    func testProcessPaymentGatewayNotFound() async {
        let manager = PaymentManager()

        do {
            _ = try await manager.processPayment(
                method: .stcPay,
                amount: 50.0,
                currency: .SAR,
                orderId: "order-002"
            )
            XCTFail("Expected error")
        } catch let error as PaymentError {
            if case .gatewayNotFound = error {
                // Expected
            } else {
                XCTFail("Expected gatewayNotFound error")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testProcessPaymentRouting() async throws {
        let manager = PaymentManager()
        let cardGateway = MockPaymentGateway(name: "CardGateway", supportedMethods: [.visa, .mastercard])
        let stcGateway = MockPaymentGateway(name: "STCGateway", supportedMethods: [.stcPay])

        await manager.register(cardGateway)
        await manager.register(stcGateway)

        _ = try await manager.processPayment(
            method: .stcPay, amount: 25.0, currency: .SAR, orderId: "order-003"
        )

        XCTAssertEqual(stcGateway.processCallCount, 1)
        XCTAssertEqual(cardGateway.processCallCount, 0)
    }

    func testPaymentErrorIsRetryable() {
        XCTAssertTrue(PaymentError.networkError().isRetryable)
        XCTAssertTrue(PaymentError.timeout.isRetryable)
        XCTAssertFalse(PaymentError.cardDeclined.isRetryable)
        XCTAssertFalse(PaymentError.userCancelled.isRetryable)
        XCTAssertFalse(PaymentError.insufficientFunds.isRetryable)
    }
}
