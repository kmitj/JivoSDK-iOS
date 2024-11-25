//
//  JMTimelineViewUpdater.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 02/10/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage
import DTCollectionViewManager
import SwiftyNSException

final class JMTimelineViewUpdater: CollectionViewUpdater {
    var exceptionHandler: (() -> Void)?
    
    override func storageDidPerformUpdate(_ update: StorageUpdate) {
        do {
            try handle { super.storageDidPerformUpdate(update) }
        }
        catch let exc {
            print("JMTimelineView: exception thrown: \(exc)")
            exceptionHandler?()
        }
    }
}
