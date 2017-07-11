//
//  AdultTypePresentationController.swift
//  Babies
//
//  Created by phi on 22/11/16.
//  Copyright © 2016 Stanhope Road. All rights reserved.
//

import UIKit

class AdultTypePresentationController: UIPresentationController {

    var blurView: UIVisualEffectView!

    override var frameOfPresentedViewInContainerView: CGRect {
        if let frame = containerView?.bounds {
            let offset = frame.height/8
            return frame.insetBy(dx: 10, dy: offset).offsetBy(dx: 0, dy: offset)
        } else {
            return super.frameOfPresentedViewInContainerView
        }
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func containerViewDidLayoutSubviews() {
        //
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else {
            return
        }

        blurView = UIVisualEffectView()
        containerView.insertSubview(blurView, at: 0)
        blurView.pinEdgesToSuperViewEdges()

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.blurView.effect = UIBlurEffect(style: .dark)
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        // print(#function)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.presentingViewController.view.transform = .identity
            self.blurView.effect = nil
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // print(#function)
    }
}
