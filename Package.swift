// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JivoSDK-iOS",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "JivoSDK-iOS", targets: ["JivoSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/FluidGroup/TypedTextAttributes.git", from: "2.0.0"),
        .package(url: "https://github.com/JivoSite/pure-parser.git", from: "1.0.4"),
        .package(url: "https://github.com/ashleymills/Reachability.swift.git", from: "5.2.4"),
        .package(url: "https://github.com/malcommac/SwiftDate.git", from: "7.0.0"),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "24.0.0"),
        .package(url: "https://github.com/1024jp/GzipSwift.git", from: "6.1.0"),
        .package(url: "https://github.com/auth0/JWTDecode.swift.git", exact: "3.1.0"),
        .package(url: "https://github.com/iziz/libPhoneNumber-iOS.git", exact: "1.1.0"),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger.git", from: "7.1.5"),
        .package(url: "https://github.com/DenTelezhkin/DTCollectionViewManager.git", from: "11.0.0"),
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
                "CollectionAndTableViewCompatible",
                "JMCodingKit",
                "JFMarkdownKit",
                "SwiftGraylog",
                "JFWebSocket",
                .product(name: "Gzip", package: "GzipSwift"),
                .product(name: "XCGLogger", package: "XCGLogger"),
                .product(name: "JWTDecode", package: "JWTDecode.swift"),
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "DTCollectionViewManager", package: "DTCollectionViewManager"),
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "SwiftDate", package: "SwiftDate"),
                .product(name: "libPhoneNumber", package: "libPhoneNumber-iOS"),
                .product(name: "PureParser", package: "pure-parser"),
            ],
            path: "JivoSDK/Sources",
            resources: [
                .process("Shared/Models/JVDatabase.xcdatamodeld"),
                .process("Shared/Design/AssetsDesign.xcassets"),
                .process("Resources/Assets.xcassets"),
                .copy("Shared/Design/fontello_entypo.ttf"),
                .copy("Shared/Resources/Fonts/roboto.medium.ttf"),
                .copy("Shared/Resources/Fonts/roboto.regular.ttf"),
            ]),
        .target(name: "CollectionAndTableViewCompatible", path: "CollectionAndTableViewCompatible"),
        .target(name: "JMDesignKit", path: "JMDesignKit"),
        .target(name: "JMCodingKit", path: "JMCodingKit"),
        .target(name: "JMImageLoader", path: "JMImageLoader"),
        .target(name: "JMSidePanelKit", path: "JMSidePanelKit"),
        .target(name: "JFMarkdownKit", path: "JFMarkdownKit"),
        .target(name: "SwiftGraylog", path: "SwiftGraylog"),
        .target(name: "JFWebSocket", path: "JFWebSocket"),
        .target(name: "JMOnetimeCalculator", path: "JMOnetimeCalculator"),
        .target(name: "SwiftNSExceptionObjc", path: "SwiftNSExceptionObjc", publicHeadersPath: "include"),
        .target(name: "SwiftyNSException",
                dependencies: [
                    "SwiftNSExceptionObjc"
                ],
                path: "SwiftyNSException"),
        .target(name: "SwiftMime",
                path: "SwiftMime",
                resources: [
                    .copy("Resource/types.json"),
                ]),
        .target(name: "JFEmojiPicker",
                path: "JFEmojiPicker",
                resources: [
                    .process("Resource/Assets.xcassets"),
                    .copy("Resource/emojis.json"),
                    .copy("Resource/emojis9.1.json"),
                    .copy("Resource/emojis11.0.1.json"),
                ]),
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
                    "JFMarkdownKit",
                    .product(name: "TypedTextAttributes", package: "TypedTextAttributes"),
                ],
                path: "JMMarkdownKit"),
        .target(name: "JMTimelineKit",
                dependencies: [
                    "JMOnetimeCalculator",
                    "SwiftyNSException",
                    .product(name: "DTCollectionViewManager", package: "DTCollectionViewManager"),
                ],
                path: "JMTimelineKit"),
    ]
)
