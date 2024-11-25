//
//  JMTimelineObservableSlider.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 13/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

open class JMTimelineObservableSlider: UISlider {
    public var beginHandler: ((Float) -> Bool)?
    public var adjustHandler: ((Float) -> Bool)?
    public var endHandler: (() -> Void)?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(handleValueChange), for: .valueChanged)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let point = touches.first?.location(in: self) {
            let progress = Float(point.x / bounds.width)
            if (beginHandler?(progress) ?? true) == true {
                value = progress
            }
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let point = touches.first?.location(in: self) {
            let progress = Float(point.x / bounds.width)
            if (adjustHandler?(progress) ?? true) == true {
                value = progress
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        endHandler?()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        endHandler?()
    }
    
    @objc private func handleValueChange() {
        _ = adjustHandler?(value)
    }
}
