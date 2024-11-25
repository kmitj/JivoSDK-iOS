//
//  JMImageCaching.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 31.07.2021.
//

import UIKit

public protocol JMImageCaching {
    subscript(_ url: URL) -> UIImage? { get set }
    
    func removeImage(by url: URL)
    func removeAllImages()
}
