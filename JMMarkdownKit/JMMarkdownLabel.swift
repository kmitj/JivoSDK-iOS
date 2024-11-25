//
//  JMMarkdownLabel.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 27/06/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//


import Foundation
import UIKit

public enum JMMarkdownParserPurpose {
    case render
    case interact
}

public enum JMMarkdownContent {
    case caption(String)
    case rich(NSAttributedString)
    case attachment(JMMarkdownImageAttachment)
}

public enum JMMarkdownURLInteraction {
    case shortTap
    case longPress
}

open class JMMarkdownLabel: UIView {
    public typealias ParserProvider = (JMMarkdownParserPurpose) -> JMMarkdownParser

    public var urlHandler: ((URL, JMMarkdownURLInteraction) -> Void)?
    
    private var parserProvider: ParserProvider?
    private var renderingParser: JMMarkdownParser?
    private let renderingLabel = UITextView()
    
    private var suffixLabel: UILabel?
    private var suffixGap = CGFloat(0)
    
    private var contents = [JMMarkdownContent]()
    private var interactable: Bool = true
    private var longPressGesture = UILongPressGestureRecognizer()

    public init(provider: ParserProvider?) {
        self.parserProvider = provider
        
        super.init(frame: .zero)

        preconfigureParser()

        renderingLabel.backgroundColor = UIColor.clear
        renderingLabel.textColor = nil
        renderingLabel.textAlignment = .left
        renderingLabel.translatesAutoresizingMaskIntoConstraints = true
        renderingLabel.textContainerInset = .zero
        renderingLabel.textContainer.lineFragmentPadding = 0
        renderingLabel.isScrollEnabled = false
        renderingLabel.showsVerticalScrollIndicator = false
        renderingLabel.showsHorizontalScrollIndicator = false
        renderingLabel.isEditable = false
        renderingLabel.isSelectable = false
        renderingLabel.dataDetectorTypes = []
        addSubview(renderingLabel)
        
        isUserInteractionEnabled = true
        
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
        
        longPressGesture.addTarget(self, action: #selector(handleLongPress))
        addGestureRecognizer(longPressGesture)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var backgroundColor: UIColor? {
        get { return renderingLabel.backgroundColor }
        set { renderingLabel.backgroundColor = newValue }
    }
    
    public var textColor: UIColor? {
        get { return renderingLabel.textColor }
        set { renderingLabel.textColor = newValue }
    }
    
    public var linkColor: UIColor? {
        get { return renderingLabel.linkTextAttributes?[.foregroundColor] as? UIColor }
        set { renderingLabel.linkTextAttributes = [.foregroundColor: newValue ?? .blue] }
    }
    
    public var font: UIFont! {
        get { return renderingLabel.font }
        set { renderingLabel.font = newValue }
    }
    
    public var numberOfLines: Int {
        get { return renderingLabel.textContainer.maximumNumberOfLines }
        set { renderingLabel.textContainer.maximumNumberOfLines = newValue }
    }
    
    public var lineBreakMode: NSLineBreakMode {
        get { return renderingLabel.textContainer.lineBreakMode }
        set { renderingLabel.textContainer.lineBreakMode = newValue }
    }

    public var textAlignment: NSTextAlignment {
        get { return renderingLabel.textAlignment }
        set { renderingLabel.textAlignment = newValue }
    }
    
    private var resolvedExclusionPaths = [UIBezierPath]()
    public var exclusionPaths = [UIBezierPath]() {
        didSet { applyExclusion(width: bounds.width) }
    }
    
    public var isInteractive: Bool = false
    
    public var enableLongPress: Bool {
        get { longPressGesture.isEnabled }
        set { longPressGesture.isEnabled = newValue }
    }
    
    public func updateParser(_ provider: @escaping ParserProvider) {
        parserProvider = provider
        preconfigureParser()

        textColor = renderingParser?.fontColor
        font = renderingParser?.font
        setContents(contents)
    }
    
    public func setContents(_ contents: [JMMarkdownContent]) {
        self.contents = contents
    }
    
    public func setContents(_ contents: JMMarkdownContent...) {
        setContents(contents)
    }
    
    public func setText(_ markup: String) {
        setContents(.caption(markup))
    }
    
    private var suffixExclusionPath: UIBezierPath?
    public func setSuffix(_ suffix: JMMarkdownContent?, gap: CGFloat) {
        if let suffix = suffix {
            let label = suffixLabel ?? UILabel()
            suffixLabel = label
            suffixGap = gap
            
            if let parser = renderingParser {
                label.attributedText = resolveString(parser: parser, contents: [suffix])
            }
            else {
                label.attributedText = NSAttributedString()
            }
            
            if label.isDescendant(of: self) {
                setNeedsLayout()
            }
            else {
                addSubview(label)
            }
        }
        else {
            suffixLabel?.removeFromSuperview()
            suffixLabel = nil
        }
    }
    
    public func render() {
        if let parser = renderingParser {
            renderingLabel.attributedText = resolveString(parser: parser, contents: contents)
        }
        else {
            renderingLabel.attributedText = NSAttributedString()
        }
    }
    
    func obtainInteractiveLabel() -> UITextView? {
        if isInteractive, let parser = parserProvider?(.interact) {
            let label = UITextView()
            label.frame = renderingLabel.bounds
            label.backgroundColor = .white
            label.font = renderingLabel.font
            label.textContainerInset = .zero
            label.textContainer.lineBreakMode = renderingLabel.textContainer.lineBreakMode
            label.textContainer.lineFragmentPadding = renderingLabel.textContainer.lineFragmentPadding
            label.textContainer.maximumNumberOfLines = renderingLabel.textContainer.maximumNumberOfLines
            label.textContainer.exclusionPaths = renderingLabel.textContainer.exclusionPaths
            label.isScrollEnabled = false
            label.isEditable = false
            label.isSelectable = false
            label.isHidden = true
            label.attributedText = resolveString(parser: parser, contents: contents)
            
            label.setNeedsLayout()
            label.layoutIfNeeded()
            
            interactable = true
            for content in contents {
                guard case .caption(let caption) = content else { continue }
                for value in parser.scan(caption) {
                    guard value.type == .overpaint else { continue }
                    interactable = false
                    break
                }
            }
            
            return label
        }
        else {
            interactable = false
            
            return nil
        }
    }
    
    public func calculateSize(for width: CGFloat, numberOfLines: Int?, exclusionPaths: [UIBezierPath]? = nil) -> CGSize {
        if width > 0 {
            let size = renderingLabel.calculateSize(
                for: width,
                numberOfLines: numberOfLines ?? self.numberOfLines,
                exclusionPaths: exclusionPaths ?? renderingLabel.textContainer.exclusionPaths
            )
            
            if let exclusionX = suffixExclusionPath?.bounds.maxX {
                return CGSize(
                    width: max(exclusionX, size.width),
                    height: size.height
                )
            }
            else {
                return size
            }
        }
        else {
            let size = renderingLabel.calculateSize(
                for: .infinity,
                numberOfLines: numberOfLines ?? self.numberOfLines,
                exclusionPaths: exclusionPaths ?? renderingLabel.textContainer.exclusionPaths
            )
            
            let suffixSize = calculateSuffixSize()
            if suffixSize.width > 0 {
                return CGSize(
                    width: size.width + suffixSize.width,
                    height: max(size.height, suffixSize.height)
                )
            }
            else {
                return size
            }
        }
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        syncSuffixStyle()
        applyExclusion(width: size.width)
        
        return calculateSize(
            for: size.width,
            numberOfLines: numberOfLines,
            exclusionPaths: resolvedExclusionPaths
        )
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        syncSuffixStyle()
        applyExclusion(width: bounds.width)

        let renderingSize: CGSize
        switch textAlignment {
        case .left, .natural:
            let size = renderingLabel.calculateSize(
                for: bounds.width,
                numberOfLines: numberOfLines,
                exclusionPaths: resolvedExclusionPaths
            )
            
            // Just one additional pixel for height
            // to fix the last line rendering
            renderingSize = CGSize(width: size.width, height: size.height + 1)

        case .center:
            renderingSize = bounds.size

        default:
            renderingSize = bounds.size
        }
        
        renderingLabel.frame = CGRect(
            origin: .zero,
            size: renderingSize
        )
        
        if let exclusionPath = suffixExclusionPath {
            let leftX = min(
                exclusionPath.bounds.minX,
                renderingSize.width
            )

            suffixLabel?.frame = CGRect(
                origin: CGPoint(x: leftX + suffixGap, y: 0),
                size: exclusionPath.bounds.size
            )
        }
    }

    private func syncSuffixStyle() {
        suffixLabel?.textColor = renderingLabel.textColor
        suffixLabel?.font = renderingLabel.font
        suffixLabel?.textAlignment = renderingLabel.textAlignment
    }
    
    private func calculateSuffixSize() -> CGSize {
        guard let label = suffixLabel else { return .zero }
        guard let text = label.text, !text.isEmpty else { return .zero }
        
        let size = label.sizeThatFits(.zero)
        return CGSize(width: suffixGap + size.width, height: size.height)
    }
    
    private func applyExclusion(width: CGFloat) {
        let suffixSize = calculateSuffixSize()
        
        if width == 0 {
            suffixExclusionPath = nil
            resolvedExclusionPaths = exclusionPaths
        }
        else if suffixSize.width == 0 {
            suffixExclusionPath = nil
            resolvedExclusionPaths = exclusionPaths
        }
        else {
            let baseRect = bounds.divided(atDistance: suffixSize.width, from: .maxXEdge).slice
            
            if exclusionPaths.isEmpty {
                let exclusionPath = UIBezierPath(rect: baseRect)

                suffixExclusionPath = exclusionPath
                resolvedExclusionPaths = [exclusionPath]
            }
            else if let firstOriginal = exclusionPaths.first {
                let offset = bounds.width - firstOriginal.cgPath.boundingBoxOfPath.minX
                let rect = baseRect.offsetBy(dx: -offset, dy: 0)
                let exclusionPath = UIBezierPath(rect: rect)
                
                suffixExclusionPath = exclusionPath
                resolvedExclusionPaths = [exclusionPath] + exclusionPaths
            }
            else {
                suffixExclusionPath = nil
                resolvedExclusionPaths = exclusionPaths
            }
        }
        
        renderingLabel.textContainer.exclusionPaths = resolvedExclusionPaths
    }

    private func preconfigureParser() {
        guard let parser = parserProvider?(.render) else { return }
        renderingParser = parser

        parser.autoLinkElement.linksEnabled = false
        parser.emailElement.linksEnabled = false
        parser.phoneElement.linksEnabled = false
    }
    
    private func resolveString(parser: JMMarkdownParser, contents: [JMMarkdownContent]) -> NSAttributedString {
        let string = NSMutableAttributedString()
        
        for content in contents {
            switch content {
            case .caption(let caption):
                string.append(adjustAttributes(parser.parse(caption)))
            case .rich(let rich):
                string.append(rich)
            case .attachment(let attachment):
                string.append(NSAttributedString(attachment: attachment))
            }
        }
        
        return string
    }
    
    private func adjustAttributes(_ string: NSAttributedString) -> NSAttributedString {
        guard string.length > 0 else { return string }
        
        let style: NSMutableParagraphStyle
        if let existingAttribute = string.attribute(.paragraphStyle, at: 0, effectiveRange: nil) {
            if let existingStyle = existingAttribute as? NSParagraphStyle {
                if let copiedStyle = existingStyle.mutableCopy() as? NSMutableParagraphStyle {
                    style = copiedStyle
                }
                else {
                    style = NSMutableParagraphStyle()
                }
            }
            else {
                style = NSMutableParagraphStyle()
            }
        }
        else {
            style = NSMutableParagraphStyle()
        }
        
        style.alignment = textAlignment
//        style.lineBreakMode = lineBreakMode
        
        let adjustedString = NSMutableAttributedString(attributedString: string)
        adjustedString.addAttributes(
            [.paragraphStyle: style],
            range: NSMakeRange(0, adjustedString.length)
        )
        
        if let color = textColor {
            let fullRange = NSMakeRange(0, adjustedString.length)
            var lastIndex = 0
            
            adjustedString.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { value, range, _ in
                defer { lastIndex = range.upperBound }
                if range.lowerBound > lastIndex {
                    let range = NSMakeRange(lastIndex, range.lowerBound - lastIndex)
                    adjustedString.addAttribute(.foregroundColor, value: color, range: range)
                }
            }
            
            let range = NSMakeRange(lastIndex, adjustedString.length - lastIndex)
            adjustedString.addAttribute(.foregroundColor, value: color, range: range)
        }
        
        if let font = font {
            let fullRange = NSMakeRange(0, adjustedString.length)
            var lastIndex = 0
            
            adjustedString.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
                defer { lastIndex = range.upperBound }
                if range.lowerBound > lastIndex {
                    let range = NSMakeRange(lastIndex, range.lowerBound - lastIndex)
                    adjustedString.addAttribute(.font, value: font, range: range)
                }
            }
            
            let range = NSMakeRange(lastIndex, adjustedString.length - lastIndex)
            adjustedString.addAttribute(.font, value: font, range: range)
        }
        
        return adjustedString
    }
    
    public func retrieveURL(gesture: UIGestureRecognizer) -> URL? {
        guard let label = obtainInteractiveLabel() else { return nil }
        guard interactable else { return nil }
        guard let attributedText = label.attributedText else { return nil }
        
        let textContainer = label.textContainer
        let layoutManager = label.layoutManager
        
        let location = gesture.location(in: self)
        let indexOfCharacter = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        guard indexOfCharacter < attributedText.string.count else { return nil }
        return attributedText.attribute(.link, at: indexOfCharacter, effectiveRange: nil) as? URL
    }
    
    @objc public func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let url = retrieveURL(gesture: gesture) else { return }
        
        if let handler = urlHandler {
            handler(url, .shortTap)
        }
        else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc public func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let url = retrieveURL(gesture: gesture) else { return }
        
        if let handler = urlHandler {
            handler(url, .longPress)
        }
        else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
