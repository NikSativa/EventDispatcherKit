// swift-tools-version:5.8
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
        .library(name: "EventDispatcherKit", targets: ["EventDispatcherKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/SpryKit.git", .upToNextMinor(from: "3.0.2")),
        .package(url: "https://github.com/NikSativa/Threading.git", .upToNextMinor(from: "2.1.1"))
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
