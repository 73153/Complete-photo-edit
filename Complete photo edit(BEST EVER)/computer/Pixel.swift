//
//  Pixel.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/15/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

// from http://stackoverflow.com/questions/30958427/pixel-array-to-uiimage-in-swift

public struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

func imageFromARGB32Bitmap(_ pixels: UnsafeMutablePointer<PixelData>, width: Int, height: Int)-> UIImage {
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    let bitsPerComponent:Int = 8
    let bitsPerPixel:Int = 32
    
    // assert(pixels.count == Int(width * height))
    
    // var data = pixels // Copy to mutable []
//    let providerRef = CGDataProvider(
//        data: Data(bytes: UnsafePointer<UInt8>(pixels), count: width * height * MemoryLayout<PixelData>.size) as CFData
//    )
    let providerRef = CGDataProvider(data: Data(bytes: pixels, count: width * height) as CFData)
    
    let cgim = CGImage(
        width: width,
        height: height,
        bitsPerComponent: bitsPerComponent,
        bitsPerPixel: bitsPerPixel,
        bytesPerRow: width * Int(MemoryLayout<PixelData>.size),
        space: rgbColorSpace,
        bitmapInfo: bitmapInfo,
        provider: providerRef!,
        decode: nil,
        shouldInterpolate: true,
        intent: .defaultIntent
    )!
    return UIImage(cgImage: cgim)
}
