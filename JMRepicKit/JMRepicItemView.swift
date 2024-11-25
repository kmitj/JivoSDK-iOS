//
//  JMRepicItemView.swift
//  JMRepicView
//
//  Created by Stan Potemkin on 23/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMImageLoader

final class JMRepicItemView: UIView {
    private let item: JMRepicItem
    private let config: JMRepicItemConfig
    private let standalone: Bool
    
    private let backgroundView = JMInternalImageView()
    private let contentView: UIView
    private let gradientOverlay = CAGradientLayer()

    private var isTransparent = false
    
    init(item: JMRepicItem, config: JMRepicItemConfig, standalone: Bool) {
        self.item = item
        self.config = config
        self.standalone = standalone
        
        switch item.source {
        case .avatar: contentView = JMInternalImageView()
        case .remote: contentView = JMInternalImageView()
        case .named: contentView = JMInternalImageView()
        case .exact: contentView = JMInternalImageView()
        case .caption: contentView = JMInternalLabel()
        case .empty: contentView = UIView()
        }

        super.init(frame: .zero)
        
        backgroundColor = item.backgroundColor ?? config.borderColor

        backgroundView.contentMode = .scaleAspectFill
        addSubview(backgroundView)
        
        gradientOverlay.colors = [UIColor(white: 1.0, alpha: 0.25).cgColor, UIColor.clear.cgColor]
        gradientOverlay.masksToBounds = true
        gradientOverlay.shouldRasterize = true
        gradientOverlay.isHidden = true
        layer.addSublayer(gradientOverlay)
        
        contentView.contentMode = .scaleAspectFill
        addSubview(contentView)
        
        switch item.source {
        case let .avatar(URL, image, color, tp):
            internalLoadAvatar(view: contentView as? JMInternalImageView, URL: URL, image: image, color: color, transparent: tp)
        case let .remote(URL):
            internalLoadRemote(view: contentView as? JMInternalImageView, URL: URL)
        case let .named(name, template):
            internalLoadNamed(view: contentView as? JMInternalImageView, asset: name, template: template)
        case let .exact(image):
            internalLoadExact(view: contentView as? JMInternalImageView, image: image)
        case let .caption(caption, font):
            internalLoadCaption(label: contentView as? UILabel, caption: caption, font: font)
        case .empty:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if standalone {
            backgroundView.frame = bounds
        }
        else {
            let backgroundMargin = config.borderWidthProvider(bounds.width)
            backgroundView.frame = bounds.insetBy(dx: backgroundMargin, dy: backgroundMargin)
        }
        
        gradientOverlay.frame = bounds
        
        let contentInset = (1.0 - item.scale) * 0.5
        contentView.frame = bounds.insetBy(dx: bounds.width * contentInset, dy: bounds.height * contentInset)

        if isTransparent {
            backgroundView.layer.cornerRadius = bounds.width * 0.5
        }
        else {
            backgroundView.layer.cornerRadius = 0
        }
        
        switch item.clipping {
        case .disabled:
            layer.masksToBounds = false
            layer.cornerRadius = 0
            
            backgroundView.layer.masksToBounds = false
            backgroundView.layer.cornerRadius = 0
            
            contentView.layer.masksToBounds = false
            contentView.layer.cornerRadius = 0
            
        case .external:
            layer.masksToBounds = true
            layer.cornerRadius = bounds.height * 0.5
            
            backgroundView.layer.masksToBounds = false
            backgroundView.layer.cornerRadius = 0
            
            contentView.layer.masksToBounds = false
            contentView.layer.cornerRadius = 0

        case .dual:
            layer.masksToBounds = true
            layer.cornerRadius = bounds.height * 0.5
            
            backgroundView.layer.masksToBounds = true
            backgroundView.layer.cornerRadius = backgroundView.frame.width * 0.5
            
            contentView.layer.masksToBounds = true
            contentView.layer.cornerRadius = contentView.frame.width * 0.5
        }
    }
    
    private func internalLoadAvatar(view: JMInternalImageView?, URL: URL?, image: UIImage?, color: UIColor?, transparent: Bool) {
        guard let view = view else { return }
        isTransparent = false

        func _loadMain() {
            if let URL = URL {
                if #available(iOS 11.0, *) {
                    accessibilityIgnoresInvertColors = true
                }
                
                _loadDefault()
                
//                backgroundView.backgroundColor = nil
//                backgroundView.image = nil
//                backgroundView.tintColor = nil
//                backgroundView.contentMode = .scaleAspectFill
//
//                gradientOverlay.isHidden = true
//
//                view.backgroundColor = nil
//                view.image = image
//                view.tintColor = nil
//                view.contentMode = .scaleAspectFill
                
                view.jmLoadImage(with: URL) { result in
//                    switch result {
//                    case .failure: _loadDefault()
//                    default: break
//                    }
                }
                
                if let control = view.viewWithTag(0xF180) {
                    control.isHidden = true
                }
            }
        }
        
        func _loadDefault() {
            if let image = image {
                if #available(iOS 11.0, *) {
                    accessibilityIgnoresInvertColors = false
                }
                
                if let color = color {
                    backgroundView.image = nil
                    backgroundView.tintColor = nil
                    
                    view.backgroundColor = UIColor(white: 1.0, alpha: 0)
                    view.image = image.withRenderingMode(.alwaysTemplate)

                    isTransparent = transparent
                    if transparent {
                        backgroundView.backgroundColor = UIColor.clear
                        backgroundView.layer.borderWidth = 1
                        backgroundView.layer.borderColor = color.cgColor

                        gradientOverlay.isHidden = true

                        view.tintColor = color
                    }
                    else {
                        backgroundView.backgroundColor = color
                        backgroundView.layer.borderWidth = 0
                        backgroundView.layer.borderColor = nil

                        gradientOverlay.isHidden = false

                        view.tintColor = UIColor.white
                    }
                }
                else {
                    backgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0)
                    backgroundView.image = nil
                    
                    gradientOverlay.isHidden = false
                    
                    view.backgroundColor = UIColor(white: 1.0, alpha: 0)
                    view.image = image
                }
            }
        }
        
        func _loadNone() {
            backgroundView.image = nil
            gradientOverlay.isHidden = true
            view.image = nil
        }
        
        if let _ = URL {
            _loadMain()
        }
        else if let _ = image {
            _loadDefault()
        }
        else {
            _loadNone()
        }

        setNeedsLayout()
    }
    
    private func internalLoadRemote(view: JMInternalImageView?, URL: URL) {
        guard let view = view else { return }
        
        view.image = nil
        view.jmLoadImage(with: URL)
        
        gradientOverlay.isHidden = true
    }
    
    private func internalLoadNamed(view: JMInternalImageView?, asset: String, template: Bool) {
        guard let view = view else { return }
        
        view.image = UIImage(named: asset)?.withRenderingMode(template ? .alwaysTemplate : .alwaysOriginal)
        view.contentMode = .scaleAspectFit
        
        gradientOverlay.isHidden = true
    }
    
    private func internalLoadExact(view: JMInternalImageView?, image: UIImage) {
        guard let view = view else { return }
        
        backgroundView.image = image
        backgroundView.contentMode = .scaleAspectFit
        
        gradientOverlay.isHidden = true
        
        view.image = nil
    }
    
    private func internalLoadCaption(label: UILabel?, caption: String, font: UIFont) {
        guard let label = label else { return }
        
        label.text = caption
        label.font = font
        label.adjustsFontSizeToFitWidth = true
        
        gradientOverlay.isHidden = true
    }
}
