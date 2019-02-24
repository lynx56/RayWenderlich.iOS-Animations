//
//  ClassicGradient.swift
//  SlideToReveal
//
//  Created by lynx on 24/02/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit
import QuartzCore

struct ClassicGradient: GradientProvider {
    func makeLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        let colors: [UIColor] = [.black, .white, .black]
        gradientLayer.colors = colors.map { $0.cgColor }
        let locations: [NSNumber] = [0.25, 0.5, 0.75]
        gradientLayer.locations = locations
        return gradientLayer
    }
    
    func makeAnimation() -> CABasicAnimation {
        return CABasicAnimation.makeMovingGradient(from: [0, 0, 0.25],
                                                   to: [0.75, 1, 1],
                                                   duration: 3)
    }
}
