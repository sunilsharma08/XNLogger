// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XNLogger",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "XNLogger",
            targets: ["XNLogger", "XNLogger-ObjC"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.4.5")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "XNLogger",
            dependencies: [],
            path: "XNLogger",
            exclude: ["UI/XNLoader.m", "Info.plist", "XNLogger.h"],
            sources: ["./"]),
        .target(
            name: "XNLogger-ObjC",
            dependencies: ["XNLogger"],
            path: "XNLogger",
            sources: ["UI/XNLoader.m"]),
        .testTarget(
            name: "XNLoggerTests",
            dependencies: ["XNLogger", "Swifter"],
            path: "XNLoggerTests"),
    ]
)
