//
//  JMTimelinePayloadItem.swift
//  JMTimelineKit
//
//  Created by Stan Potemkin on 16.12.2021.
//

import Foundation

open class JMTimelinePayloadItem<Payload>: JMTimelineItem {
    public let payload: Payload
    
    public init(
        uid: String,
        date: Date,
        layoutValues: JMTimelineItemLayoutValues,
        logicOptions: JMTimelineLogicOptions,
        extraActions: JMTimelineExtraActions,
        payload: Payload
    ) {
        self.payload = payload
        
        super.init(
            uid: uid,
            date: date,
            layoutValues: layoutValues,
            logicOptions: logicOptions,
            extraActions: extraActions
        )
    }
}
