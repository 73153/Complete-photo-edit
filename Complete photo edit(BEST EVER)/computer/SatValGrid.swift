//
//  SatValGrid.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/15/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class SatValGrid: UIImageView {
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setup()
    }
    
    let marker = UIView()
    
    func setup() {
        addSubview(marker)
        marker.bounds = CGRect(x: 0, y: 0, width: 8, height: 8)
        marker.backgroundColor = UIColor.white
        marker.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / 4.0))
        
        let sv = satVal
        satVal = sv
        let h = hue
        hue = h
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SatValGrid._move(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(SatValGrid._move(_:))))
    }
    
    func _move(_ sender: UIGestureRecognizer) {
        let pos = sender.location(in: self)
        let sat = Float(max(0, min(1, pos.x / bounds.size.width)))
        let val = Float(max(0, min(1, pos.y / bounds.size.height)))
        satVal = (sat, val)
        if let cb = onSatValChanged {
            cb(sat, val)
        }
    }
    
    var hue: Float = 0 {
        didSet {
            render()
        }
    }
    
    func render() {
        let pixels = UnsafeMutablePointer<PixelData>.allocate(capacity: 128 * 128)
        for y in 0..<128 {
            for x in 0..<128 {
                var r: Float = 0
                var g: Float = 0
                var b: Float = 0
                HSVtoRGB(&r, &g, &b, hue * 360.0, Float(x) / 128.0, Float(y) / 128.0)
                pixels[y*128 + x] = PixelData(a: 255, r: UInt8(r*Float(255.0)), g: UInt8(g*Float(255.0)), b: UInt8(b*Float(255.0)))
            }
        }
        self.image = imageFromARGB32Bitmap(pixels, width: 128, height: 128)
        pixels.deinitialize()
    }
    
    var satVal: (Float, Float) = (0, 0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var onSatValChanged: ((Float, Float) -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let (s, v) = satVal
        marker.center = CGPoint(x: CGFloat(s) * bounds.size.width, y: CGFloat(v) * bounds.size.height)
    }
}
