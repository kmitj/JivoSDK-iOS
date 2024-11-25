//
//  JMTimelineEventCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 15/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit

fileprivate var staticFocusedTimelineItemUUID: String?
func JMTimelineStoreUUID(_ uuid: String) { staticFocusedTimelineItemUUID = uuid }
func JMTimelineObtainUUID() -> String? { return staticFocusedTimelineItemUUID }

open class JMTimelineEventCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    public private(set) lazy var container: JMTimelineContainer = { obtainContainer() }()
    private let longPressGesture = UILongPressGestureRecognizer()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        container.frame = contentView.bounds
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(container)
        
        longPressGesture.addTarget(self, action: #selector(handleLongPress))
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func obtainCanvas() -> JMTimelineCanvas {
        abort()
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return container.sizeThatFits(size)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
//        container.frame = contentView.bounds
    }
    
    fileprivate func obtainContainer() -> JMTimelineContainer {
        return JMTimelineContainer(canvas: obtainCanvas())
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        _ = container.canvas.handleLongPressInteraction(gesture: gesture)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === longPressGesture {
            return otherGestureRecognizer is UILongPressGestureRecognizer
        }
        else {
            return false
        }
    }
}
