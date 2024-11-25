//
//  ImmediatePanGestureRecognizer.swift
//  App
//
//  Created by Yulia Popova on 08.01.2023.
//  Copyright © 2023 JivoSite. All rights reserved.
//

import UIKit

class ImmediatePanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .ended { return }
        super.touchesEnded(touches, with: event)
        self.state = .ended
    }
}
