// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "RSKGrowingTextView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "RSKGrowingTextView", targets: ["RSKGrowingTextView"])
    ],
    dependencies: [
        .package(url: "https://github.com/ruslanskorb/RSKPlaceholderTextView.git", from: "6.1.0")
    ],
    targets: [
        .target(name: "RSKGrowingTextView", dependencies: ["RSKPlaceholderTextView"], path: "RSKGrowingTextView")
    ],
    swiftLanguageVersions: [.v5]
)
