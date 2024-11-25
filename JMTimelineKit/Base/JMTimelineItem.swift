//
// Created by Stan Potemkin on 09/08/2018.
// Copyright (c) 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public struct JMTimelineItemLayoutValues: JMTimelineStyle {
    public let margins: UIEdgeInsets
    public let groupingCoef: CGFloat
//    public let contentStyle: JMTimelineStyle
    
    public init(margins: UIEdgeInsets,
                groupingCoef: CGFloat
//                contentStyle: JMTimelineStyle
    ) {
        self.margins = margins
        self.groupingCoef = groupingCoef
//        self.contentStyle = contentStyle
    }
}

public struct JMTimelineExtraActions {
    public let reactions: [JMTimelineReactionMeta]
    public let actions: [JMTimelineActionMeta]
    
    public init(reactions: [JMTimelineReactionMeta] = [], actions: [JMTimelineActionMeta] = []) {
        self.reactions = reactions
        self.actions = actions
    }
}

public struct JMTimelineReactionMeta {
    public let emoji: String
    public let number: Int
    public let participated: Bool
    
    public init(emoji: String, number: Int, participated: Bool) {
        self.emoji = emoji
        self.number = number
        self.participated = participated
    }
}

public struct JMTimelineActionMeta {
    public let ID: String
    public let icon: UIImage
    
    public init(ID: String, icon: UIImage) {
        self.ID = ID
        self.icon = icon
    }
}

public struct JMTimelineReactionStyle: JMTimelineStyle {
    public struct Element {
        public let paddingCoef: CGFloat
        public let fontReducer: CGFloat
        public let pullingCoef: CGFloat
        public init(paddingCoef: CGFloat, fontReducer: CGFloat, pullingCoef: CGFloat) {
            self.paddingCoef = paddingCoef
            self.fontReducer = fontReducer
            self.pullingCoef = pullingCoef
        }
    }
    
    public let height: CGFloat
    public let baseFont: UIFont
    public let regularBackgroundColor: UIColor
    public let regularNumberColor: UIColor
    public let selectedBackgroundColor: UIColor
    public let selectedNumberColor: UIColor
    public let sidePaddingCoef: CGFloat
    public let emojiElement: Element
    public let counterElement: Element
    public let actionElement: Element

    public init(height: CGFloat,
                baseFont: UIFont,
                regularBackgroundColor: UIColor,
                regularNumberColor: UIColor,
                selectedBackgroundColor: UIColor,
                selectedNumberColor: UIColor,
                sidePaddingCoef: CGFloat,
                emojiElement: Element,
                counterElement: Element,
                actionElement: Element) {
        self.height = height
        self.baseFont = baseFont
        self.regularBackgroundColor = regularBackgroundColor
        self.regularNumberColor = regularNumberColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.selectedNumberColor = selectedNumberColor
        self.sidePaddingCoef = sidePaddingCoef
        self.emojiElement = emojiElement
        self.counterElement = counterElement
        self.actionElement = actionElement
    }
}

public struct JMTimelineLogicOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let isVirtual = Self.init(rawValue: 1 << 0)
    public static let enableSizeCaching = Self.init(rawValue: 1 << 1)
    public static let missingHistoryPast = Self.init(rawValue: 1 << 2)
    public static let missingHistoryFuture = Self.init(rawValue: 1 << 3)
    public static let loadingHistoryPast = Self.init(rawValue: 1 << 4)
    public static let loadingHistoryFuture = Self.init(rawValue: 1 << 5)
}

public struct JMTimelineLayoutOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let groupTopMargin = JMTimelineLayoutOptions(rawValue: 1 << 0)
    public static let groupFirstElement = JMTimelineLayoutOptions(rawValue: 1 << 1)
    public static let groupLastElement = JMTimelineLayoutOptions(rawValue: 1 << 2)
    public static let groupBottomMargin = JMTimelineLayoutOptions(rawValue: 1 << 3)
    public static let allOptions = JMTimelineLayoutOptions(rawValue: ~0)
}

public class JMTimelineItemPayload {
    public let object: JMTimelineInfo
    public let style: JMTimelineStyle
    
    public init(object: JMTimelineInfo,
                style: JMTimelineStyle) {
        self.object = object
        self.style = style
    }
}

public typealias JMTimelineItemZoneProvider = (JMTimelineItem) -> UIView

open class JMTimelineItem: Equatable, Hashable {
    public let uid: String
    public let date: Date
    public let layoutValues: JMTimelineItemLayoutValues
    public let logicOptions: JMTimelineLogicOptions
    public private(set) var layoutOptions: JMTimelineLayoutOptions
    public let extraActions: JMTimelineExtraActions

    public init(uid: String,
                date: Date,
                layoutValues: JMTimelineItemLayoutValues,
                logicOptions: JMTimelineLogicOptions,
                extraActions: JMTimelineExtraActions
    ) {
        self.uid = uid
        self.date = date
        self.layoutValues = layoutValues
        self.logicOptions = logicOptions
        self.layoutOptions = .allOptions
        self.extraActions = extraActions
    }

    open var groupingID: String? {
        return uid
    }
    
    open var interactiveID: String? {
        return nil
    }
    
    public var hashValue: Int {
        return uid.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }

    final func addLayoutOptions(_ options: JMTimelineLayoutOptions) {
        layoutOptions.formUnion(options)
    }
    
    public final func hasLayoutOptions(_ options: JMTimelineLayoutOptions) -> Bool {
        return layoutOptions.contains(options)
    }
    
    final func removeLayoutOptions(_ options: JMTimelineLayoutOptions) {
        layoutOptions.subtract(options)
    }
    
    func equal(to another: JMTimelineItem) -> Bool {
        guard uid == another.uid else { return false }
        return true
    }
    
    public static func ==(lhs: JMTimelineItem, rhs: JMTimelineItem) -> Bool {
        return lhs.equal(to: rhs)
    }
}

public extension JMTimelineItem {
    func convert<T>(to: T.Type) -> T {
        return self as! T
    }
}
