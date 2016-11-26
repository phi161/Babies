//
//  AdultTypeTransitionAnimator.swift
//  Babies
//
//  Created by phi on 22/11/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class AdultTypeTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from)
        else {return}
        
        let isPresenting = toViewController == fromViewController.presentedViewController
        let containerView = transitionContext.containerView
        let animationDuration = self.transitionDuration(using: transitionContext)
        
        if isPresenting {
            toViewController.view.frame.origin.y = toViewController.view.frame.size.height
            toViewController.view.layer.cornerRadius = 5.0
            toViewController.view.clipsToBounds = true
            
            containerView.addSubview(toViewController.view)
            
            UIView.animate(withDuration: animationDuration, animations: {
                toViewController.view.frame.origin.y = 0
            }) { (finished) in
                transitionContext.completeTransition(finished)
            }
        } else {
            UIView.animate(withDuration: animationDuration, animations: {
                fromViewController.view.frame.origin.y = toViewController.view.frame.size.height
            }) { (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        // print(#function)
    }
}
