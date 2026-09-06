// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "gnome",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(name: "gnome", targets: ["gnome"]),
    ],
    targets: [
        .target(
            name: "gnome",
            path: "src"
        ),
    ]
)