//
//  UITextViewExtensions.swift
//  JMMarkdown
//
//  Created by Stan Potemkin on 29/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

fileprivate let calculateStorage = NSTextStorage()
fileprivate let calculateContainer = NSTextContainer()
fileprivate let calculateManager = NSLayoutManager()

extension UITextView {
    func calculateSize(for width: CGFloat, numberOfLines: Int?, exclusionPaths: [UIBezierPath] = []) -> CGSize {
        calculateContainer.size = CGSize(width: width, height: .infinity)
        calculateContainer.exclusionPaths = exclusionPaths
        calculateContainer.lineBreakMode = textContainer.lineBreakMode
        calculateContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        calculateContainer.maximumNumberOfLines = numberOfLines ?? textContainer.maximumNumberOfLines
        
        calculateStorage.setAttributedString(attributedText)
        
        let containerIndex = calculateManager.textContainers.endIndex
        calculateManager.addTextContainer(calculateContainer)
        defer { calculateManager.removeTextContainer(at: containerIndex) }
        
        calculateStorage.addLayoutManager(calculateManager)
        defer { calculateStorage.removeLayoutManager(calculateManager) }
        
        calculateManager.glyphRange(for: calculateContainer)
        let rect = calculateManager.usedRect(for: calculateContainer)
        
        let indent = extractIndent(attributedText: attributedText)
        return CGSize(width: indent + rect.width + 1, height: rect.height)
    }

    private func extractIndent(attributedText: NSAttributedString?) -> CGFloat {
        guard let text = attributedText, text.length > 0 else { return 0 }
        guard let style = text.attribute(.paragraphStyle, at: 0, effectiveRange: nil) else { return 0 }
        guard let indent = (style as? NSParagraphStyle)?.firstLineHeadIndent else { return 0 }
        return indent
    }
}
