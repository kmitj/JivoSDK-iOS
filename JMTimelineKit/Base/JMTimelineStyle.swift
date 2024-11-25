//
//  JMTimelineStyle.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

public protocol JMTimelineStyle {
}

public extension JMTimelineStyle {
    func convert<T>(to: T.Type) -> T {
        return self as! T
    }
}

public protocol JMTimelineStylable: class {
    func updateDesign()
}
