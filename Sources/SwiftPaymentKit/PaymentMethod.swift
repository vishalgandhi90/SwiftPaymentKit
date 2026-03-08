import Foundation

public enum PaymentMethod: Hashable, Sendable {
    case visa
    case mastercard
    case mada
    case applePay
    case stcPay
    case tabby
    case tamara
    case cashOnDelivery
    case custom(String)
}

extension PaymentMethod: CustomStringConvertible {
    public var description: String {
        switch self {
        case .visa: return "Visa"
        case .mastercard: return "Mastercard"
        case .mada: return "Mada"
        case .applePay: return "Apple Pay"
        case .stcPay: return "STC Pay"
        case .tabby: return "Tabby"
        case .tamara: return "Tamara"
        case .cashOnDelivery: return "Cash on Delivery"
        case .custom(let name): return name
        }
    }
}
