//
//  CMGroupFillWrapper.swift
//  computer
//
//  Created by Nate Parrott on 2/23/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class CMGroupFillWrapper: CMDrawableView {
    var group: CMGroupDrawable? {
        didSet {
            
        }
    }
    
    var fillView: CMDrawableView? {
        willSet(newVal) {
            if fillView != newVal {
                fillView?.removeFromSuperview()
                if let new = newVal {
                    addSubview(new)
                }
            }
        }
    }
    
    var childView: CMDrawableView? {
        willSet(newVal) {
            if newVal != self.mask {
                self.mask = childView
                if let child = childView {
                    bounds = child.bounds
                    child.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let fill = fillView {
            let scale = max(bounds.size.width / fill.bounds.size.width, bounds.size.height / fill.bounds.size.height)
            fill.transform = CGAffineTransform(scaleX: scale, y: scale)
            fill.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        }
    }
}
