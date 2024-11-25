//
//  UIImageExtensions.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    convenience init?(color: UIColor, size: CGSize? = nil) {
        let renderingSize = size ?? CGSize(width: 3, height: 3)
        
        UIGraphicsBeginImageContext(renderingSize)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: renderingSize))
        
        guard let rendered = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        if let _ = size {
            guard let image = rendered.cgImage else { return nil }
            self.init(cgImage: image)
        }
        else {
            let strethable = rendered.stretchableImage(withLeftCapWidth: 1, topCapHeight: 1)
            guard let image = strethable.cgImage else { return nil }
            self.init(cgImage: image)
        }
    }
}
