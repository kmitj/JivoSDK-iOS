//
//  JVIDispatcher_decl.swift
//  Pods
//
//  Created by Stan Potemkin on 12.04.2023.
//

import Foundation
import UIKit

protocol JVIDispatcher: AnyObject {
    func addOperation(_ block: @Sendable @escaping () -> Void)
}

extension OperationQueue: JVIDispatcher {
    func addOperation(_ block: @Sendable @escaping () -> Void) {
        
    }
}
