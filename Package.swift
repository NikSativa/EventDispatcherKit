// swift-tools-version:5.8
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "NEventDispatcher",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(name: "NEventDispatcher", targets: ["NEventDispatcher"]),
        .library(name: "NEventDispatcherTestHelpers", targets: ["NEventDispatcherTestHelpers"])
    ],
    dependencies: [
        .package(url: "git@github.com:NikSativa/NQueue.git", .upToNextMajor(from: "1.2.2")),
        .package(url: "git@github.com:NikSativa/NSpry.git", .upToNextMajor(from: "2.1.1"))
    ],
    targets: [
        .target(name: "NEventDispatcher",
                dependencies: [
                    "NQueue"
                ],
                path: "Sources"),
        .target(name: "NEventDispatcherTestHelpers",
                dependencies: [
                    "NEventDispatcher",
                    "NSpry"
                ],
                path: "TestHelpers"),
        .testTarget(name: "NEventDispatcherTests",
                    dependencies: [
                        "NQueue",
                        .product(name: "NQueueTestHelpers", package: "NQueue"),
                        "NSpry",
                        "NEventDispatcher",
                        "NEventDispatcherTestHelpers"
                    ],
                    path: "Tests")
    ]
)
