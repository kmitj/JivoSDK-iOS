//
//  JMImageViewImageLoading.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 03.08.2021.
//

import UIKit

public protocol JMImageViewImageLoading {
    @discardableResult
    func jmLoadImage(with url: URL, completion: ((Result<UIImage, Error>) -> Void)?) -> JMImageLoadingCancellable
    @discardableResult
    func jmLoadImage(with url: URL, usingStrategy loadingStrategy: JMImageLoading, completion: ((Result<UIImage, Error>) -> Void)?) -> JMImageLoadingCancellable
}

extension JMImageViewImageLoading {
    @discardableResult
    public func jmLoadImage(with url: URL, completion: ((Result<UIImage, Error>) -> Void)? = nil) -> JMImageLoadingCancellable {
        self.jmLoadImage(with: url, completion: completion)
    }
    
    @discardableResult
    public func jmLoadImage(with url: URL, usingStrategy loadingStrategy: JMImageLoading, completion: ((Result<UIImage, Error>) -> Void)? = nil) -> JMImageLoadingCancellable {
        self.jmLoadImage(with: url, usingStrategy: loadingStrategy, completion: completion)
    }
}
