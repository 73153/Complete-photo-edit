//
//  ColorCell.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/16/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class ColorCell: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // fuck this shit
    }
    
    let label = UILabel()
    let preview = PatternView()
    let hueSlider = HueSlider()
    let graySlider = GraySlider()
    let rightButton = UIButton()
    let hueMarker = UIImageView(image: UIImage(named: "PPHueArrow")!)
    let touchView = UIView()
    var rightButtonInset: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var showGrayscale = false {
        didSet {
            if !showGrayscale && graySlider.superview != nil {
                graySlider.removeFromSuperview()
            } else if showGrayscale && graySlider.superview == nil {
                addSubview(graySlider)
            }
        }
    }
    
    func setup() {
        addSubview(hueSlider)
        addSubview(touchView)
        addSubview(rightButton)
        addSubview(label)
        addSubview(preview)
        addSubview(hueMarker)
        
        preview.patternScale = 0.1
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ColorCell.tapped(_:)))
        touchView.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ColorCell.panned(_:)))
        addGestureRecognizer(pan)
        
        hueMarker.alpha = 0.5
        label.alpha = 0.5
        rightButton.alpha = 0.5
        
        let hsva = self.hsva
        self.hsva = hsva
        
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        backgroundColor = UIColor.white
    }
    
    var hsva: (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0) {
        didSet {
            setNeedsLayout()
            if !showGrayscale {
                hueSlider.satVal = (hsva.1, hsva.2)
            }
        }
    }
    
    var onHsvaChanged: (((CGFloat, CGFloat, CGFloat, CGFloat)) -> ())?
    var onTouchUp: (() -> ())?
    
    var _hsvaAtStartOfGesture: (CGFloat, CGFloat, CGFloat, CGFloat)?
    func tapped(_ rec: UITapGestureRecognizer) {
        if rec.state == .began {
            _hsvaAtStartOfGesture = hsva
        }
        pickHueAtX(rec.location(in: self).x)
        if let cb = onTouchUp {
            cb()
        }
    }
    
    func panned(_ rec: UIPanGestureRecognizer) {
        if rec.state == .began {
            _hsvaAtStartOfGesture = hsva
        }
        pickHueAtX(rec.location(in: self).x)
        if rec.state == .ended, let cb = onTouchUp {
            cb()
        }
    }
    
    var _grayscaleFraction: CGFloat {
        get {
            return showGrayscale ? 0.35 : 0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth = bounds.size.height
        let hueHeight: CGFloat = 4
        let previewSize: CGFloat = 12
        let xInset: CGFloat = 10
        
        preview.frame = CGRect(x: xInset, y: (bounds.size.height - preview.frame.size.height)/2, width: previewSize, height: previewSize)
        preview.clipsToBounds = true
        preview.layer.cornerRadius = previewSize/2
        
        label.sizeToFit()
        label.frame = CGRect(x: preview.frame.origin.x + preview.frame.size.width + xInset, y: (bounds.size.height - label.frame.size.height)/2, width: label.frame.size.width, height: label.frame.size.height)
        
        rightButton.frame = CGRect(x: self.bounds.size.width - buttonWidth - rightButtonInset, y: 0, width: buttonWidth, height: self.bounds.size.height)
        
        hueSlider.frame = CGRect(x: 0, y: bounds.size.height - hueHeight, width: bounds.size.width * (1 - _grayscaleFraction), height: hueHeight)
        graySlider.frame = CGRect(x: bounds.size.width * (1 - _grayscaleFraction), y: hueSlider.frame.origin.y, width: bounds.size.width * _grayscaleFraction, height: hueHeight)
        
        touchView.frame = bounds
        
        hueMarker.sizeToFit()
        if hsva.1 == 0 && showGrayscale {
            hueMarker.center = CGPoint(x: bounds.size.width * (1 - _grayscaleFraction) + hsva.2 * bounds.size.width * _grayscaleFraction, y: bounds.size.height - hueHeight - hueMarker.bounds.size.height - 1)
        } else {
            hueMarker.center = CGPoint(x: hsva.0 * bounds.size.width * (1 - _grayscaleFraction), y: bounds.size.height - hueHeight - hueMarker.bounds.size.height - 1)
        }
    }
    
    func pickHueAtX(_ x: CGFloat) {
        var hsva = _hsvaAtStartOfGesture ?? self.hsva
        
        let unitX = x / bounds.size.width
        if unitX < (1 - _grayscaleFraction) {
            // it's a hue:
            hsva.0 = min(1, max(0, unitX / (1-_grayscaleFraction)))
            hsva.1 = 1
            hsva.2 = 1
        } else {
            // it's a grayscale val:
            hsva.1 = 0
            hsva.2 = (unitX - (1 - _grayscaleFraction)) / _grayscaleFraction
        }
        
        self.hsva = hsva
        if let cb = onHsvaChanged {
            cb(hsva)
        }
    }
}
