//
//  JMTimelineFactory.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 01/10/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTCollectionViewManager

open class JMTimelineFactory {
    public init() {
    }
    
    open func register(manager: DTCollectionViewManager, providers: JMTimelineDataSourceProviders) {
    }
    
    open func generateItem(for date: Date) -> JMTimelineItem {
        abort()
    }
    
    open func generateCanvas(for item: JMTimelineItem) -> JMTimelineCanvas {
        abort()
    }
}

