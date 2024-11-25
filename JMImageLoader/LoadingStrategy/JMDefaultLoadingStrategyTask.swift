//
//  JMDefaultLoadingStrategyTask.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 03.08.2021.
//

import Foundation

public struct JMDefaultLoadingStrategyTask {
    private let webImageLoader: JMWebImageLoading
    
    public init(webImageLoader: JMWebImageLoading) {
        self.webImageLoader = webImageLoader
    }
}

extension JMDefaultLoadingStrategyTask: JMImageLoadingCancellable {
    public func cancel() {
        webImageLoader.cancelCurrentLoading()
    }
}
