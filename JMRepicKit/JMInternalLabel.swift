//
//  JMInternalLabel.swift
//  JMComplexAvatarView
//
//  Created by Stan Potemkin on 30.04.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit

final class JMInternalLabel: UILabel {
    init() {
        super.init(frame: .zero)
        
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
