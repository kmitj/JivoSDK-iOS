//
//  JMMarkdownImageAttachment.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 02/07/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMDesignKit

public enum JMMarkdownImageAttachmentSizing {
    case keepInBound
    case scaleToFit
    case centered(UIFont.TextStyle, CGFloat)
    case anchored(UIFont.TextStyle, CGFloat)
    case exact(CGSize)
}

public final class JMMarkdownImageAttachment: NSTextAttachment {
    private let font: UIFont
    private let sizing: JMMarkdownImageAttachmentSizing
    
    public init(font: UIFont, image: UIImage, sizing: JMMarkdownImageAttachmentSizing) {
        self.font = font
        self.sizing = sizing
        
        super.init(data: nil, ofType: nil)
        
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        guard let image = image else { return .zero }
        
        let imageSize = image.size
        let adjustedSize: CGSize
        
        switch sizing {
        case .keepInBound:
            if font.lineHeight < imageSize.height {
                let scale = font.lineHeight / imageSize.height
                adjustedSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
            }
            else {
                adjustedSize = imageSize
            }
            
        case .scaleToFit:
            let scale = font.capHeight / imageSize.height
            adjustedSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
            return CGRect(x: 0, y: 0, width: adjustedSize.width, height: adjustedSize.height)

        case .centered(let style, let multiplier):
            adjustedSize = imageSize.scaled(category: style, multiplier: multiplier)

        case .anchored(let style, let multiplier):
            adjustedSize = imageSize.scaled(category: style, multiplier: multiplier)
            return CGRect(x: 0, y: 0, width: adjustedSize.width, height: adjustedSize.height)
            
        case .exact(let size):
            return CGRect(x: 0, y: font.descender, width: size.width, height: size.height)
        }
        
        let originY = font.descender - (adjustedSize.height - font.lineHeight) * 0.5
        return CGRect(x: 0, y: originY, width: adjustedSize.width, height: adjustedSize.height)
    }
    
    private func scale(size: CGSize, category: UIFont.TextStyle?) -> CGSize {
        guard let category = category else { return size }
        return size.scaled(category: category)
    }
}
