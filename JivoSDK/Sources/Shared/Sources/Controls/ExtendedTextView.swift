//
//  ExtendedTextView.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 26/02/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

protocol ResponderProxy {
    var isFirstResponder: Bool { get }
    func register(_ responder: UIResponder, for actions: [Selector])
}

final class ExtendedTextView: UIView, UITextViewDelegate, ResponderProxy {
    private let placeholderLabel = UILabel()
    private let textView = InputTextArea()
    
    var limit: Int?
    var startEditingHandler: ((String) -> Void)?
    var textChangeHandler: ((String) -> Void)?
    var heightUpdateHandler: (() -> Void)?
    var finishEditingHandler: ((String) -> Void)?

    init(linesLimit: Int) {
        super.init(frame: .zero)
        
        textView.backgroundColor = UIColor.clear
        textView.textColor = JVDesign.colors.resolve(usage: .primaryForeground)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        textView.inputAccessoryView = UIView()
        addSubview(textView)
        
        placeholderLabel.textColor = JVDesign.colors.resolve(usage: .secondaryForeground).jv_withAlpha(0.45)
        placeholderLabel.numberOfLines = linesLimit
        placeholderLabel.lineBreakMode = (linesLimit == 1 ? .byTruncatingTail : .byWordWrapping)
        addSubview(placeholderLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var font: UIFont? {
        get { return textView.font }
        set { placeholderLabel.font = newValue; textView.font = newValue }
    }
    
    var textContainerInset: UIEdgeInsets {
        get { return textView.textContainerInset }
        set { textView.textContainerInset = newValue }
    }
    
    var contentOffset: CGPoint {
        get { return textView.contentOffset }
        set { textView.contentOffset = newValue }
    }
    
    var placeholder: String? {
        get {
            return placeholderLabel.text
        }
        set {
            guard newValue != placeholderLabel.text else { return }
            placeholderLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    var placeholderOffset: CGPoint = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    var text: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            adjustTextColor()
            
            placeholderLabel.isHidden = textView.hasText
        }
    }
    
    var textColor: UIColor? {
        get { return textView.textColor }
        set { textView.textColor = newValue }
    }
    
    var hasText: Bool {
        return textView.hasText
    }
    
    var isOverLimit: Bool {
        guard let limit = limit else { return false }
        guard let text = text else { return false }
        return (text.count > limit)
    }
    
    var isScrollEnabled: Bool {
        get { return textView.isScrollEnabled }
        set { textView.isScrollEnabled = newValue }
    }
    
    var caretPosition: Int? {
        let beginning = textView.beginningOfDocument
        let end = textView.endOfDocument
        
        if let range = textView.selectedTextRange {
            return textView.offset(from: beginning, to: range.start)
        }
        else {
            return textView.hasText ? textView.offset(from: beginning, to: end) - 1 : nil
        }
    }
    
    func insertAtCaret(symbol: String, replacement: String) {
        guard let content = textView.text else {
            text = replacement
            return
        }
        
        guard let range = textView.selectedTextRange else {
            text = content + symbol + replacement
            return
        }
        
        let searchingRange = NSMakeRange(0, textView.offset(from: textView.beginningOfDocument, to: range.start))
        let foundRange = (content as NSString).range(of: symbol, options: .backwards, range: searchingRange, locale: nil)
        
        guard foundRange.location != NSNotFound else {
            replace(range, withText: symbol + replacement)
            return
        }
        
        guard let startPosition = textView.position(from: textView.beginningOfDocument, offset: foundRange.upperBound) else {
            replace(range, withText: symbol + replacement)
            return
        }
        
        guard let replacingRange = textView.textRange(from: startPosition, to: range.end) else {
            replace(range, withText: symbol + replacement)
            return
        }
        
        if let tail = textView.text(in: replacingRange), tail.jv_containsSymbols(from: .mentioningGap) {
            replace(range, withText: symbol + replacement)
            return
        }
            
        replace(replacingRange, withText: replacement)
    }
    
    override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }
    
    override var canBecomeFirstResponder: Bool {
        return textView.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        get { return textView.inputAccessoryView }
        set { textView.inputAccessoryView = newValue }
    }
    
    func insertText(_ text: String) {
        textView.insertText(text)
        adjustTextColor()
    }
    
    func register(_ responder: UIResponder, for actions: [Selector]) {
//        textView.register(responder, for: actions)
    }
    
    func calculateContentOffset(for maxHeight: CGFloat) -> CGFloat? {
        return textView.jv_calculateContentOffset(for: maxHeight)
    }
    
    func calculateSize(for width: CGFloat, numberOfLines: Int?) -> CGSize {
        return textView.jv_calculateSize(for: width, numberOfLines: numberOfLines)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = bounds
        
        if placeholderOffset == .zero {
            let size = placeholderLabel.jv_calculateSize(forWidth: bounds.width)
            placeholderLabel.frame = CGRect(x: 0, y: (bounds.height - size.height) * 0.5 - 1, width: size.width, height: size.height)
        }
        else {
            let size = placeholderLabel.jv_calculateSize(forWidth: bounds.divided(atDistance: placeholderOffset.x, from: .minXEdge).remainder.width)
            placeholderLabel.frame = CGRect(x: placeholderOffset.x, y: placeholderOffset.y - 1, width: size.width, height: max(bounds.height, size.height))
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let placeholderSize = placeholderLabel.sizeThatFits(size)
        let textViewSize = textView.sizeThatFits(size)
        
        return CGSize(
            width: textViewSize.width,
            height: max(textViewSize.height, placeholderSize.height)
        )
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        startEditingHandler?(textView.text.jv_orEmpty)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.hasText
        
        textChangeHandler?(textView.text.jv_orEmpty)
        
        if textView.jv_calculateSize(for: bounds.width, numberOfLines: nil).height != textView.bounds.height {
            heightUpdateHandler?()
        }
        
        adjustTextColor()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        finishEditingHandler?(textView.text.jv_orEmpty)
    }
    
    private func replace(_ range: UITextRange, withText: String) {
        textView.replace(range, withText: withText)
        adjustTextColor()
    }
    
    private func adjustTextColor() {
        textView.textColor = JVDesign.colors.resolve(usage: isOverLimit ? .warningForeground : .primaryForeground)
    }
}
