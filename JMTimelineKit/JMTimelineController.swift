//
//  JMTimelineController.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 01/10/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTCollectionViewManager

public final class JMTimelineController<Interactor: JMTimelineInteractor>: NSObject, DTCollectionViewManageable, UIScrollViewDelegate {
    public var optionalCollectionView: UICollectionView?
    public var lastItemAppearHandler: (() -> Void)?
    
    public let cache: JMTimelineCache
    public let history: JMTimelineHistory
    
    public let factory: JMTimelineFactory
    private var dataSource: JMTimelineDataSource?
    
    private let maxImageDiskCacheSize: UInt
    
    public init(factory: JMTimelineFactory, cache: JMTimelineCache, maxImageDiskCacheSize: UInt) {
        self.cache = cache
        self.history = JMTimelineHistory(factory: factory, cache: cache)
        self.factory = factory
        
        self.maxImageDiskCacheSize = maxImageDiskCacheSize
        
        super.init()
    }
    
    public func attach(timelineView: JMTimelineView<Interactor>,
                       eventHandler: @escaping (JMTimelineEvent) -> Void) {
        optionalCollectionView = timelineView
        
        let oldStorage = manager.storage
        manager = DTCollectionViewManager()
        manager.storage = oldStorage
//        manager.memoryStorage.defersDatasourceUpdates = true
        
        history.configure(manager: manager)
        history.prepare()
        
        dataSource = JMTimelineDataSource(
            manager: manager,
            history: history,
            cache: cache,
            cellFactory: factory,
            eventHandler: eventHandler
        )
        
        dataSource?.register(in: timelineView)
    }
    
    public func detach(timelineView: JMTimelineView<Interactor>) {
        dataSource?.unregister(from: timelineView)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        (scrollView as? JMTimelineView<Interactor>)?.dismissOwnMenu()
    }
}
