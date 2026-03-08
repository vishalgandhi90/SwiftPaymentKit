// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftPaymentKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SwiftPaymentKit", targets: ["SwiftPaymentKit"]),
    ],
    targets: [
        .target(name: "SwiftPaymentKit"),
        .testTarget(name: "SwiftPaymentKitTests", dependencies: ["SwiftPaymentKit"]),
    ]
)
