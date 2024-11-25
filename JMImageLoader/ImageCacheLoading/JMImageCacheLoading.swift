//
//  JMImageCacheLoading.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 02.08.2021.
//

import UIKit

public enum JMImageCacheLoadingError: Error {
    case notFound
}

public protocol JMImageCacheLoading: JMImageLoadingNode {}
