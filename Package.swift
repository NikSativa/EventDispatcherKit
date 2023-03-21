// swift-tools-version:5.6
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "NEventDispatcher",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "NEventDispatcher", targets: ["NEventDispatcher"]),
        .library(name: "NEventDispatcherTestHelpers", targets: ["NEventDispatcherTestHelpers"])
    ],
    dependencies: [
        .package(url: "git@github.com:NikSativa/NQueue.git", .upToNextMajor(from: "1.1.17")),
        .package(url: "git@github.com:NikSativa/NSpry.git", .upToNextMajor(from: "1.3.3")),
        .package(url: "git@github.com:Quick/Quick.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "git@github.com:Quick/Nimble.git", .upToNextMajor(from: "11.2.1"))
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
                        "Quick",
                        "Nimble",
                        "NSpry",
                        .product(name: "NSpry_Nimble", package: "NSpry"),
                        "NEventDispatcher",
                        "NEventDispatcherTestHelpers"
                    ],
                    path: "Tests")
    ]
)
