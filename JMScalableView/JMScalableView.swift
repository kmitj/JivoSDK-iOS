//
//  JMScalableView.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 07/07/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMDesignKit

final public class JMScalableView: UIView {
    public var category: UIFont.TextStyle?
    public var renderingSize: CGSize?

    private let imageView = UIImageView()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
    }

    public init(image: UIImage?) {
        super.init(frame: .zero)

        imageView.image = image
        addSubview(imageView)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }

    public override var contentMode: ContentMode {
        get { return imageView.contentMode }
        set { imageView.contentMode = newValue }
    }
    
    public override var tintColor: UIColor! {
        get { return imageView.tintColor }
        set { imageView.tintColor = newValue }
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let basicSize = renderingSize ?? imageView.sizeThatFits(size)

        if let category = category {
            return basicSize.scaled(category: category)
        }
        else {
            return basicSize
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = centeredFrame(size: sizeThatFits(bounds.size), inside: bounds.size)
    }

    private func centeredFrame(size: CGSize, inside: CGSize) -> CGRect {
        let x = (inside.width - size.width) * 0.5
        let y = (inside.height - size.height) * 0.5
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
