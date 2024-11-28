//
//  JVDispatchThreadMock.swift
//  Pods
//
//  Created by Stan Potemkin on 08.03.2023.
//

import Foundation

open class JVDispatchThreadMock: JVIDispatchThread {
    public init() {
    }
    
    public func async(block: @escaping () -> Void) {
        fatalError()
    }
    
    public func sync(block: @escaping () -> Void) {
        fatalError()
    }
    
    public func addOperationNew(_ block: @escaping () -> Void) {
        fatalError()
    }
    
    public func stop() {
    }
}
