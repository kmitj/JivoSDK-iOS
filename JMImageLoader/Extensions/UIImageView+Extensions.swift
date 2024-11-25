//
//  UIImageView+Extensions.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 03.08.2021.
//

import UIKit

extension UIImageView: JMImageViewImageLoading {
    @discardableResult
    public func jmLoadImage(with url: URL, completion: ((Result<UIImage, Error>) -> Void)? = nil) -> JMImageLoadingCancellable {
        let defaultLoadingStrategy = ImageLoadingStrategyFactory.defaultShared(withImageCacheMemoryLimit: 1024 * 1024 * 50)
        return jmLoadImage(with: url, usingStrategy: defaultLoadingStrategy, completion: completion)
    }
    
    @discardableResult
    public func jmLoadImage(with url: URL, usingStrategy loadingStrategy: JMImageLoading, completion: ((Result<UIImage, Error>) -> Void)? = nil) -> JMImageLoadingCancellable {
        let indicator = retrieveIndicator()
        indicator.isHidden = false
        indicator.startAnimating()
        
        let task = loadingStrategy.load(with: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(image) where image.size == .zero:
                    break
                case let .success(image):
                    self?.image = image
                case .failure:
                    break
                }
                
                indicator.stopAnimating()
                indicator.isHidden = true

                completion?(result)
            }
        }
        
        return task
    }
    
    private func retrieveIndicator() -> UIActivityIndicatorView {
        let activityTag = 0xF180
        
        if let control = viewWithTag(activityTag) as? UIActivityIndicatorView {
            return control
        }
        else {
            let control = UIActivityIndicatorView()
            insertSubview(control, at: 0)
            
            if #available(iOS 13.0, *) {
                control.style = .medium
            }
            else {
                control.style = .white
            }
            
            control.frame = bounds
            control.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            control.tag = activityTag
            control.startAnimating()

            return control
        }
    }
}
