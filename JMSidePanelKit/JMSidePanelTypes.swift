//
// Created by Stan Potemkin on 01/11/2018.
// Copyright (c) 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public protocol JMSidePanelView: AnyObject {
    func applyExtraInsets(_ insets: UIEdgeInsets)
    func preferredSize(for width: CGFloat) -> CGSize
}

public enum JMSidePanelPosition {
    case none
    case left
    case right
    case bottom
}

public enum JMSidePanelDepth {
    case back
    case front
}

public enum JMSidePanelSize {
    case value(CGFloat)
    case percent(CGFloat)
    case autosize(CGFloat)
}

public enum JMSidePanelGesture: Equatable {
    case none
    case edge(CGFloat)
    case full
}

public struct JMSidePanelAnimation {
    let duration: TimeInterval
    let curve: UIView.AnimationOptions

    public init(duration: TimeInterval,
                curve: UIView.AnimationOptions) {
        self.duration = duration
        self.curve = curve
    }
}

public enum JMSidePanelAxis {
    case horizontal
    case vertical
}

public struct JMSidePanel {
    let ID: String?
    let provider: () -> UIViewController?
    let depth: JMSidePanelDepth
    let size: JMSidePanelSize
    let dimBy: UIColor
    let gesture: JMSidePanelGesture
    let animation: JMSidePanelAnimation
    let exclusive: Bool
    let openHandler: (() -> Void)?
    let closeHandler: (() -> Void)?

    public init(ID: String?,
                provider: @escaping () -> UIViewController?,
                depth: JMSidePanelDepth,
                size: JMSidePanelSize,
                dimBy: UIColor,
                gesture: JMSidePanelGesture,
                animation: JMSidePanelAnimation,
                exclusive: Bool,
                openHandler: (() -> Void)?,
                closeHandler: (() -> Void)?) {
        self.ID = ID
        self.provider = provider
        self.depth = depth
        self.size = size
        self.dimBy = dimBy
        self.gesture = gesture
        self.animation = animation
        self.exclusive = exclusive
        self.openHandler = openHandler
        self.closeHandler = closeHandler
    }
}
