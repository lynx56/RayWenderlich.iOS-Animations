//
//  PsychedelecGradient.swift
//  SlideToReveal
//
//  Created by lynx on 24/02/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit

struct PsychedelicGradient: GradientProvider {
    func makeLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        let colors: [UIColor] = [.yellow, .green, .orange, .cyan, .red, .yellow]
        gradientLayer.colors = colors.map { $0.cgColor }
        let locations: [NSNumber] = [0.05, 0.1, 0.25, 0.5, 0.75, 1]
        gradientLayer.locations = locations
        return gradientLayer
    }
    
    func makeAnimation() -> CABasicAnimation {
        return CABasicAnimation.makeMovingGradient(from: [0, 0, 0, 0, 0, 0.25],
                                                   to: [0.65, 0.8, 0.85, 0.9, 0.95, 1],
                                                   duration: 3)
    }
}
