//
//  JMImageCacheLoader.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 02.08.2021.
//

import UIKit

public class JMImageCacheLoader {
    private var nextLoader: JMImageLoadingNode?
    private let cache: JMImageCaching
    
    required convenience public init(nextLoader: JMImageLoadingNode? = nil) {
        let defaultCache = JMImageCache(config: .default)
        self.init(nextLoader: nextLoader, cache: defaultCache)
    }
    
    required public init(nextLoader: JMImageLoadingNode? = nil, cache: JMImageCaching) {
        self.nextLoader = nextLoader
        self.cache = cache
    }
}

extension JMImageCacheLoader: JMImageCacheLoading {
    public func setNext(node: JMImageLoadingNode) {
        nextLoader = node
    }
    
    public func load(with url: URL, completion: @escaping (Result<UIImage, Error>, AnyClass) -> Void) {
        guard let cachedImage = cache[url] else {
            nextLoader.flatMap { $0.load(with: url, completion: completion) } ?? completion(.failure(JMImageCacheLoadingError.notFound), Self.self); return
        }
        
        completion(.success(cachedImage), Self.self)
    }
}
