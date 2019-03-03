//
//  RevealAnimator.swift
//  LogoReveal
//
//  Created by lynx on 03/03/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit

class RevealAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let animationDuartion: TimeInterval = 2
    var operation: UINavigationControllerOperation = .push
    weak var storedContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuartion
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch operation {
        case .push:
            push(using: transitionContext)
        case .pop:
            pop(using: transitionContext)
        case .none:
            assertionFailure("wtf?")
        }
    }
    
    private func push(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? MasterViewController,
            let toVC = transitionContext.viewController(forKey: .to) as? DetailViewController
            else { assertionFailure("Invalid controllers in transition"); return }
        
        storedContext = transitionContext
        transitionContext.containerView.addSubview(toVC.view)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D:
            CATransform3DConcat(CATransform3DMakeTranslation(0, -10, 0),
                                CATransform3DMakeScale(150, 150, 1)))
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0
        fade.toValue = 1
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animation, fade]
        animationGroup.duration = animationDuartion
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animationGroup.delegate = self
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = kCAFillModeForwards
        
        let maskLayer = RWLogoLayer.logoLayer()
        maskLayer.position = fromVC.logo.position
        toVC.view.layer.mask = maskLayer
        maskLayer.add(animationGroup, forKey: nil)
        fromVC.logo.add(animationGroup, forKey: nil)
    }
    
    private func pop(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
            else { assertionFailure("Invalid view in transition"); return }
        
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        UIView.animate(withDuration: animationDuartion,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        fromView.transform = .init(scaleX: 0.01, y: 0.01)
        },
                       completion: { _ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

extension RevealAnimator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let context = storedContext,
            let fromVC = context.viewController(forKey: .from) as? MasterViewController,
            let toVC = context.viewController(forKey: .to) as? DetailViewController{
            context.completeTransition(!context.transitionWasCancelled)
            fromVC.logo.removeAllAnimations()
            toVC.view.layer.mask = nil
        }
        storedContext = nil
    }
}
