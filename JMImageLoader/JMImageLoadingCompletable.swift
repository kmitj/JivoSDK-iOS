//
//  JMImageLoadingCompletable.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 03.08.2021.
//

import UIKit

// MARK: Not using for now

protocol JMImageLoadingCompletable {
    func onSuccess(_ block: @escaping (UIImage) -> Void)
    func onFailure(_ block: @escaping (Error) -> Void)
}
