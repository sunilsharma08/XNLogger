// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XNLogger",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "XNLogger",
            targets: ["XNLogger"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "XNLogger",
            dependencies: [],
            path: "XNLogger",
            exclude: [
                "UI/XNLoader.m",
                "Info.plist",
                "XNLogger.h"
            ],
            resources: [
                .process("UI/XNUIMain.storyboard"),
                .process("UI/LogDetailScreen/XNUILogDetailVC.xib"),
                .process("UI/LogDetailScreen/XNUILogDetailView.xib"),
                .process("UI/LogDetailScreen/XNUILogDetailCell.xib"),
                .process("UI/LogDetailScreen/XNUILogDetailHeaderCell.xib"),
                .process("UI/LogsListScreen/XNUILogListTableViewCell.xib"),
                .process("UI/ResponseFullScreen/XNUIResponseFullScreenVC.xib"),
                .process("UI/SettingsScreen/XNUISettingsCell.xib"),
                .process("UI/Resources/Media.xcassets")
            ],
            linkerSettings: [
                .linkedFramework("WebKit")
            ]
        ),
        .testTarget(
            name: "XNLoggerTests",
            dependencies: [
                "XNLogger",
                .product(name: "Swifter", package: "swifter"),
            ],
            path: "XNLoggerTests",
            exclude: ["Info.plist"]
        ),
    ]
)
