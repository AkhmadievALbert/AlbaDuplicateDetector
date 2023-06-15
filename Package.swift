// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlbaDuplicateDetector",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ]
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "0.50700.1"),
    ],
    targets: [
        .executableTarget(
            name: "AlbaDuplicateDetector",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ],
            path: "AlbaDuplicateDetector/AlbaDuplicateDetector"
        )
    ]
)