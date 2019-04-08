//
//  DismissAnimator.swift
//  CookBook
//
//  Created by alejandro Lopez on 12/22/16.
//  Copyright © 2016 Aleks. All rights reserved.
//


import UIKit

class DismissAnimator: NSObject {
    
    var destinationFrame = CGRect.zero
}


extension DismissAnimator : UIViewControllerAnimatedTransitioning {
    /*
     The animator adopts the UIViewControllerAnimatedTransitioning Protocol which has two required methiods:
     transitionDuration(_:)
     animationTransition(_:)
     */
    
    
    
    //MARK: transitionDuration(_:): This is how long the animation is
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    //MARK: animationTransition(_:): This is the animation and the code will go here
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        let containerView = transitionContext.containerView
        
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        
        let screenBounds = UIScreen.main.bounds
        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromViewController.view.frame = finalFrame
                fromViewController.view.layer.opacity = 0.0
        },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        )
        
        
        
        
    }
}
