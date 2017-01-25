//
//  PatternPickerViewController.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/15/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class PatternPickerViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    let background = UIView() //UIVisualEffectView(effect: nil)
    
    var pattern = Pattern(type: .solidColor, primaryColor: UIColor.green, secondaryColor: nil) {
        didSet {
            if onlyAllowSolidColors && !(pattern.type == Pattern.PatternType.solidColor) {
                pattern = Pattern(type: .solidColor, primaryColor: pattern.primaryColor, secondaryColor: nil)
            } else {
                primaryColorPicker.color = pattern.primaryColor
                secondaryColorPicker.color = pattern.secondaryColorOrDefault
                secondaryColorPicker.hue.preview.pattern = Pattern(type: .solidColor, primaryColor: secondaryColorPicker.color, secondaryColor: nil)
                primaryColorPicker.hue.preview.pattern = pattern
                _showSecondaryColor = pattern.type.involvesSecondaryColor
                patternTypePicker.selectedPatternType = pattern.type
                patternTypePicker.colors = (primaryColorPicker.color, secondaryColorPicker.color)
                doneButtonWithPreview.pattern = pattern
            }
        }
    }
    var onlyAllowSolidColors = false
    var onChangedPattern: ((Pattern) -> ())?
    fileprivate func _updatePattern(_ pattern: Pattern) {
        self.pattern = pattern
        if let cb = onChangedPattern {
            cb(pattern)
        }
    }
    
    let primaryColorPicker = ColorPickerCollection()
    let secondaryColorPicker = ColorPickerCollection()
    let patternTypePicker = PatternTypePicker(frame: CGRect.zero)
    let doneButtonWithPreview = PatternView()
    
    class ColorPickerCollection {
        init() {
            let c = color
            color = c
            for view in [satVal, hue, alphaSlider] as [UIView] {
                view.clipsToBounds = true
                view.layer.cornerRadius = PatternPickerView.rounding
            }
            hue.onHsvaChanged = {
                [weak self]
                (hsva) in
                let hue = hsva.0
                var (_,s,v,a) = self!.color.hsva
                if a == 0 { a = 1 }
                self!._updateColor(UIColor(hue: CGFloat(hue), saturation: s, brightness: v, alpha: a))
            }
            satVal.onSatValChanged = {
                [weak self]
                (satVal) in
                let (sat, val) = satVal
                let (h,_,_,a) = self!.color.hsva
                self!._updateColor(UIColor(hue: h, saturation: CGFloat(sat), brightness: CGFloat(val), alpha: a))
            }
            alphaSlider.onSelectedAlphaChanged = {
                [weak self]
                (alphaVal) in
                let (h,s,v,_) = self!.color.hsva
                self!._updateColor(UIColor(hue: h, saturation: s, brightness: v, alpha: CGFloat(alphaVal)))
            }
            
        }
        var color = UIColor.green {
            didSet {
                let (h,s,v,a) = color.hsva
                hue.hsva = color.hsva
                satVal.satVal = (Float(s), Float(v))
                satVal.hue = Float(h)
                alphaSlider.selectedAlpha = Float(a)
                alphaSlider.hsv = (Float(h), Float(s), Float(v))
            }
        }
        var onColorChange: ((UIColor) -> ())?
        
        let hue = ColorCell(frame: CGRect.zero)
        let satVal = SatValGrid()
        let alphaSlider = AlphaSlider()
        
        fileprivate func _updateColor(_ color: UIColor) {
            self.color = color
            if let cb = onColorChange {
                cb(color)
            }
        }
        
        var views: [UIView] {
            get {
                return [hue, satVal, alphaSlider]
            }
        }
    }
    
    override func loadView() {
        self.view = UIScrollView()
    }
    
    var scrollView: UIScrollView! {
        get {
            return self.view as! UIScrollView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(background)
        view.backgroundColor = UIColor.clear
        background.alpha = 0
        background.backgroundColor = UIColor.black
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(PatternPickerViewController.dismiss(_:)))
        background.addGestureRecognizer(tapRec)
        
        primaryColorPicker.hue.label.text = NSLocalizedString("Fill", comment: "")
        secondaryColorPicker.hue.label.text = NSLocalizedString("Secondary color", comment: "")
        
        patternTypePicker.backgroundColor = UIColor.white
        patternTypePicker.clipsToBounds = true
        patternTypePicker.layer.cornerRadius = PatternPickerView.rounding
        
        let doneButton = UIButton(type: .custom)
        doneButton.setTitle(NSLocalizedString("Done", comment: ""), for: UIControlState())
        doneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        doneButtonWithPreview.addSubview(doneButton)
        doneButton.frame = doneButton.superview!.bounds
        doneButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        doneButton.addTarget(self, action: #selector(PatternPickerViewController.dismiss(_:)), for: .touchUpInside)
        doneButtonWithPreview.clipsToBounds = true
        doneButtonWithPreview.layer.cornerRadius = PatternPickerView.rounding
        
        view.addSubview(doneButtonWithPreview)
        
        scrollView.showsVerticalScrollIndicator = false
        
        for childView in primaryColorPicker.views + secondaryColorPicker.views {
            view.addSubview(childView)
        }
        
        primaryColorPicker.onColorChange = {
            [weak self]
            (color) in
            self!._updatePattern(Pattern(type: self!.pattern.type, primaryColor: color, secondaryColor: self!.pattern.secondaryColor))
        }
        secondaryColorPicker.onColorChange = {
            [weak self]
            (color) in
            self!._updatePattern(Pattern(type: self!.pattern.type, primaryColor: self!.pattern.primaryColor, secondaryColor: color))
        }
        patternTypePicker.onSelectedPatternTypeChanged = {
            [weak self]
            (patternType) in
            self!._updatePattern(Pattern(type: patternType, primaryColor: self!.pattern.primaryColor, secondaryColor: self!.pattern.secondaryColor))
        }
        
        view.addSubview(patternTypePicker)
        
        /*primaryColorPicker.hue.rightButton.setTitle(NSLocalizedString("Done", comment: ""), forState: .Normal)
        primaryColorPicker.hue.rightButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        primaryColorPicker.hue.rightButtonInset = 10
        primaryColorPicker.hue.rightButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        primaryColorPicker.hue.rightButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)*/
        
        let p = pattern
        self.pattern = p
    }
    
    var contentViews: [UIView] {
        get {
            if onlyAllowSolidColors {
                return primaryColorPicker.views
            } else {
                return primaryColorPicker.views + [patternTypePicker] + secondaryColorPicker.views + [doneButtonWithPreview]
            }
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        if let cb = parentView.onPatternChangeTransactionEnded {
            cb()
        }
    }
    
    var parentView: PatternPickerView!
    fileprivate var _parentViewFrameInSelfViewCoordinates: CGRect?
    
    // MARK: Content
    var _showSecondaryColor = false {
        didSet {
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                for v in self.secondaryColorPicker.views {
                    v.alpha = self._showSecondaryColor ? 1 : 0
                }
                self.viewDidLayoutSubviews()
                }, completion: { (completed) -> Void in
                    
            }) 
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        background.frame = view.bounds
        
        let margin: CGFloat = 20
        var y = margin
        
        for childView in contentViews {
            
            var height: CGFloat = 44
            if let _ = childView as? SatValGrid {
                height = 88
            }
            if !isBeingDismissed {
                childView.frame = CGRect(x: margin, y: y, width: view.bounds.size.width - margin*2, height: height)
            }
            if _showSecondaryColor || !secondaryColorPicker.views.contains(childView) {
                y += height + margin
            }
        }
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.size.width, height: y)
    }
    
    // MARK: Transitioning
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let dismissing = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) === self
        let duration = transitionDuration(using: transitionContext)
        
        viewDidLayoutSubviews()
        
        let mainHueView = primaryColorPicker.hue
        var viewsToFade = contentViews
        viewsToFade.remove(at: viewsToFade.index(of: mainHueView)!)
        
        if dismissing {
            UIView.animate(withDuration: duration, animations: { () -> Void in
                // self.background.effect = nil
                self.background.alpha = 0
                for v in viewsToFade {
                    v.alpha = 0
                }
                mainHueView.frame = self._parentViewFrameInSelfViewCoordinates!
                mainHueView.layoutIfNeeded()
                }, completion: { (completed) -> Void in
                    transitionContext.completeTransition(true)
            })
        } else {
            transitionContext.containerView.addSubview(view)
            view.frame = transitionContext.finalFrame(for: self)
            
            viewDidLayoutSubviews()
            
            _parentViewFrameInSelfViewCoordinates = mainHueView.superview!.convert(self.parentView.bounds, from: self.parentView)
            
            let mainHueViewFrame = mainHueView.frame
            mainHueView.frame = _parentViewFrameInSelfViewCoordinates!
            mainHueView.superview!.bringSubview(toFront: mainHueView)
            mainHueView.layoutIfNeeded()
            
            let oldAlphas = viewsToFade.map({ $0.alpha })
            for v in viewsToFade {
                v.alpha = 0
            }
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                // self.background.effect = UIBlurEffect(style: .Dark)
                self.background.alpha = 1
                for (v, alpha) in zip(viewsToFade, oldAlphas) {
                    v.alpha = alpha
                }
                mainHueView.frame = mainHueViewFrame
                mainHueView.layoutIfNeeded()
                }, completion: { (completed) -> Void in
                    transitionContext.completeTransition(true)
            })
        }
    }
}
