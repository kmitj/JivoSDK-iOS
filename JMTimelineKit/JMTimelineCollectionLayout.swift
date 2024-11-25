//
//  JMTimelineCollectionLayout.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 06/08/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

final class JMTimelineCollectionLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionFootersPinToVisibleBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)?.compactMap(adjustAttributes)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath).flatMap(adjustAttributes)
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath).flatMap(adjustAttributes)
    }
    
    private func adjustAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let copiedAttributes = attributes.copy() as? UICollectionViewLayoutAttributes
        copiedAttributes?.transform = .invertedVertically
        return copiedAttributes ?? attributes
    }
}
