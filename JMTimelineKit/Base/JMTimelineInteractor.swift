//
//  JMTimelineInteractor.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

public enum ChatTimelineTap {
    
    case regular
    case long
}

public enum JMTimelineMediaStatus {
    case available
    case accessDenied(String?)
    case unknownError(String?)
}

public protocol JMTimelineInteractor: AnyObject {
    var timelineView: UIView? { get set }
    func systemMessageTap(messageID: String?)
    func prepareForItem(uuid: String)
    func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool
}
