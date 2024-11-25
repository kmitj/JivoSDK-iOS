//
//  PopupPresenterBridgeMock.swift
//  App
//
//  Created by Stan Potemkin on 08.03.2023.
//  Copyright © 2023 JivoSite. All rights reserved.
//

import Foundation
import UIKit

class PopupPresenterBridgeMock: IPopupPresenterBridge {
    func displayFlexibleMenu(within container: PopupPresenterDisplayContainer, source: FlexibleMenuTriggerButton?, items: [PopupPresenterFlexibleMenuItem]) {
        
    }
    
    func attachFlexibleMenu(to button: FlexibleMenuTriggerButton, items: [PopupPresenterFlexibleMenuItem]) {
        
    }
    
    func detachFlexibleMenu(from button: UIButton) {
        
    }
    
    func share(within container: PopupPresenterDisplayContainer, items: [Any], performCleanup: Bool) {
        
    }
    
    var informableContainer: PopupInformingContainer {
        fatalError()
    }
    
    func take(window: UIWindow?) {
        fatalError()
    }
    
    func displayAlert(within container: PopupPresenterDisplayContainer, title: String?, message: String?, items: [PopupPresenterItem]) {
        fatalError()
    }
    
    func displayMenu(within container: PopupPresenterDisplayContainer, anchor: UIView?, title: String?, message: String?, items: [PopupPresenterItem]) {
        fatalError()
    }
    
    func informShortly(message: String) {
        fatalError()
    }
    
    func informShortly(message: String?, icon: UIImage?, options: PopupPresenterShortlyOptions) {
        fatalError()
    }
    
    func attachMenu(to button: UIButton, location: PopupPresenterMenuLocation, items: [PopupPresenterItem]) {
        fatalError()
    }
    
    func detachMenu(from button: UIButton) {
        fatalError()
    }
    
    func attachMenu(to barButtonItem: UIBarButtonItem, location: PopupPresenterMenuLocation, items: [PopupPresenterItem]) -> UIBarButtonItem {
        fatalError()
    }
    
    func detachMenu(from barButtonItem: UIBarButtonItem) {
        fatalError()
    }
}
