//
//  JMImageCache.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 31.07.2021.
//

import UIKit

public class JMImageCache {
    // MARK: Preinitialized private properties
    private let internalCache = NSCache<NSString, UIImage>()
    
    // MARK: Private properties initializing via init
    private let config: Config
    
    // MARK: Init
    public init(config: Config = .default) {
        self.config = config
        
        setUp()
    }
    
    // MARK: Private methods
    // Setting up
    private func setUp() {
        internalCache.totalCostLimit = config.memoryLimit
    }
    
    // Other
    private func insertImage(_ image: UIImage?, with url: URL) {
        guard let image = image else { return removeImage(by: url) }
        internalCache.setObject(image, forKey: NSString(string: url.absoluteString))
    }
    
    private func image(for url: URL) -> UIImage? {
        guard let cachedImage = internalCache.object(forKey: NSString(string: url.absoluteString)) else {
            return nil
        }
        
        return cachedImage
    }
}

// MARK: ImageCaching conformance for JMImageCache

extension JMImageCache: JMImageCaching {
    public subscript(url: URL) -> UIImage? {
        get {
            return image(for: url)
        }
        set {
            insertImage(newValue, with: url)
        }
    }
    
    public func removeImage(by url: URL) {
        internalCache.removeObject(forKey: NSString(string: url.absoluteString))
    }
    
    public func removeAllImages() {
        internalCache.removeAllObjects()
    }
}

// MARK: JMImageCache.Config

extension JMImageCache {
    public struct Config {
        // MARK: Static properties
        private static let DEFAULT_MEMORY_LIMIT = 1024 * 1024 * 50
        
        // MARK: Public properties initializing via init
        let memoryLimit: Int
        
        // MARK: Static properties
        public static let `default` = Config(memoryLimit: DEFAULT_MEMORY_LIMIT)
        
        // MARK: Public init
        public init(memoryLimit: Int) {
            self.memoryLimit = memoryLimit
        }
    }
}
