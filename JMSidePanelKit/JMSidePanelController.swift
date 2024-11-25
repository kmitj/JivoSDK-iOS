//
//  JMSidePanelController.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 08/09/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public protocol JMSidePanelProtocol: AnyObject {
    var mainViewController: UIViewController? { get set }
    var activePosition: JMSidePanelPosition { get }

    func setEnabled(_ enabled: Bool)
    func allowToFail(recognizer: UIGestureRecognizer)

    func assign(panel: JMSidePanel?, to position: JMSidePanelPosition)
    func open(_ position: JMSidePanelPosition)
    func pull(panel: JMSidePanel, from position: JMSidePanelPosition)
    func expand()
    func collapse()
    func close()
    func close(position: JMSidePanelPosition?)
    func reset(panelID: String?, for position: JMSidePanelPosition)
    
    func presentModal(_ viewController: UIViewController)
    func dismissModal(completion: (() -> Void)?)
}

open class JMSidePanelController: UIViewController, JMSidePanelProtocol, UIGestureRecognizerDelegate {
    fileprivate enum DisplayingMode {
        case none
        case onscreen(JMSidePanelPosition, JMSidePanelDepth, CGFloat)
        case fullscreen(JMSidePanelPosition, JMSidePanelDepth)
    }

    public private(set) var activePosition = JMSidePanelPosition.none
    
    private let presenterViewController = JMSidePanelPresenter()
    private var activePanel: JMSidePanel?
    private var activeViewController: UIViewController?

    private var axis = JMSidePanelAxis.horizontal
    private var openingPercent = CGFloat(0)
    private var expandedOpening = false

    private var dimmingView = UIView()
    private let panGesture = UIPanGestureRecognizer()
    private var gestureHandler: JMSidePanelGestureHandler?
    private weak var parentWindow: UIWindow?

    public init() {
        super.init(nibName: nil, bundle: nil)
        
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = true
        panGesture.cancelsTouchesInView = true
        panGesture.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var mainViewController: UIViewController? {
        willSet {
            dimmingView.removeFromSuperview()
            
            presenterViewController.view.removeFromSuperview()
            presenterViewController.removeFromParent()

            mainViewController?.view.removeFromSuperview()
            mainViewController?.removeFromParent()
        }
        didSet {
            guard let viewController = mainViewController else { return }
            
            addChild(viewController)
            view.addSubview(viewController.view)
            
            addChild(presenterViewController)
            view.addSubview(presenterViewController.view)
            
            view.addSubview(dimmingView)
        }
    }
    
    private var leftPanel: JMSidePanel?
    private var rightPanel: JMSidePanel?
    private var bottomPanel: JMSidePanel?

    public func setEnabled(_ enabled: Bool) {
        panGesture.isEnabled = enabled
    }

    public func allowToFail(recognizer: UIGestureRecognizer) {
        recognizer.require(toFail: panGesture)
    }

    public func assign(panel: JMSidePanel?, to position: JMSidePanelPosition) {
        switch position {
        case .none:
            abort()

        case .left:
            if let currentPanelID = leftPanel?.ID, panel?.ID != currentPanelID {
                close(position: position)
            }

            if let currentPanelID = leftPanel?.ID, panel?.ID == currentPanelID {
                // do nothing
            }
            else {
                leftPanel = panel
            }

        case .right:
            if let currentPanelID = rightPanel?.ID, panel?.ID != currentPanelID {
                close(position: position)
            }

            if let currentPanelID = rightPanel?.ID, panel?.ID == currentPanelID {
                // do nothing
            }
            else {
                rightPanel = panel
            }

        case .bottom:
            if let currentPanelID = bottomPanel?.ID, panel?.ID != currentPanelID {
                close(position: position)
            }

            if let currentPanelID = bottomPanel?.ID, panel?.ID == currentPanelID {
                // do nothing
            }
            else {
                bottomPanel = panel
            }
        }
    }

    public func open(_ position: JMSidePanelPosition) {
        if let panel = panelForPosition(position) {
            pull(panel: panel, from: position)
        }
        else {
            close()
        }
    }

    public func pull(panel: JMSidePanel, from position: JMSidePanelPosition) {
        load(panel: panel, to: position)
        openingPercent = 1.0
        expandedOpening = false
        animateForPanel(panel, completion: nil)
    }
    
    public func expand() {
        guard let panel = activePanel else { return }
        expandedOpening = true
        animateForPanel(panel, completion: nil)
    }

    public func collapse() {
        guard let panel = activePanel else { return }
        expandedOpening = false
        animateForPanel(panel, completion: nil)
    }

    public func close() {
        internalClose(position: nil)
    }

    public func close(position: JMSidePanelPosition?) {
        internalClose(position: position)
    }

    public func reset(panelID: String?, for position: JMSidePanelPosition) {
        if let panelID = panelID, panelForPosition(position)?.ID != panelID {
            return
        }

        assign(panel: nil, to: position)
    }
    
    public func presentModal(_ viewController: UIViewController) {
        mainViewController?.view.isUserInteractionEnabled = false
        presenterViewController.present(viewController, animated: true, completion: nil)
    }
    
    public func dismissModal(completion: (() -> Void)? = nil) {
        mainViewController?.view.isUserInteractionEnabled = true
        presenterViewController.dismiss(animated: true, completion: completion)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        presenterViewController.view.isUserInteractionEnabled = false
        
        let dimGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimTap))
        dimGesture.delaysTouchesBegan = false
        dimGesture.delaysTouchesEnded = false
        dimmingView.addGestureRecognizer(dimGesture)
        
