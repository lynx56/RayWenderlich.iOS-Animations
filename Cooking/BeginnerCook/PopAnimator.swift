//
//  PopAnimator.swift
//  BeginnerCook
//
//  Created by lynx on 02/03/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 1
    var presenting = true
    var originFrame: CGRect = .zero
    var dismissCompletion: (() -> Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationView = transitionContext.view(forKey: .to)
            else { assertionFailure("destination controller is nil"); return }
        let herbView = presenting ? destinationView : transitionContext.view(forKey: .from)!
        let containerView = transitionContext.containerView
        let herbVC = (presenting ? transitionContext.viewController(forKey: .to)! : transitionContext.viewController(forKey: .from)!) as! HerbDetailsViewController
        
        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame
        
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            herbView.clipsToBounds = true
        }
        
        containerView.addSubview(destinationView)
        containerView.bringSubview(toFront: herbView)
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0,
                       animations: {
                        herbView.transform = self.presenting ? .identity : scaleTransform
                        herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                        herbView.layer.cornerRadius = self.presenting ? 0 : 20 / xScaleFactor
                        herbVC.containerView.alpha = self.presenting ? 1 : 0
        },
                       completion: { _ in
                        if !self.presenting {
                            self.dismissCompletion?()
                        }
                        transitionContext.completeTransition(true)
        })
    }
}
