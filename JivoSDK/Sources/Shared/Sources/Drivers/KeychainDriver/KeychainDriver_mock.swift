//
//  KeychainDriverMock.swift
//  App
//
//  Created by Stan Potemkin on 08.03.2023.
//  Copyright © 2023 JivoSite. All rights reserved.
//

import Foundation
import KeychainSwift
import UIKit

class KeychainDriverMock: IKeychainDriver {
    func scope(_ name: String) -> any IKeychainDriver {
        fatalError()
    }
    
    func clearNamespace(scopePrefix: String) {
        fatalError()
    }
    
    var lastOperationFailure: OSStatus? {
        fatalError()
    }
    
    func retrieveAccessor(forToken token: KeychainToken) -> IKeychainAccessor {
        fatalError()
    }
    
    func migrate(mapping: [(String, KeychainSwiftAccessOptions)]) {
        fatalError()
    }
    
    func clearAll() {
        fatalError()
    }
}
