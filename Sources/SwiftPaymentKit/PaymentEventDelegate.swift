import Foundation

public protocol PaymentEventDelegate: AnyObject, Sendable {
    func paymentWillInitiate(method: PaymentMethod, amount: Decimal, currency: Currency)
    func paymentDidInitiate(session: PaymentSession)
    func paymentDidComplete(result: PaymentResult)
    func paymentDidFail(error: PaymentError)
    func paymentDidCancel()
}

/// Default implementations so delegates only need to implement what they care about.
public extension PaymentEventDelegate {
    func paymentWillInitiate(method: PaymentMethod, amount: Decimal, currency: Currency) {}
    func paymentDidInitiate(session: PaymentSession) {}
    func paymentDidComplete(result: PaymentResult) {}
    func paymentDidFail(error: PaymentError) {}
    func paymentDidCancel() {}
}
