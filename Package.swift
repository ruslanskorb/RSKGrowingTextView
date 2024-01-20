// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "RSKGrowingTextView",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "RSKGrowingTextView", targets: ["RSKGrowingTextView"])
    ],
    dependencies: [
        .package(url: "https://github.com/ruslanskorb/RSKPlaceholderTextView.git", from: "8.0.0")
    ],
    targets: [
        .target(name: "RSKGrowingTextView", dependencies: ["RSKPlaceholderTextView"], path: "RSKGrowingTextView")
    ],
    swiftLanguageVersions: [.v5]
)
