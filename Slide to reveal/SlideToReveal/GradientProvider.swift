//
//  GradientProvider.swift
//  SlideToReveal
//
//  Created by lynx on 24/02/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import QuartzCore

protocol GradientProvider {
    func makeLayer() -> CAGradientLayer
    func makeAnimation() -> CABasicAnimation
}
