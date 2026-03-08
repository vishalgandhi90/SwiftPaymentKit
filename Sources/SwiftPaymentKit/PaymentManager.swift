import Foundation

public actor PaymentManager {
    private var gateways: [PaymentMethod: PaymentGateway] = [:]
    private var configuration: PaymentConfiguration
    private weak var delegate: PaymentEventDelegate?
    private let logger: PaymentLogger

    public init(
        configuration: PaymentConfiguration = .init(),
        logger: PaymentLogger = ConsolePaymentLogger()
    ) {
        self.configuration = configuration
        self.logger = logger
    }

    public func setDelegate(_ delegate: PaymentEventDelegate) {
        self.delegate = delegate
    }

    // MARK: - Gateway Registration

    public func register(_ gateway: PaymentGateway) {
        for method in gateway.supportedMethods {
            gateways[method] = gateway
            logger.log("Registered \(gateway.name) for \(method)", level: .debug)
        }
    }

    public func availableMethods() -> [PaymentMethod] {
        Array(gateways.keys)
    }

    // MARK: - Payment Processing

    public func processPayment(
        method: PaymentMethod,
        amount: Decimal,
        currency: Currency,
        orderId: String,
        metadata: [String: String] = [:]
    ) async throws -> PaymentResult {
        guard let gateway = gateways[method] else {
            throw PaymentError.gatewayNotFound(method)
        }

        delegate?.paymentWillInitiate(method: method, amount: amount, currency: currency)
        logger.log("Initiating \(method) payment of \(amount) \(currency.rawValue)", level: .info)

        var lastError: PaymentError?
        let maxRetries = configuration.maxRetryCount

        for attempt in 0...maxRetries {
            if attempt > 0 {
                logger.log("Retry attempt \(attempt)/\(maxRetries) for \(orderId)", level: .info)
            }

            do {
                let session = try await gateway.initiatePayment(
                    amount: amount,
                    currency: currency,
                    orderId: orderId,
                    metadata: metadata
                )
                delegate?.paymentDidInitiate(session: session)

                let result = try await gateway.processPayment(session: session)

                switch result {
                case .success(let txnId):
                    logger.log("Payment successful: \(txnId)", level: .info)
                    delegate?.paymentDidComplete(result: result)
                case .pending(let checkoutId):
                    logger.log("Payment pending: \(checkoutId)", level: .info)
                    delegate?.paymentDidComplete(result: result)
                case .cancelled:
                    logger.log("Payment cancelled by user", level: .info)
                    delegate?.paymentDidCancel()
                case .failed(let error):
                    logger.log("Payment failed: \(error.userMessage)", level: .error)
                    delegate?.paymentDidFail(error: error)
                }

                return result

            } catch let error as PaymentError {
                lastError = error
                if !error.isRetryable || attempt == maxRetries {
                    delegate?.paymentDidFail(error: error)
                    throw error
                }
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
            } catch {
                let wrappedError = PaymentError.networkError(underlying: error)
                delegate?.paymentDidFail(error: wrappedError)
                throw wrappedError
            }
        }

        throw lastError ?? PaymentError.networkError()
    }

    // MARK: - Verification

    public func verifyPayment(
        method: PaymentMethod,
        transactionId: String
    ) async throws -> PaymentStatus {
        guard let gateway = gateways[method] else {
            throw PaymentError.gatewayNotFound(method)
        }
        return try await gateway.verifyPayment(transactionId: transactionId)
    }
}
