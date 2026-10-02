// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swiftPaginator",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "swiftPaginator",
            targets: ["swiftPaginator"]
        )
    ],
    targets: [
        .target(
            name: "swiftPaginator"
        ),
        .testTarget(
            name: "swiftPaginatorTests",
            dependencies: ["swiftPaginator"]
        )
    ],
    swiftLanguageModes: [.v6]
)
