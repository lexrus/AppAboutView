// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppAboutView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
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
