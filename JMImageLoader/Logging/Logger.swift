//
//  Logger.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 03.08.2021.
//

import Foundation

class Logger {
    var loggingLevel: LoggingLevel
    
    init(loggingLevel: LoggingLevel = .full) {
        self.loggingLevel = loggingLevel
    }
}

extension Logger: Logging {
    func log(_ message: String) {
        switch loggingLevel {
        case .full:
            print(message)
            
        case .silent:
            break
        }
    }
}
