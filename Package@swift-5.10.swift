// swift-tools-version:5.10
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "EventDispatcherKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
        .macCatalyst(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "EventDispatcherKit", targets: ["EventDispatcherKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/SpryKit.git", from: "3.1.0"),
        .package(url: "https://github.com/NikSativa/Threading.git", from: "2.2.1")
    ],
    targets: [
        .target(name: "EventDispatcherKit",
                dependencies: [
                    "Threading"
                ],
                path: "Sources",
                resources: [
                    .process("PrivacyInfo.xcprivacy")
                ]),
        .testTarget(name: "EventDispatcherKitTests",
                    dependencies: [
                        "Threading",
                        "SpryKit",
                        "EventDispatcherKit",
                    ],
                    path: "Tests")
    ]
)
