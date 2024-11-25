//
//  JMRepicTypes.swift
//  JMRepicView
//
//  Created by Stan Potemkin on 23/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public typealias JMRepicDimensionProvider = (CGFloat) -> CGFloat

public struct JMRepicConfig {
    let side: CGFloat
    let borderWidth: CGFloat
    let borderColor: UIColor
    let itemConfig: JMRepicItemConfig
    let layoutMap: [Int: [JMRepicLayoutItem]]
    
    public init(side: CGFloat,
                borderWidth: CGFloat,
                borderColor: UIColor,
                itemConfig: JMRepicItemConfig,
                layoutMap: [Int: [JMRepicLayoutItem]]) {
        self.side = side
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.itemConfig = itemConfig
        self.layoutMap = layoutMap
    }
}

public struct JMRepicItemConfig {
    let borderWidthProvider: JMRepicDimensionProvider
    let borderColor: UIColor

    public init(borderWidthProvider: @escaping JMRepicDimensionProvider,
                borderColor: UIColor) {
        self.borderWidthProvider = borderWidthProvider
        self.borderColor = borderColor
    }
}

public struct JMRepicIndicatorConfig {
    let sideProvider: JMRepicDimensionProvider
    let borderWidthProvider: JMRepicDimensionProvider
    let borderColor: UIColor
    let contentMarginProvider: JMRepicDimensionProvider
    let contentTintColor: UIColor?
    
    public init(sideProvider: @escaping JMRepicDimensionProvider,
                borderWidthProvider: @escaping JMRepicDimensionProvider,
                borderColor: UIColor,
                contentMarginProvider: @escaping JMRepicDimensionProvider,
                contentTintColor: UIColor?) {
        self.sideProvider = sideProvider
        self.borderWidthProvider = borderWidthProvider
        self.borderColor = borderColor
        self.contentMarginProvider = contentMarginProvider
        self.contentTintColor = contentTintColor
    }
}

public struct JMRepicLayoutItem {
    let position: CGPoint
    let radius: CGFloat
    
    public init(position: CGPoint, radius: CGFloat) {
        self.position = position
        self.radius = radius
    }
}

public struct JMRepicItem: Hashable {
    public let backgroundColor: UIColor?
    public let source: JMRepicItemSource
    public let scale: CGFloat
    public let clipping: JMRepicItemClipping
    
    public init(backgroundColor: UIColor?, source: JMRepicItemSource, scale: CGFloat, clipping: JMRepicItemClipping) {
        self.backgroundColor = backgroundColor
        self.source = source
        self.scale = scale
        self.clipping = clipping
    }
    
    public var link: String? {
        return source.URL?.absoluteString
    }
    
    public var hashValue: Int {
        var result = 0
        result ^= backgroundColor.hashValue
        result ^= source.hashValue
        result ^= scale.hashValue
        result ^= clipping.hashValue
        return result
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(backgroundColor)
        hasher.combine(source)
        hasher.combine(scale)
        hasher.combine(clipping)
    }
}

public enum JMRepicItemSource: Hashable {
    case avatar(URL: URL?, image: UIImage?, color: UIColor?, transparent: Bool)
    case remote(URL)
    case named(asset: String, template: Bool)
    case exact(UIImage)
    case caption(String, UIFont)
    case empty
    
    public var URL: URL? {
        switch self {
        case .avatar(let URL, _, _, _): return URL
        case .remote(let URL): return URL
        case .named: return nil
        case .exact: return nil
        case .caption: return nil
        case .empty: return nil
        }
    }
}

public enum JMRepicItemClipping: Hashable {
    case disabled
    case external
    case dual
}

public func ==(lhs: JMRepicItemSource, rhs: JMRepicItemSource) -> Bool {
    switch (lhs, rhs) {
    case let (.avatar(fstURL, fstImage, fstColor, fstTransparent), .avatar(sndURL, sndImage, sndColor, sndTransparent)):
        guard fstURL == sndURL else { return false }
        guard fstImage?.size == sndImage?.size else { return false }
        guard fstColor == sndColor else { return false }
        guard fstTransparent == sndTransparent else { return false }
        return true
        
    case let (.remote(fstURL), .remote(sndURL)):
        guard fstURL == sndURL else { return false }
        return true
        
    case let (.named(fstName), .named(sndName)):
        guard fstName == sndName else { return false }
        return true
        
    case let (.exact(fstImage), .exact(sndImage)):
        guard fstImage.size == sndImage.size else { return false }
        return true
        
    case let (.caption(fstCaption, _), .caption(sndCaption, _)):
        guard fstCaption == sndCaption else { return false }
        return true

    default:
        return false
    }
}
