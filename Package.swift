// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlottedSlider",
    platforms: [ .iOS(.v14)],
    products: [
        .library(
            name: "SlottedSlider",
            targets: ["SlottedSlider"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SlottedSlider",
            dependencies: []),
        .testTarget(
            name: "SlottedSliderTests",
            dependencies: ["SlottedSlider"]),
    ]
)
