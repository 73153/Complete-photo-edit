//
//  AlphaSlider.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/15/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class AlphaSlider: UIView {
    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        get {
            return self.layer as! CAGradientLayer
        }
    }
    
    var marker = UIView()
    
    func setup() {
        let h = hsv
        self.hsv = h
        backgroundColor = UIColor(patternImage: UIImage(named: "PPCheckerboard")!)
        
        addSubview(marker)
        marker.bounds = CGRect(x: 0, y: 0, width: 8, height: 8)
        marker.backgroundColor = UIColor.white
        marker.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 4))
        
        let a = selectedAlpha
        selectedAlpha = a
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AlphaSlider._moved(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(AlphaSlider._moved(_:))))
    }
    
    func _moved(_ sender: UIGestureRecognizer) {
        selectedAlpha = Float(max(0, min(1, sender.location(in: self).x / bounds.size.width)))
        if let cb = onSelectedAlphaChanged {
            cb(selectedAlpha)
        }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setup()
    }
    
    var hsv: (Float, Float, Float) = (0,0,0) {
        didSet {
            let (h,s,v) = hsv
            gradientLayer.startPoint = CGPoint.zero
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.colors = [UIColor(hue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(v), alpha: 0).cgColor, UIColor(hue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(v), alpha: 1).cgColor]
        }
    }
    
    var selectedAlpha: Float = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var onSelectedAlphaChanged: ((Float) -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        marker.center = CGPoint(x: bounds.size.width * CGFloat(selectedAlpha), y: bounds.size.height / 2)
    }
}
