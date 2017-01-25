//
//  PatternView.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/15/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class PatternView: UIView {
    var pattern: Pattern = Pattern(type: .solidColor, primaryColor: UIColor.green, secondaryColor: nil) {
        didSet {
            _contentView = pattern.renderAsView(_contentView)
            let s = patternScale
            patternScale = s
        }
    }
    fileprivate var _contentView: UIView? {
        willSet(newVal) {
            if newVal !== _contentView {
                if let old = _contentView {
                    old.removeFromSuperview()
                }
                if let view = newVal {
                    insertSubview(view, at: 0)
                }
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        _contentView?.frame = bounds
    }
    var patternScale: CGFloat = 1 {
        didSet {
            if let v = _contentView {
                v.transform = CGAffineTransform(scaleX: patternScale, y: patternScale)
                v.bounds = CGRect(x: 0, y: 0, width: bounds.size.width / patternScale, height: bounds.size.height / patternScale)
            }
        }
    }
}
