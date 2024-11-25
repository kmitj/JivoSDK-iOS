//
//  JMTimelineHeaderView.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

open class JMTimelineHeaderView: UICollectionReusableView {
    public private(set) lazy var container: JMTimelineContainer = { obtainContainer() }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(container)
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
        container.frame = bounds
    }
    
    fileprivate func obtainContainer() -> JMTimelineContainer {
        return JMTimelineContainer(canvas: obtainCanvas())
    }
}
