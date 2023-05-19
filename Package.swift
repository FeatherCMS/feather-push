// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "feather-push",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "FeatherPush", targets: ["FeatherPush"]),
        .library(name: "FeatherAPNS", targets: ["FeatherAPNS"]),
        .library(name: "FeatherFCM", targets: ["FeatherFCM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.10.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),
        .package(url: "https://github.com/swift-server-community/APNSwift.git", from: "5.0.0-beta.2"),
    ],
    targets: [
        .target(name: "FeatherAPNS", dependencies: [
            .product(name: "APNS", package: "APNSwift"),
        ]),
        .target(name: "FeatherFCM", dependencies: [
            .product(name: "JWTKit", package: "jwt-kit"),
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
        ]),
        .target(name: "FeatherPush", dependencies: [
            .target(name: "FeatherFCM"),
            .target(name: "FeatherAPNS"),
        ]),
        .testTarget(name: "FeatherPushTests", dependencies: [
            .target(name: "FeatherPush"),
        ]),
    ]
)
