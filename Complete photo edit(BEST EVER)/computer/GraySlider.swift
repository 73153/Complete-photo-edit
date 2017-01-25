//
//  GraySlider.swift
//  computer
//
//  Created by Nate Parrott on 1/11/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class GraySlider: UIImageView {
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        render()
        contentMode = .scaleToFill
    }
    
    func render() {
        let pixels = UnsafeMutablePointer<PixelData>.allocate(capacity: 256)
        for i in 0..<256 {
            var r: Float = 0
            var g: Float = 0
            var b: Float = 0
            let val = Float(i) / 255.0
            HSVtoRGB(&r, &g, &b, 0, 0, val)
            pixels[i] = PixelData(a: 255, r: UInt8(r*Float(255.0)), g: UInt8(g*Float(255.0)), b: UInt8(b*Float(255.0)))
        }
        self.image = imageFromARGB32Bitmap(pixels, width: 256, height: 1)
        pixels.deinitialize()
    }
}
