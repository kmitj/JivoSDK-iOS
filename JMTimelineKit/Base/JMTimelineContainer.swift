//
//  JMTimelineContainer.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public final class JMTimelineContainer: UIView {
    let canvas: JMTimelineCanvas
    
    private var layoutValues: JMTimelineItemLayoutValues!
    private var layoutOptions: JMTimelineLayoutOptions!

    public init(canvas: JMTimelineCanvas) {
        self.canvas = canvas
        
        super.init(frame: .zero)
        
        addSubview(canvas)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(item: JMTimelineItem) {
        layoutValues = item.layoutValues
        layoutOptions = item.layoutOptions

        canvas.configure(item: item)
//        content.apply(style: style.contentStyle)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        canvas.frame = layout.canvasFrame
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            canvas: canvas,
            layoutValues: layoutValues,
            layoutOptions: layoutOptions
        )
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let canvas: JMTimelineCanvas
    let layoutValues: JMTimelineItemLayoutValues
    let layoutOptions: JMTimelineLayoutOptions

    var canvasFrame: CGRect {
        let width = bounds.reduceBy(insets: layoutValues.margins).width
        let height = canvas.size(for: width).height
        let leftX = layoutValues.margins.left
        return CGRect(x: leftX, y: calculatedTopMargin, width: width, height: height)
    }
    
    var totalSize: CGSize {
        let frame = canvasFrame
        
        if frame.isEmpty {
            return CGSize(width: bounds.width, height: 0)
        }
        else {
            let height = frame.maxY + calculatedBottomMargin
            return CGSize(width: bounds.width, height: height)
        }
    }
    
    private var calculatedTopMargin: CGFloat {
        let multiplier = layoutOptions.contains(.groupTopMargin) ? 1.0 : layoutValues.groupingCoef
        return layoutValues.margins.top * CGFloat(multiplier)
    }
    
    private var calculatedBottomMargin: CGFloat {
        let multiplier = layoutOptions.contains(.groupBottomMargin) ? 1.0 : layoutValues.groupingCoef
        return layoutValues.margins.bottom * CGFloat(multiplier)
    }
}
