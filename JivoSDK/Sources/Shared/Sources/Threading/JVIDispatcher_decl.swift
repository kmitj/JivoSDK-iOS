//
//  JVIDispatcher_decl.swift
//  Pods
//
//  Created by Stan Potemkin on 12.04.2023.
//

import Foundation
import UIKit

protocol JVIDispatcher: AnyObject {
    func addOperationNew(_ block: @escaping @Sendable () -> Void)
}

extension OperationQueue: JVIDispatcher {
    func addOperationNew(_ block: @escaping @Sendable () -> Void) {
        self.addOperation(block)
    }
}
