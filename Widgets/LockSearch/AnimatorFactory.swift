//
//  AnimatorFactory.swift
//  Widgets
//
//  Created by lynx on 10/03/2019.
//  Copyright © 2019 Underplot ltd. All rights reserved.
//

import UIKit

class AnimatorFactory {
  static func scaleUp(view: UIView) -> UIViewPropertyAnimator {
    let scale = UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)
    scale.addAnimations {
      view.alpha = 1
    }
    scale.addAnimations({
      view.transform = .identity
    }, delayFactor: 0.33)
    
    scale.addCompletion { _ in
      print("ready")
    }
    return scale
  }
  
  @discardableResult
  static func jiggle(view: UIView) -> UIViewPropertyAnimator {
    return UIViewPropertyAnimator.runningPropertyAnimator(
      withDuration: 0.33, delay: 0,
      options: .curveLinear,
      animations: {
        UIView.animateKeyframes(withDuration: 1, delay: 0, animations: {
          UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
            view.transform = CGAffineTransform(rotationAngle: -.pi/8)
          })
          UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.75, animations: {
            view.transform = CGAffineTransform(rotationAngle: .pi/8)
          })
          UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 1, animations: {
            view.transform = .identity
          })
        }, completion: nil)
    })
  }
  
  @discardableResult
  static func fade(blurView: UIView, visible: Bool) -> UIViewPropertyAnimator {
    return UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5,
                                                          delay: 0.1,
                                                          options: [.curveEaseOut],
                                                          animations: {
                                                            blurView.alpha = visible ? 1 : 0
    },
                                                          completion: nil)
  }
  
  @discardableResult
  static func animateConstraint(view: UIView, constraint: NSLayoutConstraint, by: CGFloat) -> UIViewPropertyAnimator {
    let spring = UISpringTimingParameters(dampingRatio: 0.2)
    let animator = UIViewPropertyAnimator(duration: 2, timingParameters: spring)
    animator.addAnimations {
      constraint.constant += by
      view.layoutIfNeeded()
    }
    return animator
  }
}
