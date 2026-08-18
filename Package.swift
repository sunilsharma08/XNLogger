// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XNLogger",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "XNLogger",
            targets: ["XNLogger"]
        ),
    ],
    dependencies: [],
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
            dependencies: ["XNLogger"],
            path: "XNLoggerTests",
            exclude: ["Info.plist"]
        ),
    ]
)
