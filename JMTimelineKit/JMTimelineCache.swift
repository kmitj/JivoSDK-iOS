//
//  JMTimelineCache.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public final class JMTimelineCache {
    private var cellSizes = [String: CGSize]()
    private var disabledIDs = Set<String>()
    
    public init() {
    }
    
    public func preventCaching(for messageIDs: Set<String>) {
        disabledIDs = messageIDs
        messageIDs.forEach(resetSize)
    }
    
    public func resetSize(for messageID: String) {
        cellSizes.removeValue(forKey: messageID)
    }
    
    public func resetMessageSizes() {
        cellSizes.removeAll()
    }
    
    internal func cache(messageSize size: CGSize, for messageID: String) {
        guard !disabledIDs.contains(messageID) else { return }
        cellSizes[messageID] = size
    }
    
    internal func size(for messageID: String) -> CGSize? {
        guard !disabledIDs.contains(messageID) else { return nil }
        return cellSizes[messageID]
    }
}
