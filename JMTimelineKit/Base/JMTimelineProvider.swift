//
//  JMTimelineProvider.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public enum JMTimelineMediaMetaResult {
    case accessDenied(description: String? = nil)
    case metaIsNotNeeded(description: String? = nil)
    case unknownError(description: String? = nil)
    case meta(fileName: String? = nil)
}

public protocol JMTimelineProvider: AnyObject {
    func formattedDateForGroupHeader(_ date: Date) -> String
    func formattedDateForMessageEvent(_ date: Date) -> String
    func formattedTimeForPlayback(_ timestamp: TimeInterval) -> String
    func formattedPhoneNumber(_ phone: String) -> String
    func retrieveMeta(forFileWithURL fileURL: URL, completion: @escaping (JMTimelineMediaMetaResult) -> Void)
}
