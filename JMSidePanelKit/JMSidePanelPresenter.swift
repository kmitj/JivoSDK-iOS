//
//  JMSidePanelPresenter.swift
//  JMSidePanelController
//
//  Created by Stan Potemkin on 04.09.2019.
//  Copyright © 2019 JivoSite. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum JMViewControllerTransitionMode {
    case replace
    case present
    case dismiss
}

fileprivate struct JMViewControllerTransitionContext {
    let container: UIView
    let oldView: UIView?
    let newView: UIView?
}

final public class JMSidePanelPresenter: UIViewController {
    private(set) var activeViewController: UIViewController?
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    public override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        becomeFirstResponder()
        
        activeViewController = viewControllerToPresent
        view.isUserInteractionEnabled = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        setActiveViewController(viewControllerToPresent, transition: flag ? .present : .replace)
        CATransaction.commit()
    }
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        resignFirstResponder()
        
        activeViewController = nil
        view.isUserInteractionEnabled = false

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        setActiveViewController(nil, transition: flag ? .dismiss : .replace)
        CATransaction.commit()
    }
    
    private func setActiveViewController(_ viewController: UIViewController?, transition: JMViewControllerTransitionMode) {
        guard viewController !== children.last else { return }
        let lastViewController = children.last

        let context = JMViewControllerTransitionContext(
            container: view,
            oldView: lastViewController?.view,
            newView: viewController?.view
        )

        if let viewController = viewController {
            addChild(viewController)
            view.addSubview(viewController.view)
        }

        switch transition {
        case .replace: placeBeforeReplace(context: context)
        case .present: placeBeforePresent(context: context)
        case .dismiss: placeBeforeDismiss(context: context)
        }

        UIView.transition(
            with: view.window ?? view,
            duration: (transition == .replace ? 0 : 0.25),
            options: [],
            animations: { [weak self] in
                switch transition {
                case .replace: self?.animateToReplace(context: context)
                case .present: self?.animateToPresent(context: context)
                case .dismiss: self?.animateToDismiss(context: context)
                }
            },
            completion: { [lastvc = lastViewController] _ in
                lastvc?.view.removeFromSuperview()
                lastvc?.removeFromParent()
            }
        )
    }
    
    private func placeBeforeReplace(context: JMViewControllerTransitionContext) {
        guard let newView = context.newView else { return }
        context.newView?.frame = context.container.bounds
        context.container.bringSubviewToFront(newView)
    }

    private func animateToReplace(context: JMViewControllerTransitionContext) {
    }

    private func placeBeforePresent(context: JMViewControllerTransitionContext) {
        guard let newView = context.newView else { return }
        let offset = context.container.bounds.height
        context.newView?.frame = context.container.bounds.offsetBy(dx: 0, dy: offset)
        context.container.bringSubviewToFront(newView)
    }

    private func animateToPresent(context: JMViewControllerTransitionContext) {
        context.newView?.frame = context.container.bounds
    }

    private func placeBeforeDismiss(context: JMViewControllerTransitionContext) {
        guard let newView = context.newView else { return }
        context.newView?.frame = context.container.bounds
        context.container.sendSubviewToBack(newView)
    }

    private func animateToDismiss(context: JMViewControllerTransitionContext) {
        let offset = context.container.bounds.height
        context.oldView?.frame = context.container.bounds.offsetBy(dx: 0, dy: offset)
    }
}
