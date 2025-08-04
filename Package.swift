// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppAboutView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v17),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AppAboutView",
            targets: ["AppAboutView"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppAboutView",
            dependencies: [],
            resources: [
                .process("Resources")
            ],
            plugins: []
        ),
        .testTarget(
            name: "AppAboutViewTests",
            dependencies: ["AppAboutView"]
        ),
        .testTarget(
            name: "AppAboutViewUITests",
            dependencies: ["AppAboutView"]
        ),
    ]
)
