//
//  PatternPickerView.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/15/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class PatternPickerView: UIView {
    var pattern = Pattern(type: .solidColor, primaryColor: UIColor.green, secondaryColor: nil) {
        didSet {
            if onlyAllowSolidColors && !(pattern.type == Pattern.PatternType.solidColor) {
                pattern = Pattern(type: .solidColor, primaryColor: pattern.primaryColor, secondaryColor: nil)
            } else {
                cell.hsva = pattern.primaryColor.hsva
                cell.preview.pattern = pattern
            }
        }
    }
    var onlyAllowSolidColors = false
    var onPatternChanged: ((Pattern) -> ())?
    var onPatternChangeTransactionEnded: (() -> ())?
    var shouldEditModally: (() -> ())?
    fileprivate func _updatePattern(_ pattern: Pattern) {
        self.pattern = pattern
        if let cb = onPatternChanged {
            cb(pattern)
        }
    }
    
    static let rounding: CGFloat = 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    let cell = ColorCell()
    
    func setup() {
        addSubview(cell)
        let p = self.pattern
        self.pattern = p
        cell.showGrayscale = true
        
        cell.onHsvaChanged = {
            [weak self]
            (hsva) in
            let (h,s,v,_) = hsva
            if let p = self {
                var a = p.pattern.primaryColor.hsva.3
                if a == 0 { a = 1 }
                let newPrimaryColor = UIColor(hue: h, saturation: s, brightness: v, alpha: a)
                let pattern = Pattern(type: p.pattern.type, primaryColor: newPrimaryColor, secondaryColor: p.pattern.secondaryColor)
                p._updatePattern(pattern)
            }
        }
        
        cell.onTouchUp = {
            [weak self] in
            if let cb = self!.onPatternChangeTransactionEnded {
                cb()
            }
        }
        
        cell.label.text = NSLocalizedString("Fill", comment: "")
        cell.rightButton.setImage(UIImage(named: "PPChevron")!, for: UIControlState())
        cell.rightButton.addTarget(self, action: #selector(PatternPickerView._shouldEditModally(_:)), for: .touchUpInside)
        
        clipsToBounds = true
        layer.cornerRadius = PatternPickerView.rounding
    }
    
    func _shouldEditModally(_ sender: UIButton) {
        if let fn = shouldEditModally {
            fn()
        }
    }
    
    func editModally(_ viewController: UIViewController) {
        let vc = PatternPickerViewController()
        vc.onlyAllowSolidColors = onlyAllowSolidColors
        vc.pattern = pattern
        vc.onChangedPattern = {
            [weak self]
            (pattern) in
            if let s = self {
                s._updatePattern(pattern)
            }
        }
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc
        vc.parentView = self
        viewController.present(vc, animated: true, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cell.frame = bounds
    }
}
