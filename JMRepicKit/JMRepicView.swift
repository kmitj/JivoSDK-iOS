//
//  JMRepicView.swift
//  JMRepicView
//
//  Created by Stan Potemkin on 23/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

open class JMRepicView: UIView {
    private let config: JMRepicConfig
    private var items: [JMRepicItem]
    
    private var itemViews = [JMRepicItemView]()
    private var indicator: JMRepicIndicator?
    private var activeLayoutsItems = [JMRepicLayoutItem]()
    private var previousItemsLinks: Set<String?>? = nil
    
    public init(config: JMRepicConfig) {
        self.config = config
        self.items = []
        
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(items: [JMRepicItem]) {
        let currentItemsLinks = Set(items.map { $0.link })
        if currentItemsLinks == previousItemsLinks { return }
        
        self.previousItemsLinks = currentItemsLinks
        self.items = items
        
        if let layoutItems = config.layoutMap[items.count] {
            activeLayoutsItems = layoutItems
        }
        else if items.count > 1, let layoutItems = config.layoutMap[.max] {
            activeLayoutsItems = layoutItems
        }
        else {
            activeLayoutsItems = [JMRepicLayoutItem(position: .zero, radius: 1.0)]
        }

        itemViews.forEach { $0.removeFromSuperview() }
        itemViews = items.map { JMRepicItemView(item: $0, config: config.itemConfig, standalone: (items.count == 1)) }
        itemViews.forEach { addSubview($0) }
    }
    
    public func configure(item: JMRepicItem?) {
        if let item = item {
            configure(items: [item])
        }
        else {
            configure(items: [])
        }
    }
    
    open func setIndicator(fillColor: UIColor, icon: UIImage?, config: JMRepicIndicatorConfig?) {
        if let config = config {
            let internalConfig = JMRepicIndicatorInternalConfig(
                height: self.config.side,
                externalConfig: config
            )
            
            if let indicator = indicator {
                indicator.config = internalConfig
                
                bringSubviewToFront(indicator)
            }
            else {
                let indicator = JMRepicIndicator(config: internalConfig)
                self.indicator = indicator
                
                addSubview(indicator)
            }
            
            indicator?.color = fillColor
            indicator?.icon = icon
        }
        else {
            self.indicator?.removeFromSuperview()
            self.indicator = nil
        }
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: bounds.size)
        return layout.totalSize
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: config.side, height: config.side)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        indicator?.frame = layout.indicatorFrame
        indicator?.layer.cornerRadius = layout.indicatorCornerRadius
        indicator?.layer.zPosition = 1
        zip(itemViews, layout.itemViewsFrames).forEach { $0.frame = $1 }
        
        let hasManyChildren = (itemViews.count > 1)
        let childrenBorderWidth = (hasManyChildren ? config.itemConfig.borderWidthProvider(bounds.width) : 0)
        let childrenBorderColor = (hasManyChildren ? config.itemConfig.borderColor.cgColor : nil)
        for itemView in itemViews {
            itemView.layer.borderWidth = childrenBorderWidth
            itemView.layer.borderColor = childrenBorderColor
        }
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: bounds,
            itemViews: itemViews,
            indicator: indicator,
            config: config,
            layoutItems: activeLayoutsItems
        )
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let itemViews: [JMRepicItemView]
    let indicator: JMRepicIndicator?
    let config: JMRepicConfig
    let layoutItems: [JMRepicLayoutItem]

    var itemViewsFrames: [CGRect] {
        return layoutItems.map { item in
            let width = bounds.width * item.radius
            let height = bounds.height * item.radius
            let leftX = bounds.width * (item.position.x + 0.5) - width * 0.5
            let topY = bounds.height * (item.position.y + 0.5) - height * 0.5
            return CGRect(x: leftX, y: topY, width: width, height: height)
        }
    }
    
    var indicatorFrame: CGRect {
        let centerX = bounds.width * (0.5 + 0.5 * sin(.pi * 0.25))
        let centerY = bounds.height * (0.5 - 0.5 * cos(.pi * 0.25))
        let center = CGPoint(x: centerX, y: centerY)
        let size = indicator?.sizeThatFits(.zero) ?? .zero
        return CGRect(origin: center, size: .zero).insetBy(dx: -size.width * 0.5, dy: -size.height * 0.5)
    }
    
    var indicatorCornerRadius: CGFloat {
        return indicatorFrame.width * 0.5
    }
    
    var totalSize: CGSize {
        return CGSize(width: config.side, height: config.side)
    }
}
