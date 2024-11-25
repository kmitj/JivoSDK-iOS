//
//  ImageLoadingStrategyFactory.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 03.08.2021.
//

import Foundation

enum ImageLoadingStrategyFactory {
    case `default`(withImageCacheMemoryLimit: Int)
    
    static func defaultShared(withImageCacheMemoryLimit imageCacheMemoryLimit: Int) -> JMImageLoading {
        return defaultShared.flatMap { $0 }
            ?? buildDefault(withImageCacheMemoryLimit: imageCacheMemoryLimit)
    }
}

extension ImageLoadingStrategyFactory {
    private static var defaultShared: JMImageLoading? = nil
    
    private static func buildDefault(withImageCacheMemoryLimit imageCacheMemoryLimit: Int) -> JMImageLoadingDefaultStrategy {
        let imageCacheConfig = JMImageCache.Config(memoryLimit: imageCacheMemoryLimit)
        let imageCache = JMImageCache(config: imageCacheConfig)
        
        let webImageLoader = JMWebImageLoader()
        let imageCacheLoader = JMImageCacheLoader(nextLoader: webImageLoader, cache: imageCache)
        
        let logger = Logger(loggingLevel: .silent)
        
        let imageLoadingDefaultStrategy = JMImageLoadingDefaultStrategy(cache: imageCache, cacheLoader: imageCacheLoader, webLoader: webImageLoader, logger: logger)
        defaultShared = imageLoadingDefaultStrategy
        
        return imageLoadingDefaultStrategy
    }
}

extension ImageLoadingStrategyFactory: Building {
    func build() -> JMImageLoading {
        switch self {
        case let .default(imageCacheMemoryLimit):
            return ImageLoadingStrategyFactory.buildDefault(withImageCacheMemoryLimit: imageCacheMemoryLimit)
        }
    }
}
