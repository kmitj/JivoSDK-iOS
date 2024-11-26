// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JivoSDK-iOS",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "JivoSDK-iOS", targets: ["JivoSDK"]),
        .library(name: "JFEmojiPicker", targets: ["JFEmojiPicker"]),
        .library(name: "SwiftMime", targets: ["SwiftMime"]),
        .library(name: "JMOnetimeCalculator", targets: ["JMOnetimeCalculator"]),
        .library(name: "JMTimelineKit", targets: ["JMTimelineKit"]),
        .library(name: "JMDesignKit", targets: ["JMDesignKit"]),
        .library(name: "JMMarkdownKit", targets: ["JMMarkdownKit"]),
        .library(name: "SwiftyNSException", targets: ["SwiftyNSException"]),
        .library(name: "JMImageLoader", targets: ["JMImageLoader"]),
    ],
    dependencies: [
        .package(url: "https://github.com/FluidGroup/TypedTextAttributes.git", from: "2.0.0"),
        .package(url: "https://github.com/JivoSite/pure-parser.git", from: "1.0.4"),
        .package(url: "https://github.com/ashleymills/Reachability.swift.git", from: "5.2.4"),
        .package(url: "https://github.com/malcommac/SwiftDate.git", from: "7.0.0"),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "24.0.0"),
        .package(url: "https://github.com/1024jp/GzipSwift.git", from: "6.1.0"),
        .package(url: "https://github.com/kmitj/CollectionAndTableViewCompatible.git", exact: "0.2.6"),
        .package(url: "https://github.com/auth0/JWTDecode.swift.git", exact: "3.1.0"),
        .package(url: "https://github.com/iziz/libPhoneNumber-iOS.git", exact: "1.1.0"),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger.git", from: "7.1.5"),
        .package(url: "https://github.com/kmitj/JMCodingKit.git", from: "5.0.2"),
        .package(url: "https://github.com/DenTelezhkin/DTCollectionViewManager.git", from: "11.0.0"),
        .package(url: "https://github.com/kmitj/JFMarkdownKit.git", from: "1.3.1"),
        .package(url: "https://github.com/kmitj/swift-graylog.git", from: "1.0.1"),
        .package(url: "https://github.com/kmitj/JFWebSocket.git", from: "2.9.8"),
    ],
    targets: [
        .target(
            name: "JivoSDK",
            dependencies: [
                "JFEmojiPicker",
                "JMTimelineKit",
                "JMMarkdownKit",
                "JMScalableView",
                "JMRepicKit",
                "JMSidePanelKit",
                "SwiftMime",
                "SwiftyNSException",
                .product(name: "JFWebSocket", package: "JFWebSocket"),
                .product(name: "SwiftGraylog", package: "swift-graylog"),
                .product(name: "Gzip", package: "GzipSwift"),
                .product(name: "XCGLogger", package: "XCGLogger"),
                .product(name: "JFMarkdownKit", package: "JFMarkdownKit"),
                .product(name: "JWTDecode", package: "JWTDecode.swift"),
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "JMCodingKit", package: "JMCodingKit"),
                .product(name: "CollectionAndTableViewCompatible", package: "CollectionAndTableViewCompatible"),
                .product(name: "DTCollectionViewManager", package: "DTCollectionViewManager"),
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "SwiftDate", package: "SwiftDate"),
                .product(name: "libPhoneNumber", package: "libPhoneNumber-iOS"),
                .product(name: "PureParser", package: "pure-parser"),
            ],
            path: "JivoSDK/Sources",
            resources: [
                .process("Shared/Models/JVDatabase.xcdatamodeld"),
                .process("Shared/Models/JVDatabase.momd")
            ]),
//        .target(name: "JivoShared",
//                dependencies: [
//                    "SwiftyNSException",
//                    .product(name: "JFWebSocket", package: "JFWebSocket"),
//                    .product(name: "Gzip", package: "GzipSwift"),
//                    .product(name: "XCGLogger", package: "XCGLogger"),
//                    .product(name: "DTCollectionViewManager", package: "DTCollectionViewManager"),
//                    .product(name: "Reachability", package: "Reachability.swift"),
//                    .product(name: "SwiftDate", package: "SwiftDate"),
//                    .product(name: "libPhoneNumber", package: "libPhoneNumber-iOS"),
//                    .product(name: "PureParser", package: "pure-parser"),
//                ],
//                path: "Shared"),
        .target(name: "JFEmojiPicker", path: "JFEmojiPicker"),
        .target(name: "JMDesignKit", path: "JMDesignKit"),
        .target(name: "JMImageLoader", path: "JMImageLoader"),
        .target(name: "JMSidePanelKit", path: "JMSidePanelKit"),
        .target(name: "JMScalableView",
                dependencies: [
                    "JMDesignKit"
                ],
                path: "JMScalableView"),
        .target(name: "JMRepicKit",
                dependencies: [
                    "JMImageLoader"
                ],
                path: "JMRepicKit"),
        .target(name: "JMMarkdownKit",
                dependencies: [
                    "JMDesignKit",
                    .product(name: "TypedTextAttributes", package: "TypedTextAttributes"),
                    .product(name: "JFMarkdownKit", package: "JFMarkdownKit"),
                ],
                path: "JMMarkdownKit"),
        .target(name: "JMOnetimeCalculator", path: "JMOnetimeCalculator"),
        .target(name: "SwiftMime", path: "SwiftMime"),
        .target(name: "SwiftNSExceptionObjc", path: "SwiftNSExceptionObjc", publicHeadersPath: "include"),
        .target(name: "SwiftyNSException",
                dependencies: [
                    "SwiftNSExceptionObjc"
                ],
                path: "SwiftyNSException"),
        .target(name: "JMTimelineKit",
                dependencies: [
                    "JMOnetimeCalculator",
                    "SwiftyNSException",
                    .product(name: "DTCollectionViewManager", package: "DTCollectionViewManager"),
                ],
                path: "JMTimelineKit"),
    ]
)
