# SwiftPaymentKit

![CI](https://github.com/vishalgandhi90/SwiftPaymentKit/actions/workflows/ci.yml/badge.svg)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![iOS 15+](https://img.shields.io/badge/iOS-15+-blue.svg)
![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A unified payment gateway abstraction layer for iOS apps. Integrate multiple payment providers — HyperPay, STC Pay, Tabby, Tamara, Apple Pay, and more — through a single, protocol-based API.

## Features

- **Unified API** — One interface for all payment providers
- **Protocol-based** — Easy to add custom gateways
- **Async/await** — Built with modern Swift concurrency
- **Automatic retry** — Configurable retry logic for transient failures
- **Event delegation** — Lifecycle hooks for analytics and UI updates
- **Type-safe** — Strongly typed payment methods, currencies, and errors
- **Testable** — Protocol-driven design makes mocking straightforward

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/vishalgandhi90/SwiftPaymentKit.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → paste the URL.

## Quick Start

```swift
import SwiftPaymentKit

// 1. Configure
let config = PaymentConfiguration(
    environment: .production,
    merchantId: "your-merchant-id",
    maxRetryCount: 2
)
let manager = PaymentManager(configuration: config)

// 2. Register gateways
await manager.register(HyperPayGateway(apiKey: "..."))
await manager.register(STCPayGateway(merchantId: "..."))

// 3. Process payment
let result = try await manager.processPayment(
    method: .visa,
    amount: 99.99,
    currency: .SAR,
    orderId: "order-12345"
)

switch result {
case .success(let transactionId):
    print("Payment successful: \(transactionId)")
case .pending(let checkoutId):
    print("Payment pending: \(checkoutId)")
case .cancelled:
    print("User cancelled")
case .failed(let error):
    print("Failed: \(error.userMessage)")
}
```

## Creating a Custom Gateway

Conform to `PaymentGateway`:

```swift
final class MyGateway: PaymentGateway {
    let name = "MyGateway"
    let supportedMethods: [PaymentMethod] = [.visa, .mastercard]

    func initiatePayment(
        amount: Decimal, currency: Currency,
        orderId: String, metadata: [String: String]
    ) async throws -> PaymentSession {
        // Call your API to create a checkout session
        let checkoutId = try await api.createCheckout(amount: amount)
        return PaymentSession(checkoutId: checkoutId, gatewayName: name)
    }

    func processPayment(session: PaymentSession) async throws -> PaymentResult {
        // Present payment UI and wait for result
        let txnId = try await api.processCheckout(session.checkoutId)
        return .success(transactionId: txnId)
    }

    func verifyPayment(transactionId: String) async throws -> PaymentStatus {
        return try await api.checkStatus(transactionId)
    }

    func cancelPayment(transactionId: String) async throws -> PaymentStatus {
        return try await api.cancel(transactionId)
    }
}
```

## Architecture

```
PaymentManager (coordinator)
├── registers PaymentGateway implementations
├── routes payments to correct gateway by PaymentMethod
├── handles retry logic for transient errors
└── emits events via PaymentEventDelegate

PaymentGateway (protocol)
├── HyperPayGateway  → .visa, .mastercard, .mada
├── STCPayGateway    → .stcPay
├── TabbyGateway     → .tabby
├── TamaraGateway    → .tamara
└── YourGateway      → .custom("...")
```

## Requirements

- iOS 15+ / macOS 13+
- Swift 5.9+
- Xcode 15+

## License

MIT License. See [LICENSE](LICENSE) for details.

## Author

**Vishal Gandhi** — [vishalgandhi.dev](https://vishalgandhi.dev) · [GitHub](https://github.com/vishalgandhi90)
