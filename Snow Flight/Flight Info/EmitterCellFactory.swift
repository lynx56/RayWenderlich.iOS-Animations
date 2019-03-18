//
//  Factories.swift
//  Snow Scene
//
//  Created by lynx on 17/03/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit

protocol EmitterCellFactory {
    func makeCell() -> CAEmitterCell
}

class CircleFlakeFactory: EmitterCellFactory {
    func makeCell() -> CAEmitterCell {
        return  CAEmitterCell(imageName: "flake.png",
                              behavior: EmitterCellBehavior(
                                birthRate: 50,
                                lifeTime: .init(5.5, range: 1),
                                acceleration: (x: 10, y: 70),
                                velocity: .init(20, range: 200),
                                emission: .init(-.pi, range: .pi*0.5),
                                scale: .init(0.8, range: 0.8, speed: -0.15),
                                alpha: .init(1, range: 0.75, speed: -0.15),
                                spin: nil,
                                color: (UIColor(red: 0.9, green: 1, blue: 1, alpha: 1),
                                        redRange: 0.1,
                                        greenRange: 0.1,
                                        blueRange: 0.1)))
    }
}

class SmallCircleFlakeFactory: EmitterCellFactory {
    func makeCell() -> CAEmitterCell {
        return  CAEmitterCell(imageName: "flake1.png",
                              behavior: EmitterCellBehavior(
                                birthRate: 60,
                                lifeTime: .init(4.5, range: 1),
                                acceleration: (x: 10, y: 70),
                                velocity: .init(10, range: 10),
                                emission: .init(-.pi, range: .pi*0.5),
                                scale: .init(0.8, range: 0.8, speed: -0.1),
                                alpha: .init(1, range: 0.75, speed: -0.15),
                                spin: nil,
                                color: (UIColor(red: 0.9, green: 1, blue: 1, alpha: 1),
                                        redRange: 0,
                                        greenRange: 0,
                                        blueRange: 0)))
    }
}

class ElongatedFlakeFactory: EmitterCellFactory {
    func makeCell() -> CAEmitterCell {
        return  CAEmitterCell(imageName: "flake2.png",
                              behavior: EmitterCellBehavior(
                                birthRate: 50,
                                lifeTime: .init(7.5, range: 1),
                                acceleration: (x: 10, y: 70),
                                velocity: .init(20, range: 200),
                                emission: .init(-.pi, range: .pi*0.5),
                                scale: .init(0.8, range: 0.8, speed: -0.15),
                                alpha: .init(1, range: 0.75, speed: -0.15),
                                spin: nil,
                                color: (UIColor(red: 0.9, green: 1, blue: 1, alpha: 1),
                                        redRange: 0.1,
                                        greenRange: 0.1,
                                        blueRange: 0.1)))
    }
}

class StarFlakeFactory: EmitterCellFactory {
    func makeCell() -> CAEmitterCell {
        return  CAEmitterCell(imageName: "flake3.png",
                              behavior: EmitterCellBehavior(
                                birthRate: 70,
                                lifeTime: .init(2.5, range: 1),
                                acceleration: (x: 10, y: 70),
                                velocity: .init(100, range: 200),
                                emission: .init(-.pi, range: .pi*0.5),
                                scale: .init(0.8, range: 0.8, speed: -0.25),
                                alpha: .init(1, range: 0.75, speed: -0.15),
                                spin: nil,
                                color: (UIColor(red: 0.9, green: 1, blue: 1, alpha: 1),
                                        redRange: 0.1,
                                        greenRange: 0.1,
                                        blueRange: 0.1)))
    }
}

class GossamerFlakeFactory: EmitterCellFactory {
    func makeCell() -> CAEmitterCell {
        return  CAEmitterCell(imageName: "flake4.png",
                              behavior: EmitterCellBehavior(
                                birthRate: 50,
                                lifeTime: .init(7.5, range: 1),
                                acceleration: (x: 10, y: 70),
                                velocity: .init(20, range: 200),
                                emission: .init(-.pi, range: .pi*0.5),
                                scale: .init(0.8, range: 0.8, speed: -0.15),
                                alpha: .init(1, range: 0.75, speed: -0.15),
                                spin: nil,
                                color: (UIColor(red: 0.9, green: 1, blue: 1, alpha: 1),
                                        redRange: 0.1,
                                        greenRange: 0.1,
                                        blueRange: 0.1)))
    }
}


struct EmitterCellBehavior {
    struct Volatile<T> {
        var value: T
        var range: T
        init(_ value: T, range: T) {
            self.value = value
            self.range = range
        }
    }
    
    struct Changable<T> {
        var value: T
        var range: T
        var speed: T
        init(_ value: T, range: T, speed: T) {
            self.value = value
            self.range = range
            self.speed = speed
        }
    }
    
    let birthRate: Float
    let lifeTime: Volatile<Float>
    //Vector
    let acceleration: (x: CGFloat, y: CGFloat)
    let velocity: Volatile<CGFloat>
    let emission: Volatile<CGFloat>
    let scale: Changable<CGFloat>
    let alpha: Changable<Float>
    let spin: Volatile<Measurement<UnitAngle>>?
    let color: (UIColor, redRange: Float, greenRange: Float, blueRange: Float)
}

extension CAEmitterCell {
    convenience init(imageName: String, behavior: EmitterCellBehavior) {
        self.init()
        contents = UIImage(named: imageName)?.cgImage
        birthRate = behavior.birthRate
        lifetime = behavior.lifeTime.value
        lifetimeRange = behavior.lifeTime.range
        yAcceleration = behavior.acceleration.y
        xAcceleration = behavior.acceleration.x
        zAcceleration = -1000
        velocity = behavior.velocity.value
        velocityRange = behavior.velocity.range
        emissionLongitude = behavior.emission.value
        emissionRange = behavior.emission.range
        color = behavior.color.0.cgColor
        redRange = behavior.color.redRange
        greenRange = behavior.color.greenRange
        blueRange = behavior.color.blueRange
        scale = behavior.scale.value
        scaleRange = behavior.scale.range
        scaleSpeed = behavior.scale.speed
        alphaRange = behavior.alpha.range
        alphaSpeed = behavior.alpha.speed
        if let spinBehavior = behavior.spin {
            spin = CGFloat(spinBehavior.value.converted(to: .radians).value)
            spinRange = CGFloat(spinBehavior.range.converted(to: .radians).value)
        }
    }
}
