//
//  JMRepicIndicator.swift
//  JMRepicView
//
//  Created by Stan Potemkin on 23/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

struct JMRepicIndicatorInternalConfig {
    let side: CGFloat
    let borderWidth: CGFloat
    let borderColor: UIColor
    let contentMargin: CGFloat
    let contentTintColor: UIColor?

    init(height: CGFloat, externalConfig: JMRepicIndicatorConfig) {
        side = externalConfig.sideProvider(height)
        borderWidth = externalConfig.borderWidthProvider(height)
        borderColor = externalConfig.borderColor
        contentMargin = externalConfig.contentMarginProvider(height)
        contentTintColor = externalConfig.contentTintColor
    }
}

final class JMRepicIndicator: UIView {
    private let innerCircle = UIView()
    private let iconView = UIImageView()

    init(config: JMRepicIndicatorInternalConfig) {
        self.config = config
        
        super.init(frame: .zero)
        
        addSubview(innerCircle)
        
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
        
        adjustWithConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var config: JMRepicIndicatorInternalConfig {
        didSet { adjustWithConfig() }
    }
    
    var color: UIColor? {
        didSet { innerCircle.backgroundColor = color }
    }
    
    var icon: UIImage? {
        didSet { iconView.image = icon }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        layer.cornerRadius = layout.cornerRadius
        innerCircle.frame = layout.innerCircleFrame
        innerCircle.layer.cornerRadius = layout.innerCircleCornerRadius
        iconView.frame = layout.iconViewFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            config: config
        )
    }
    
    private func adjustWithConfig() {
        backgroundColor = config.borderColor
        iconView.tintColor = config.contentTintColor
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let config: JMRepicIndicatorInternalConfig
    
    var cornerRadius: CGFloat {
        return bounds.width * 0.5
    }
    
    var innerCircleFrame: CGRect {
        let margin = config.borderWidth
        return bounds.insetBy(dx: margin, dy: margin)
    }
    
    var innerCircleCornerRadius: CGFloat {
        return innerCircleFrame.width * 0.5
    }
    
    var iconViewFrame: CGRect {
        let delta = config.contentMargin
        return innerCircleFrame.insetBy(dx: delta, dy: delta)
    }
    
    var totalSize: CGSize {
        let side = config.side
        return CGSize(width: side, height: side)
    }
}
