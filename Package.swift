// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorCacheFile",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "CapacitorCacheFile",
            targets: ["cacheFilePlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "cacheFilePlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/cacheFilePlugin"),
        .testTarget(
            name: "cacheFilePluginTests",
            dependencies: ["cacheFilePlugin"],
            path: "ios/Tests/cacheFilePluginTests")
    ]
)