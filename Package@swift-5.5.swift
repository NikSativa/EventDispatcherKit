// swift-tools-version:5.5
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "EventDispatcherKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "EventDispatcherKit", targets: ["EventDispatcherKit"]),
        .library(name: "EventDispatcherKitTestHelpers", targets: ["EventDispatcherKitTestHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/Threading.git", .upToNextMajor(from: "1.3.4")),
        .package(url: "https://github.com/NikSativa/SpryKit.git", .upToNextMajor(from: "2.2.2"))
    ],
    targets: [
        .target(name: "EventDispatcherKit",
                dependencies: [
                    "Threading"
                ],
                path: "Sources",
                resources: [
                    .copy("../PrivacyInfo.xcprivacy")
                ]),
        .target(name: "EventDispatcherKitTestHelpers",
                dependencies: [
                    "EventDispatcherKit",
                    "SpryKit"
                ],
                path: "TestHelpers",
                resources: [
                    .copy("../PrivacyInfo.xcprivacy")
                ]),
        .testTarget(name: "EventDispatcherKitTests",
                    dependencies: [
                        "Threading",
                        .product(name: "ThreadingTestHelpers", package: "Threading"),
                        "SpryKit",
                        "EventDispatcherKit",
                        "EventDispatcherKitTestHelpers"
                    ],
                    path: "Tests")
    ]
)
