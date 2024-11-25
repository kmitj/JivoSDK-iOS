//
//  JMImageLoading.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 31.07.2021.
//

import UIKit

public protocol JMImageLoadingNode {
    init(nextLoader: JMImageLoadingNode?)
    
    func setNext(node: JMImageLoadingNode)
    func load(with url: URL, completion: @escaping (Result<UIImage, Error>, AnyClass) -> Void)
}
