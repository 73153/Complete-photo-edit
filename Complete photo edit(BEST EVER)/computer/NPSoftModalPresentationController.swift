//
//  NPSoftModalPresentationController.swift
//  scratchx
//
//  Created by Nate Parrott on 10/14/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class NPSoftModalPresentationController: UIPresentationController, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    class func getViewControllerForPresentationInWindow(_ window: UIWindow) -> UIViewController {
        var parent = window.rootViewController!
        while let modal = parent.presentedViewController {
            if modal.isBeingDismissed {
               break
            } else {
                parent = modal
            }
        }
        return parent
    }
    
    class func getViewControllerForPresentation() -> UIViewController {
        return getViewControllerForPresentationInWindow(UIApplication.shared.windows.first!)
    }
    
    class func presentViewController(_ viewController: UIViewController) {
        presentViewController(viewController, fromViewController: getViewControllerForPresentationInWindow(UIApplication.shared.windows.first!))
    }
    
    class func presentViewController(_ viewController: UIViewController, fromViewController: UIViewController) {
        let presenter = NPSoftModalPresentationController(presentedViewController: viewController, presenting: fromViewController)
        viewController.transitioningDelegate = presenter
        viewController.modalPresentationStyle = .custom
        fromViewController.present(viewController, animated: true, completion: nil)
    }
    
    fileprivate var _dimView: UIView!
    fileprivate var _tapRec: UITapGestureRecognizer!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let toVC = transitionContext!.viewController(forKey: UITransitionContextViewControllerKey.to)!
        if toVC === self.presentedViewController {
            // we're presenting a modal:
            return 0.3
        } else {
            // we're dismissing:
            return 0.3
        }
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        if toVC === self.presentedViewController {
            _animatePresentation(transitionContext)
        } else {
            _animateDismissal(transitionContext)
        }
    }
    
    override func presentationTransitionWillBegin() {
        _dimView = UIView()
        _dimView.backgroundColor = UIColor.black
        _dimView.alpha = 0
        
        _tapRec = UITapGestureRecognizer(target: self, action: #selector(NPSoftModalPresentationController._tappedDimView(_:)))
        _dimView.addGestureRecognizer(_tapRec)
        
        containerView!.addSubview(_dimView)
        _dimView.frame = containerView!.bounds
        presentingViewController.transitionCoordinator!.animate(alongsideTransition: { (ctx) -> Void in
            self._dimView.alpha = 0.6
            }) { (ctx) -> Void in
                
        }
    }
    
    @objc fileprivate func _tappedDimView(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func _animatePresentation(_ transitionContext: UIViewControllerContextTransitioning) {
        let vc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let view = vc.view
        view?.frame = transitionContext.finalFrame(for: vc)
        let container = transitionContext.containerView
        container.addSubview(view!)
        let translation = (container.bounds.size.height - (view?.frame.origin.y)!) * 0.5
        view?.alpha = 0
        view?.transform = CGAffineTransform(translationX: 0, y: translation + 20)
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            view?.transform = CGAffineTransform.identity
            view?.alpha = 1
            }) { (completed) -> Void in
                transitionContext.completeTransition(true)
        }
    }
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        _dimView.frame = containerView!.bounds
        if let view = presentedView {
            let frame = frameOfPresentedViewInContainerView
            view.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            view.center = CGPoint(x: frame.midX, y: frame.midY)
        }
    }
    override var frameOfPresentedViewInContainerView : CGRect {
        let bounds = containerView!.bounds
        /*let contentWidth = bounds.size.width - 40
        let contentHeight = min(contentWidth, bounds.size.height)*/
        let widthInset: CGFloat = traitCollection.horizontalSizeClass == .compact ? 20 : 40
        let heightInset: CGFloat = traitCollection.verticalSizeClass == .compact ? 0 : 50
        let contentWidth = bounds.size.width - widthInset * 2
        let contentHeight = bounds.size.height - heightInset * 2
        return CGRect(x: (bounds.size.width - contentWidth)/2, y: (bounds.size.height - contentHeight)/2, width: contentWidth, height: contentHeight).integral
    }
    override var shouldRemovePresentersView : Bool {
        return false
    }
    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator!.animate(alongsideTransition: { (ctx) -> Void in
            self._dimView.alpha = 0
            }) { (ctx) -> Void in
                self._dimView.removeFromSuperview()
        }
    }
    fileprivate func _animateDismissal(_ transitionContext: UIViewControllerContextTransitioning) {
        let vc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let view = vc.view
        let container = transitionContext.containerView
        let translation = (container.bounds.size.height - (view?.frame.origin.y)!) * 0.5
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            view?.transform = CGAffineTransform(translationX: 0, y: translation)
            // view.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, translation), CGFloat(M_PI) * 0.3)
            view?.alpha = 0
            }) { (completed) -> Void in
                view?.alpha = 1;
                transitionContext.completeTransition(true)
        }
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
    }
    
    // MARK: Transition Delegate
    // (private implementation, used for presentViewController())
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return NPSoftModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presented.presentationController as? NPSoftModalPresentationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissed.presentationController as? NPSoftModalPresentationController
    }
}
