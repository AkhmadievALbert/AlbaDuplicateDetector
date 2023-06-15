// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlbaDuplicateDetector",
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "0.50300.0"),
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