        panGesture.addTarget(self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = getLayout(size: view.bounds.size)
        mainViewController?.view.frame = layout.mainViewControllerFrame
        presenterViewController.view.frame = layout.presenterViewControllerFrame
        activeViewController?.view.frame = layout.activePanelViewFrame
        dimmingView.frame = layout.dimmingViewFrame
        dimmingView.alpha = layout.dimmingViewAlpha
    }
    
    private func getLayout(size: CGSize) -> Layout {
        let displayingMode: DisplayingMode
        if let panel = activePanel {
            switch (activePosition, expandedOpening) {
            case (_, true):
                displayingMode = DisplayingMode.fullscreen(activePosition, panel.depth)

            case (.none, _):
                displayingMode = DisplayingMode.none

            case (.left, _):
                let width = widthForSidePanel(panel: panel, axis: .horizontal, viewController: activeViewController)
                displayingMode = DisplayingMode.onscreen(activePosition, panel.depth, width ?? 0)

            case (.right, _):
                let width = widthForSidePanel(panel: panel, axis: .horizontal, viewController: activeViewController)
                displayingMode = DisplayingMode.onscreen(activePosition, panel.depth, width ?? 0)

            case (.bottom, _):
                let height = heightForSidePanel(panel: panel, axis: .vertical, viewController: activeViewController)
                displayingMode = DisplayingMode.onscreen(activePosition, panel.depth, height ?? 0)
            }
        }
        else {
            displayingMode = DisplayingMode.none
        }

        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            activePanelPosition: activePosition,
            activePanel: activePanel,
            displayingMode: displayingMode,
            openingPercent: openingPercent
        )
    }

    private func load(panel: JMSidePanel?, to position: JMSidePanelPosition) {
        guard let panel = panel else { return }
        guard let viewController = panel.provider() else { return }

        addChild(viewController)
        switch panel.depth {
        case .back: view.insertSubview(viewController.view, at: 0)
        case .front: view.addSubview(viewController.view)
        }
        
        if #available(iOS 11.0, *), let panelView = viewController as? JMSidePanelView {
            panelView.applyExtraInsets(viewController.view.safeAreaInsets)
        }
        
        parentWindow = view.window
        parentWindow?.windowLevel = .statusBar

        activePosition = position
        activePanel = panel
        activeViewController = viewController

        openingPercent = 0
        
        let preLayout = getLayout(size: view.bounds.size)
        mainViewController?.view.frame = preLayout.mainViewControllerFrame
        activeViewController?.view.frame = preLayout.activePanelViewFrame
        dimmingView.frame = preLayout.dimmingViewFrame
        dimmingView.backgroundColor = panel.dimBy
        activeViewController?.view.layoutIfNeeded()

        panel.openHandler?()
    }

    private func panelForPosition(_ position: JMSidePanelPosition) -> JMSidePanel? {
        switch position {
        case .none: return nil
        case .left: return leftPanel
        case .right: return rightPanel
        case .bottom: return bottomPanel
        }
    }

    private func internalClose(position: JMSidePanelPosition?, percent: Float = 1.0) {
        guard position == nil || activePosition == position else { return }

        panGesture.isEnabled = false
        panGesture.isEnabled = true

        if let panel = activePanel {
            openingPercent = 0
            expandedOpening = false

            animateForPanel(panel, percent: percent) { [unowned self] in
                self.activePosition = .none
                self.removePanelView()
            }
        }
    }

    private func removePanelView() {
        activeViewController?.view.removeFromSuperview()
        activeViewController?.removeFromParent()
        activeViewController = nil
        
        parentWindow?.windowLevel = UIWindow.Level.normal

        activePanel?.closeHandler?()
        activePanel = nil
    }
    
    private func widthForSidePanel(panel: JMSidePanel?, axis: JMSidePanelAxis?, viewController: UIViewController?) -> CGFloat? {
        guard let panel = panel else { return nil }
        guard let viewController = viewController else { return nil }
        guard (axis ?? self.axis) == .horizontal else { return nil }
        
        switch panel.size {
        case .value(let value):
            return value
            
        case .percent(let percent):
            return view.bounds.width * percent
            
        case .autosize:
            if let viewController = viewController as? (UIViewController & JMSidePanelView) {
                let size = viewController.preferredSize(for: view.bounds.width)
                return size.width
            }
            else {
                assertionFailure("SidePanel must be an instance of BaseViewController to support .autosize")
                return 0
            }
        }
    }
    
    private func heightForSidePanel(panel: JMSidePanel?, axis: JMSidePanelAxis?, viewController: UIViewController?) -> CGFloat? {
        guard let panel = panel else { return nil }
        guard let viewController = viewController else { return nil }
        guard (axis ?? self.axis) == .vertical else { return nil }

        switch panel.size {
        case .value(let value):
            return value
            
        case .percent(let percent):
            return view.bounds.height * percent
            
        case .autosize(let offset):
            if let viewController = viewController as? (UIViewController & JMSidePanelView) {
                let size = viewController.preferredSize(for: view.bounds.width)
                return min(view.bounds.height - offset, size.height)
            }
            else {
                assertionFailure("SidePanel must be an instance of JMSidePanelView to support .autosize")
                return 0
            }
        }
    }

    private func animateForPanel(_ panel: JMSidePanel, percent: Float = 1.0, completion: (() -> Void)?) {
        mainViewController?.view.setNeedsLayout()
        mainViewController?.view.layoutIfNeeded()

        view.setNeedsLayout()
        UIView.animate(
            withDuration: panel.animation.duration * TimeInterval(percent),
            delay: 0,
            options: panel.animation.curve,
            animations: view.layoutIfNeeded,
            completion: { _ in completion?() }
        )
    }
    
    private func handleGestureBegan(_ gesture: UIPanGestureRecognizer) {
        func _gestureHandler(panel: JMSidePanel,
                             viewController: UIViewController?,
                             isOpening: Bool,
                             reverseDirection: Bool) -> JMSidePanelGestureHandler? {
            if let width = widthForSidePanel(panel: panel, axis: nil, viewController: viewController) {
                let distance = width * (reverseDirection ? 1 : -1)
                
                if isOpening {
                    return JMSidePanelGestureHandler(forwardDistance: distance)
                }
                else {
                    return JMSidePanelGestureHandler(backwardDistance: distance)
                }
            }
            else if let height = heightForSidePanel(panel: panel, axis: nil, viewController: viewController) {
                let distance = height * (reverseDirection ? 1 : -1)
                
                if isOpening {
                    return JMSidePanelGestureHandler(forwardDistance: distance)
                }
                else {
                    return JMSidePanelGestureHandler(backwardDistance: distance)
                }
            }
            else {
                return nil
            }
        }
        
        guard presenterViewController.activeViewController == nil else {
            gesture.cancel()
            return
        }
        
        let point = gesture.location(in: view)
        let move = gesture.translation(in: view)
        let minimalMove = CGFloat(5)
        
        if move.x > minimalMove, activePosition == .none, let menu = leftPanel {
            axis = .horizontal
            
            switch menu.gesture {
            case .none:
                gesture.cancel()
                return

            case .edge(let percent):
                guard point.x < view.bounds.width * percent else { gesture.cancel(); return }

                load(panel: leftPanel, to: .left)

                gestureHandler = _gestureHandler(panel: menu,
                                                 viewController: activeViewController,
                                                 isOpening: true,
                                                 reverseDirection: true)
                openingPercent = gestureHandler?.movePercent(for: move.x) ?? 0
                
                view.setNeedsLayout()
                
            case .full:
                load(panel: leftPanel, to: .left)
                
                gestureHandler = _gestureHandler(panel: menu,
                                                 viewController: activeViewController,
                                                 isOpening: true,
                                                 reverseDirection: true)
                openingPercent = gestureHandler?.movePercent(for: move.x) ?? 0
                
                view.setNeedsLayout()
            }
        }
        else if move.x < -minimalMove, activePosition == .none, let menu = rightPanel {
            axis = .horizontal
            
            switch menu.gesture {
            case .none:
                gesture.cancel()
                return

            case .edge(let percent):
                guard point.x > view.bounds.width * (1.0 - percent) else { gesture.cancel(); return }

                load(panel: rightPanel, to: .right)

                gestureHandler = _gestureHandler(panel: menu,
                                                 viewController: activeViewController,
                                                 isOpening: true,
                                                 reverseDirection: false)
                openingPercent = gestureHandler?.movePercent(for: move.x) ?? 0
                
                view.setNeedsLayout()
                
            case .full:
                load(panel: rightPanel, to: .right)
                
                gestureHandler = _gestureHandler(panel: menu,
                                                 viewController: activeViewController,
                                                 isOpening: true,
                                                 reverseDirection: false)
                openingPercent = gestureHandler?.movePercent(for: move.x) ?? 0
                
                view.setNeedsLayout()
            }
        }
        else if move.x < -minimalMove, activePosition == .left, let menu = leftPanel {
            axis = .horizontal
            
            switch menu.gesture {
            case .none:
                gesture.cancel()
                return

            case .edge:
                if let main = mainViewController?.view {
                    let mainPoint = gesture.location(in: main)
                    if !main.bounds.contains(mainPoint) {
                        gesture.cancel();
                        return
                    }
                }
                else {
                    gesture.cancel()
                    return
                }
                
            case .full:
                guard let leftView = activeViewController?.view else {
                    gesture.cancel()
                    return
                }
                
                guard !gesture.firedInside(view: leftView) else {
                    gesture.cancel()
                    return
                }
            }
            
            gestureHandler = _gestureHandler(panel: menu,
                                             viewController: activeViewController,
                                             isOpening: false,
                                             reverseDirection: false)
            openingPercent = gestureHandler?.movePercent(for: move.x) ?? 0
            
            view.setNeedsLayout()
        }
        else if move.x > minimalMove, activePosition == .right, let menu = rightPanel {
            axis = .horizontal
            
            switch menu.gesture {
            case .none:
                gesture.cancel()
                return

            case .edge:
                if let main = mainViewController?.view {
                    let mainPoint = gesture.location(in: main)
                    if !main.bounds.contains(mainPoint) {
                        gesture.cancel();
                        return
                    }
                }
                else {
                    gesture.cancel()
                    return
                }
                
            case .full:
                guard let rightView = activeViewController?.view else {
                    gesture.cancel()
                    return
                }
                
                guard !gesture.firedInside(view: rightView) else {
                    gesture.cancel()
                    return
                }
            }
            
            gestureHandler = _gestureHandler(panel: menu,
                                             viewController: activeViewController,
                                             isOpening: false,
                                             reverseDirection: true)
            openingPercent = gestureHandler?.movePercent(for: move.x) ?? 0

            view.setNeedsLayout()
        }
        else if move.y < -minimalMove, activePosition == .none {
            if let menu = bottomPanel {
                precondition(menu.gesture == .none)
            }
            
            gesture.cancel()
        }
        else if move.y > minimalMove {
            guard activePosition == .bottom, let panel = bottomPanel else {
                gesture.cancel()
                return
            }
            
            guard let bottomView = activeViewController?.view else {
                gesture.cancel()
                return
            }
            
            guard !gesture.firedInside(view: bottomView) else {
                gesture.cancel()
                return
            }
            
            if panel.gesture == .none {
                gesture.cancel()
                return
            }
            
            axis = .vertical
            
            gestureHandler = _gestureHandler(panel: panel,
                                             viewController: activeViewController,
                                             isOpening: false,
                                             reverseDirection: true)
            openingPercent = gestureHandler?.movePercent(for: move.y) ?? 0

            view.setNeedsLayout()
        }
    }
    
    private func handleGestureChanged(_ gesture: UIPanGestureRecognizer) {
        if let _ = gestureHandler {
            let move = gesture.translation(in: view)
            
            switch axis {
            case .horizontal: openingPercent = gestureHandler?.movePercent(for: move.x) ?? 0
            case .vertical: openingPercent = gestureHandler?.movePercent(for: move.y) ?? 0
            }
        }
        else {
            handleGestureBegan(gesture)
        }
        
        view.setNeedsLayout()
    }
    
    private func handleGestureEnded(_ gesture: UIPanGestureRecognizer) {
        guard let handler = gestureHandler else { return }
        gestureHandler = nil
        
        let vector = gesture.translation(in: view)
        
        let currentPercent = openingPercent
        openingPercent = handler.shouldOpen(for: vector, axis: axis) ? 1.0 : 0
        let percentToAnimate = abs(openingPercent - currentPercent)

        if openingPercent == 0 {
            expandedOpening = false
        }

        if openingPercent == 0 {
            internalClose(position: nil, percent: Float(percentToAnimate))
        }
        else if let panel = panelForPosition(activePosition) {
            animateForPanel(panel, percent: Float(percentToAnimate), completion: nil)
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began: handleGestureBegan(gesture)
        case .changed: handleGestureChanged(gesture)
        case .ended, .cancelled, .failed: handleGestureEnded(gesture)
        default: break
        }
    }
    
    @objc private func handleDimTap(gesture: UIGestureRecognizer) {
        guard gesture.state == .ended else { return }
        guard activePanel?.exclusive == false else { return }
        close()
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGesture {
            return true
//            if let tableView = otherGestureRecognizer.view as? UITableView {
//                if !tableView.isEditing {
//                    return true
//                }
//
//                switch panGesture.translation(in: tableView).x {
//                case let dx where dx > 0: return (leftPanel?.gesture == JMSidePanelGesture.none)
//                case let dx where dx < 0: return (rightPanel?.gesture == JMSidePanelGesture.none)
//                default: return true
//                }
//            }
//            else {
//                return true
//            }
        }

        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGesture {
            if let textField = otherGestureRecognizer.view as? (UITextInput & UIResponder) {
                return textField.isFirstResponder
            }
            else if let scrollView = otherGestureRecognizer.view as? UIScrollView {
                return (scrollView.contentSize.width > scrollView.bounds.width)
            }
//            else if let tableView = otherGestureRecognizer.view as? UITableView {
//                return tableView.isEditing
//            }
            else {
                return false
            }
        }
        
        return false
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let activePanelPosition: JMSidePanelPosition
    let activePanel: JMSidePanel?
    let displayingMode: JMSidePanelController.DisplayingMode
    let openingPercent: CGFloat
    
    var mainViewControllerFrame: CGRect {
        switch displayingMode {
        case .none:
            return bounds

        case .onscreen(let position, let depth, let side):
            if depth == .front {
                return bounds
            }

            switch position {
            case .none: abort()
            case .left: return bounds.offsetBy(dx: side * openingPercent, dy: 0)
            case .right: return bounds.offsetBy(dx: -side * openingPercent, dy: 0)
            case .bottom: return bounds.offsetBy(dx: 0, dy: -side * openingPercent)
            }

        case .fullscreen(let position, let depth):
            if depth == .front {
                return bounds
            }

            switch position {
            case .none: abort()
            case .left: return bounds.offsetBy(dx: bounds.width, dy: 0)
            case .right: return bounds.offsetBy(dx: -bounds.width, dy: 0)
            case .bottom: return bounds.offsetBy(dx: 0, dy: -bounds.height)
            }
        }
    }
    
    var presenterViewControllerFrame: CGRect {
        return bounds
    }

    var activePanelViewFrame: CGRect {
        switch displayingMode {
        case .none:
            return .zero

        case .onscreen(let position, let depth, let side):
            let base: CGRect
            switch position {
            case .none: return .zero
            case .left: base = CGRect(x: 0, y: 0, width: side, height: bounds.height)
            case .right: base = CGRect(x: bounds.width - side, y: 0, width: side, height: bounds.height)
            case .bottom: base = CGRect(x: 0, y: bounds.height - side, width: bounds.width, height: side)
            }

            if depth == .back {
                return base
            }
            else {
                switch position {
                case .none: return .zero
                case .left: return base.offsetBy(dx: -side + (side * openingPercent), dy: 0)
                case .right: return base.offsetBy(dx: side - (side * openingPercent), dy: 0)
                case .bottom: return base.offsetBy(dx: 0, dy: side - (side * openingPercent))
                }
            }

        case .fullscreen:
            return bounds
        }
    }

    var dimmingViewFrame: CGRect {
        return mainViewControllerFrame
    }
    
    var dimmingViewAlpha: CGFloat {
        if activePanelPosition == .none {
            return 0
        }
        else {
            return openingPercent
        }
    }
}

fileprivate extension UIGestureRecognizer {
    func cancel() {
        isEnabled = false
        isEnabled = true
    }

    func firedInside(view: UIView) -> Bool {
        let point = location(in: view)
        return view.bounds.contains(point)
    }
}
