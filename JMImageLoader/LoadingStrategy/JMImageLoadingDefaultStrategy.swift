//
//  JMImageLoadingDefaultStrategy.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 02.08.2021.
//

import UIKit

class JMImageLoadingDefaultStrategy {
    private var cache: JMImageCaching
    private let cacheLoader: JMImageCacheLoader
    private let webLoader: JMWebImageLoader
    private let logger: Logging
    
    init(cache: JMImageCaching, cacheLoader: JMImageCacheLoader, webLoader: JMWebImageLoader, logger: Logging) {
        self.cache = cache
        self.cacheLoader = cacheLoader
        self.webLoader = webLoader
        self.logger = logger
        
        setUp()
    }
    
    private func setUp() {
        cacheLoader.setNext(node: webLoader)
    }
}

extension JMImageLoadingDefaultStrategy: JMImageLoading {
    func load(with url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> JMImageLoadingCancellable {
        cacheLoader.load(with: url) { [weak self] result, loaderType in
            switch result {
            case let .success(image):
                self?.logger.log("Loaded image from \(String(describing: loaderType))")
                if loaderType == JMWebImageLoader.self {
                    self?.cache[url] = image
                }
                
            case let .failure(error):
                self?.logger.log("Image was not loaded. Error: \(String(describing: error))")
            }
            
            completion(result)
        }
        
        let task = JMDefaultLoadingStrategyTask(webImageLoader: webLoader)
        return task
    }
}
