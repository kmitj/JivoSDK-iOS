//
//  Building.swift
//  JMImageLoader
//
//  Created by Anton Karpushko on 03.08.2021.
//

import Foundation

protocol Building {
    associatedtype BuildingType
    
    func build() -> BuildingType
}
