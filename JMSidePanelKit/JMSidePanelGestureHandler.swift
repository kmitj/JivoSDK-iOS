//
// Created by Stan Potemkin on 01/11/2018.
// Copyright (c) 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

final class JMSidePanelGestureHandler {
    private let distance: CGFloat
    private let forward: Bool

    private let disclosingCoef = CGFloat(0.25)

    init(forwardDistance: CGFloat) {
        distance = forwardDistance
        forward = true
    }

    init(backwardDistance: CGFloat) {
        distance = backwardDistance
        forward = false
    }

    func movePercent(for gestureMove: CGFloat) -> CGFloat {
        let isDistancePositive = (distance > 0)
        let isGesturePositive = (gestureMove > 0)

        let percent: CGFloat
        if isDistancePositive, isGesturePositive {
            percent = min(gestureMove, distance) / distance
        }
        else if !isDistancePositive, !isGesturePositive {
            percent = max(gestureMove, distance) / distance
        }
        else {
            percent = 0
        }

        if forward {
            return percent
        }
        else {
            return 1.0 - percent
        }
    }

    func shouldOpen(for vector: CGPoint, axis: JMSidePanelAxis) -> Bool {
        let move: CGFloat
        switch axis {
        case .horizontal: move = vector.x
        case .vertical: move = vector.y
        }

        if forward {
            return movePercent(for: move) > disclosingCoef
        }
        else {
            return movePercent(for: move) > (1.0 - disclosingCoef)
        }
    }
}
