//
//  JMTimelineView.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 29/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import SwiftyNSException

open class JMTimelineView<Interactor: JMTimelineInteractor>: UICollectionView {
    private let interactor: Interactor
    
    public init(interactor: Interactor) {
        self.interactor = interactor
        
        super.init(frame: .zero, collectionViewLayout: JMTimelineCollectionLayout())
        
        interactor.timelineView = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismissOwnMenu() {
        guard isFirstResponder else { return }
        guard UIMenuController.shared.isMenuVisible else { return }
        UIMenuController.shared.isMenuVisible = false
    }
    
    public override var canBecomeFirstResponder: Bool {
        if let uuid = JMTimelineObtainUUID() {
            interactor.prepareForItem(uuid: uuid)
        }
        
        return true
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let _ = JMTimelineObtainUUID() {
            return interactor.canPerformAction(action, withSender: sender)
        }
        else {
            return false
        }
    }
    
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return interactor
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismissOwnMenu()
    }
    
//    open override func reloadData() {
//        UIView.performWithoutAnimation {
//            super.reloadData()
//        }
//    }
}
